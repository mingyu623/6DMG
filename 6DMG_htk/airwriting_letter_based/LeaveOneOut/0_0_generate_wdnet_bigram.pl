#!/usr/bin/perl
# Mingyu @ Apr 22 2013
# Generate "$dtype" invariant shared files:
# The viterbi decoding network with bigram probs (from $voc)
# 1. $backoff = 1 -> "wdnet_bigram_($voc)"  - w/  backoff
# 2. $backoff = 0 -> "wdnet_bigram_($voc)f" - w/o backoff, set prob(unseen bigram) to 0
# 3. Add "FIL" node to handle "non-writing" false alarm
#
# Note: 100k voc contains every possible bigrams => no backoff is needed

use strict;
use File::Path qw(make_path);

my $voc;
if ($#ARGV != 0)
{
    print "usage: generate_wdnet_bigram [voc]\n";
    print " [voc]: 100, 100f, 1k, 1kf\n";
    exit;
}
else
{
    $voc   = $ARGV[0];
    if ($voc ne "100" and $voc ne "100f" and $voc ne "1k" and $voc ne "1kf"){
	die "incorrect wdnet with voc $voc\n";
    }
}


# input
my $backoff;
my $vocArpa;
if (substr($voc,-1,1) eq 'f'){
    $backoff = 0;
    $vocArpa = substr($voc,0,-1);
}
else{
    $backoff = 1;
    $vocArpa = $voc;
}
my $outDir  = "share";
my $bi_prob = "$outDir/voc2_chars_$vocArpa"."_linear.arpa";


# output
my $wdnet_bi = "$outDir/wdnet_bigram_$voc";
unless (-d $outDir){ make_path $outDir; }


#========================================================
# Manually craft "wdnet" w/o gram & HParse
# The network is free for any possible character sequences!
# Add optional "fil" at the begin and end of the network
#========================================================
my @node_lines  = ();
my @bigram_lines= ();
my %node_hash = ();
my %bi_prob_hash  = ();
my %uni_prob_hash = ();
my %bo_wt_hash    = ();
my $node_num = 0;
my $edge_num = 0;

foreach my $C ('A'..'Z')
{
    push @node_lines, "I=$node_num\t"."W=$C";
    $node_hash{ $C } = $node_num;
    $node_num += 1;
}
foreach my $L ('A'..'Z')
{
    foreach my $R ('A'..'Z')
    {
	push @node_lines, "I=$node_num\t"."W=$L-$R";
	$node_hash{ "$L-$R" } = $node_num;
	$node_num += 1;
    }
}

# add two nodes for "fil"
push @node_lines, "I=$node_num\t"."W=fil"; $node_num+=1;
push @node_lines, "I=$node_num\t"."W=fil"; $node_num+=1;
my $node_fil_1st = $node_num-2; # the 1st fil node (right after the starting node)
my $node_fil_2nd = $node_num-1; # the 2nd fil node (right before the end node)

# add one node for "FIL"
push @node_lines, "I=$node_num\t"."W=FIL"; $node_num+=1;
my $node_FIL = $node_num-1;    # the FIL node (will output label when decoding!)

# four dummy !NULL nodes
for (1..4) 
{
    push @node_lines, "I=$node_num\tW=!NULL"; $node_num+=1;
}
my $node_start = $node_num-4; # the starting node of this word network
my $node_buf1  = $node_num-3; # the buff node after the starting node
my $node_buf2  = $node_num-2; # the buff node before the ending node
my $node_end   = $node_num-1; # the end node of this word network


#-------------------------------------------
# Read the link probs into %bi_prob_hash, %uni_prob_hash & %bo_wt_hash
#-------------------------------------------
my $ln10 = log(10);  # log(x) = log10(x)*log(10);
open BI_PROB, $bi_prob or die $!;
while (my $line = <BI_PROB>)
{
    if ($line =~ m/\\[1|2]-grams:/) # appear twice in arpa
    {
INNER:	while ($line = <BI_PROB>)
	{
	    if ($line =~ m/-{0,1}\d*\.{0,1}\d+$/) # 1-gram case
	    {
		chomp($line);
		my @arr = split(' ', $line);
		my $key = $arr[1];
		$uni_prob_hash{$key} = $arr[0] * $ln10;
		$bo_wt_hash{$key}    = $arr[2] * $ln10;
	    }
	    elsif ($line =~ m/^-{0,1}\d*\.{0,1}\d+/) # 2-gram case
	    {
		chomp($line);
		my @arr = split(' ', $line);
		my $key = "$arr[1]-$arr[2]";
		$bi_prob_hash{$key} = $arr[0] * $ln10;
	    }
	    
	    else{
		last INNER;
	    }
	}
    }
}
close BI_PROB;


# complete the missing bigram entries
# if ($backoff) -> backoff probs
# else          -> -99.99
foreach my $C1 ('A'..'Z', '<s>')
{
    foreach my $C2 ('A'..'Z','<s>')
    {
	my $key = "$C1-$C2";
	unless (exists $bi_prob_hash{$key})
	{
	    if ($backoff){
		$bi_prob_hash{$key} = $bo_wt_hash{$C1} + $uni_prob_hash{$C2};
	    }
	    else{
		$bi_prob_hash{$key} = -99.9999;
	    }
	}
    }
}

#-------------------------------------------
# connect links between nodes for wdnet with log prob
#-------------------------------------------
$edge_num = 0;       # reset edge nums
foreach my $C ('A'..'Z')
{
    my $key;
    my $node_curr = $node_hash{$C};
    
    # connect $node_buf1 -> $node_curr
    $key = "<s>-$C";
    push @bigram_lines, "J=$edge_num\t"."S=$node_buf1\t"."E=$node_curr\t"."l=$bi_prob_hash{$key}"; $edge_num+=1;

    # connect $node_curr -> $node_buf2
    $key = "$C-<s>";
    push @bigram_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$node_buf2\t"."l=$bi_prob_hash{$key}"; $edge_num+=1;
    foreach my $N ('A'..'Z')
    {
	# connect $node_curr -> all lig_nodes
	$key = "$C-$N";
	my $LigR = $node_hash{ "$C-$N" };
	push @bigram_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$LigR\t"."l=$bi_prob_hash{$key}"; $edge_num+=1;

	# connect all lig_nodes -> $node_curr (no prob)
	my $LigL = $node_hash{ "$N-$C" };
	push @bigram_lines, "J=$edge_num\t"."S=$LigL\t"."E=$node_curr"; $edge_num+=1;
    }    
}


# connect $node_fil_1st with $node_start, $node_buf1
#push @bigram_lines, "J=$edge_num\t"."S=$node_start\t"."E=$node_buf1";    $edge_num+=1; # do NOT skip $node_fil_1st
push @bigram_lines, "J=$edge_num\t"."S=$node_start\t"."E=$node_fil_1st"; $edge_num+=1;
push @bigram_lines, "J=$edge_num\t"."S=$node_fil_1st\t"."E=$node_buf1";  $edge_num+=1;

# connect $node_fil_2nd with $node_end, $node_buf2
#push @bigram_lines, "J=$edge_num\t"."S=$node_buf2\t"."E=$node_end";      $edge_num+=1; # do NOT skip $node_fil_2nd
push @bigram_lines, "J=$edge_num\t"."S=$node_buf2\t"."E=$node_fil_2nd";  $edge_num+=1;
push @bigram_lines, "J=$edge_num\t"."S=$node_fil_2nd\t"."E=$node_end";   $edge_num+=1;

# connect $node_FIL to $node_buf1 and $node_buf2 (for non-writing)
push @bigram_lines, "J=$edge_num\t"."S=$node_buf1\t"."E=$node_FIL";   $edge_num+=1;
push @bigram_lines, "J=$edge_num\t"."S=$node_FIL\t"."E=$node_buf2";   $edge_num+=1;

open WDNET_BI, ">$wdnet_bi" or die $!;
print WDNET_BI "N=$node_num\tL=$edge_num\n";
foreach my $line (@node_lines, @bigram_lines)
{
    print WDNET_BI "$line\n";
}
close WDNET_BI;
print "generate $wdnet_bi\n";
