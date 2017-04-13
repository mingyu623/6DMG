#!/usr/bin/perl
# Mingyu @ Mar 5 2013
# Generate "$dtype" invariant shared files:
# The viterbi decoding network with bigram probs (from $voc)
# 1. $backoff = 0 -> "wdnet_bigram_($voc)f" - w/o backoff, set prob(unseen bigram) to 0
# 2. $backoff = 1 -> "wdnet_bigram_($voc)"  - w/  backoff
#
# Note: 100k voc contains every possible bigrams => no backoff is needed

use strict;
use File::Path qw(make_path);

# input
my $voc;
my $backoff;
if ($#ARGV != 1)
{
    print "usage: generate_wdnet_bigram [voc] [backoff]\n";
    print " [voc] = 40, 1k, or 100k.  The vocabulary size to compute bigram\n";
    print " [backoff] = 0: wdnet_bigram_($voc)f - w/o backoff. prob(unseen bigram) = 0\n";
    print "             1: wdnet_bigram_($voc)  - w/  backoff\n";
    exit;
}
else
{
    $voc     = $ARGV[0];
    $backoff = $ARGV[1];
    if (($voc ne "40") and ($voc ne "1k") and ($voc ne "100k"))
    {
        print "[voc] is wrong\n";
        exit;
    }
}
my $outDir  = "share";
my $bi_prob = "$outDir/voc_chars_$voc.arpa";

# output
my $wdnet_bi = "$outDir/wdnet_bigram_$voc";
unless ($backoff){ $wdnet_bi = $wdnet_bi."f"; }
unless (-d $outDir){ make_path $outDir; }


#========================================================
# Manually craft "wdnet" w/o gram & HParse
# The network is free for any possible character sequences!
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

for (1..3) # three dummy !NULL nodes
{
    push @node_lines, "I=$node_num\tW=!NULL"; $node_num+=1;
}
my $node_start = $node_num-3; # the starting node of this word network
my $node_buf   = $node_num-2; # the buff node right before the end node
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
    
    # connect $node_start -> $node_curr
    $key = "<s>-$C";
    push @bigram_lines, "J=$edge_num\t"."S=$node_start\t"."E=$node_curr\t"."l=$bi_prob_hash{$key}"; $edge_num+=1;

    # connect $node_curr -> $node_buf
    $key = "$C-<s>";
    push @bigram_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$node_buf\t"."l=$bi_prob_hash{$key}"; $edge_num+=1;
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
# connect $node_nuf -> $node_end
push @bigram_lines, "J=$edge_num\t"."S=$node_buf\t"."E=$node_end"; $edge_num+=1;


open WDNET_BI, ">$wdnet_bi" or die $!;
print WDNET_BI "N=$node_num\tL=$edge_num\n";
foreach my $line (@node_lines, @bigram_lines)
{
    print WDNET_BI "$line\n";
}
close WDNET_BI;
print "generate $wdnet_bi\n";
