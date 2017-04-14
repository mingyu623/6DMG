#!/usr/bin/perl
# Mingyu @ Mar 5 2013
# Generate "$dtype" invariant shared files
# 1. "wdnet"        - viterbi decoding network for arbitrary letter sequences 
# 2. "word_ref.mlf" - labels of all words for HResults
# 3. "wdnet_bigram" - viterbi decoding network with bigram probs (from 100k vocab)
use strict;
use File::Path qw(make_path);

my $data_dir;
if ($#ARGV != 0) {
    print "usage: generate_share.pl [data_dir]";
    print " [data_dir]: the base path to the \$datatype folder\n";
} else {
    $data_dir = $ARGV[0];
}

my $outDir   = "share";
my $bi_prob  = "$outDir/voc_chars_100k.arpa"; # input file
my $wdnet    = "$outDir/wdnet";
# wdnet_bigram is identical to wdnet_bigram_100k in 0_1_gen... script
my $wdnet_bi = "$outDir/wdnet_bigram";
my $refMlf   = "$outDir/word_ref.mlf";
unless (-d $outDir){ make_path $outDir; }


#========================================================
# Manually craft "wdnet" w/o gram & HParse
# The network is free for any possible character sequences!
#========================================================
my @node_lines  = ();
my @edge_lines  = ();
my @bigram_lines= ();
my %node_hash = ();
my %prob_hash = ();
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
# Read the link probs into %prob_hash
#-------------------------------------------
my $ln10 = log(10);  # log(x) = log10(x)*log(10);
open BI_PROB, $bi_prob or die $!;
while (my $line = <BI_PROB>)
{
    if ($line =~ m/\\2-grams:/) # appear twice in arpa
    {
INNER:	while ($line = <BI_PROB>)
	{
	    if ($line =~ m/^-{0,1}\d*\.{0,1}\d+/)
	    {
		chomp($line);
		my @arr = split(' ', $line);
		my $key = "$arr[1]-$arr[2]";
		$prob_hash{$key} = $arr[0] * $ln10;
	    }
	    else{
		last INNER;
	    }
	}
    }
}
close BI_PROB;

#-------------------------------------------
# connect links between nodes for wdnet
#-------------------------------------------
foreach my $C ('A'..'Z')
{
    my $node_curr = $node_hash{$C};

    # connect $node_start -> $node_curr
    push @edge_lines, "J=$edge_num\t"."S=$node_start\t"."E=$node_curr"; $edge_num+=1;

    # connect $node_curr -> $node_buf    
    push @edge_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$node_buf"; $edge_num+=1;
    
    foreach my $N ('A'..'Z')
    {
	# connect $node_curr -> all lig_nodes
	my $LigR = $node_hash{ "$C-$N" };
	push @edge_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$LigR"; $edge_num+=1;

	# connect all lig_nodes -> $node_curr
	my $LigL = $node_hash{ "$N-$C" };
	push @edge_lines, "J=$edge_num\t"."S=$LigL\t"."E=$node_curr"; $edge_num+=1;
    }
}

# connect $node_nuf -> $node_end
push @edge_lines, "J=$edge_num\t"."S=$node_buf\t"."E=$node_end"; $edge_num+=1;

open  WDNET, ">$wdnet" or die $!;
print WDNET "N=$node_num\tL=$edge_num\n";
foreach my $line (@node_lines, @edge_lines)
{
    print WDNET "$line\n";
}
close WDNET;
print "generate $wdnet\n";


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
    push @bigram_lines, "J=$edge_num\t"."S=$node_start\t"."E=$node_curr\t"."l=$prob_hash{$key}"; $edge_num+=1;

    # connect $node_curr -> $node_buf
    $key = "$C-<s>";
    push @bigram_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$node_buf\t"."l=$prob_hash{$key}"; $edge_num+=1;
    foreach my $N ('A'..'Z')
    {
	# connect $node_curr -> all lig_nodes
	$key = "$C-$N";
	my $LigR = $node_hash{ "$C-$N" };
	push @bigram_lines, "J=$edge_num\t"."S=$node_curr\t"."E=$LigR\t"."l=$prob_hash{$key}"; $edge_num+=1;

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


#========================================================
# Create labels of all words for HResults
# "*/ABC_M1_t01.lab"
# A
# B
# C
#========================================================
my $dataDir = "$data_dir/data_NPNV";
unless (-d $dataDir) { die "$dataDir does not exist"; }
my @files = glob($dataDir."/*.htk");
open  REF_MLF, ">$refMlf" or die $!;
print REF_MLF "#!MLF!#\n";
foreach my $file (@files)
{
    $file =~ m/\/([A-Z]+)_(.*).htk/;
    my $w = $1;
    my @chars = split(undef, $w);

    print REF_MLF "\"*/$1_$2.lab\"\n";
    foreach my $i (0..scalar(@chars)-2)
    {
	print REF_MLF $chars[$i]."\n";
	#print REF_MLF $chars[$i]."-".$chars[$i+1]."\n"; # depends on wdnet, lig is not output in HVite	
    }
    print REF_MLF $chars[-1]."\n.\n";
}

close REF_MLF;
print "generate $refMlf\n";
