#!/usr/bin/perl
# Mingyu @ Mar 6 2013
# A script to launch all the simulations
use strict;

my @dTypes = ("NP", "NV", "NA", "NO", "NW", "NPNVNONANW", "NPNV", "NANWNO", 
	      "NP2D", "NV2D", "NP2DNV2D", "NP2DNV2DNONANW");

my @usrs = ("A1", "C1", "C2", "C3", "C4", "E1", "G1", "G2", "G3", "I1",
	    "I2", "I3", "J1", "J3", "L1", "M1", "S1", "U1", "Y1", "Y3",
	    "Z1", "Z2");
#my @usrs = ("M1");

use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes)
{
    foreach my $u (@usrs)
    {
	$pm->start and next;
	#========================================================
	#------ LeaveOneOut ------
	print "perl 1_build_iso_char_hmm_single.pl $u $dType\n";
	system("perl 1_build_iso_char_hmm_single.pl $u $dType");       
	#========================================================
	$pm->finish;    
    }
}
$pm->wait_all_children;
