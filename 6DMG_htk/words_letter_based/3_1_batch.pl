#!/usr/bin/perl
# Mingyu @ Mar 7 2013 [ Leave-One-Out]
# A script to launch all the simulations
# Note: run 0_generate_share, 1_batch, and 2_batch first!

use strict;
use Parallel::ForkManager;

#my @dTypes = ("NPNV", "NANWNO", "NPNVNONANW", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

#my @usrs = ("A1", "C1", "C2", "C3", "C4",
#	    "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1",
#	    "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("A1", "C1");


# Check if we have the required bigram wdnet
unless (-f "share/wdnet_bigram_40f") {
    system("perl 0_1_generate_wdnet_bigram.pl 40 0");
}
unless (-f "share/wdnet_bigram_40") {
    system("perl 0_1_generate_wdnet_bigram.pl 40 1");
}

my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes
foreach my $dtype (@dTypes)
{
    foreach my $u (@usrs)
    {	
	$pm->start and next;
	#========================================================
        # nbest is 5 (hardcoded in script 3_0_viterbi_bigram_nbest.pl)
        # bigram with lmscale = 15.0,
        # voc = na:  no bigram
        #       40:  bigram estimated from 40-word vocabulary w/  backoff
        #       40f: bigram estimated from 40-word vocabulary w/o backoff
	for my $voc ('na', '40', '40f')
	{
            print "pid($$)\t 3_0_viterbi_bigram_nbest $dtype 0 $u $voc\n";
            system("perl 3_0_viterbi_bigram_nbest.pl $dtype 0 $u $voc");
	    
            print "pid($$)\t 3_0_viterbi_bigram_nbest $dtype 1 $u $voc\n";
            system("perl 3_0_viterbi_bigram_nbest.pl $dtype 1 $u $voc");
        }
	#========================================================
	$pm->finish;
    }    
}
$pm->wait_all_children;
