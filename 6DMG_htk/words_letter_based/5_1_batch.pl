#!/usr/bin/perl
# Mingyu @ Mar 8 2013 [text on extension M1 1k words]
# A script to launch all the simulations
# Note: run 0_generate_share, 1_batch, and 2_batch first!

use strict;
use Parallel::ForkManager;

my $data_dir;
if ($#ARGV != 0) 
{
    print "usage: batch.pl [data_dir]\n";
    print " [data_dir]: the base path to the \$datatype folder\n";
}
else
{
    $data_dir = $ARGV[0];
}

#my @dTypes = ("NPNV", "NANWNO", "NPNVNONANW", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes
foreach my $dtype (@dTypes)
{
    for my $voc ('1k', '1kf', '100k')
    {
	$pm->start and next;
	#========================================================
        # nbest is 5 (hardcoded in script 5_0_ext_bigram_nbest.pl)
        # bigram with lmscale = 15.0,
        # voc = 1k:   bigram estimated from 40-word vocabulary w/  backoff
        #       1kf:  bigram estimated from 40-word vocabulary w/o backoff
        #       100k: bigram estimated from 100k-word vocabulary

        # tree0
	print "pid($$)\t 5_0_ext_bigram_nbest $data_dir $dtype 0 $voc\n";
	system("perl 5_0_ext_bigram_nbest.pl $data_dir $dtype 0 $voc");

        # tree 1
	print "pid($$)\t 5_0_ext_bigram_nbest $data_dir $dtype 1 $voc\n";
	system("perl 5_0_ext_bigram_nbest.pl $data_dir $dtype 1 $voc");
	#========================================================
	$pm->finish;
    }    
}
$pm->wait_all_children;
