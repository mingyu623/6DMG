#!/usr/bin/perl
# Mingyu @ Mar 7 2013 [ Leave-One-Out]
# A script to launch all the simulations
# Note: need to run 0_generate_share first!

use strict;
use Parallel::ForkManager;

my $data_dir;
if ($#ARGV !=0)
{
    print "usage: batch.pl [data_dir]\n";
    print " [data_dir]: the base path to the \$datatype folder\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];
}


#my @dTypes = ("NPNV", "NANWNO", "NPNVNONANW", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

#my @usrs = ("A1", "C1", "C2", "C3", "C4",
#	    "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1",
#	    "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("A1", "C1");


my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes
foreach my $dtype (@dTypes)
{
    foreach my $u (@usrs)
    {
	$pm->start and next;
	#========================================================
	print "pid($$)\t 1_0_prep_trn_scp_mlf_hmmdefs $data_dir $dtype $u\n";
	system("perl 1_0_prep_trn_scp_mlf_hmmdefs.pl $data_dir $dtype $u");
	#========================================================
	$pm->finish;
    }
}
$pm->wait_all_children;
