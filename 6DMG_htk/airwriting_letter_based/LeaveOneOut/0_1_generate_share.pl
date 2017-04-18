#!/usr/bin/perl
# Mingyu @ Apr 19 2013
# Generate "$dtype" invariant shared files

use strict;
use File::Path qw(make_path);

my $outDir   = "share";
my $wdnet    = "$outDir/wdnet";
my $refMlf   = "$outDir/word_ref.mlf";
unless (-d $outDir){ make_path $outDir; }


#========================================================
# Call "0_1_generate_wdnet_bigram.pl" to generate wdnet_bigram
# Two vocabs with & without backoff
#========================================================
foreach my $voc ("100", "100f", "1k", "1kf")
{
    system("perl 0_0_generate_wdnet_bigram.pl $voc");
}



#========================================================
# Create labels of all words for HResults
# This ref.mlf is not used for the "merged" case
# For letter-based decoding, use the recordings instead of "detected" word segs
# "*/M1_ABC.lab"
# A
# B
# C
#========================================================
my $dataDir = "../../../data_htk/airwriting_spot/truth/data_NP2DuvNV2D";
unless (-d $dataDir) {
    die "dataDir doesn't exist at $dataDir!\n";
}
my @files = glob($dataDir."/*.htk");
open  REF_MLF, ">$refMlf" or die $!;
print REF_MLF "#!MLF!#\n";
foreach my $file (@files)
{
    $file =~ m/\/([A-Z][0-9])_([A-Z]+).htk/;
    my $w = $2;
    my @chars = split(undef, $w);

    print REF_MLF "\"*/$1_$2.lab\"\n";
    foreach my $i (0..scalar(@chars)-2)
    {
	print REF_MLF $chars[$i]."\n";
        # depends on wdnet, lig is not output in HVite
	#print REF_MLF $chars[$i]."-".$chars[$i+1]."\n";
    }
    print REF_MLF $chars[-1]."\n.\n";
}

close REF_MLF;
print "generate $refMlf\n";
