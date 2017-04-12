#!/usr/bin/perl
# Mingyu @ Mar 6 2013
# A script to launch all the simulations
use strict;

my $data_dir;
if ($#ARGV != 0)
{
    print "usage: batch [data_dir]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];  # the base path to the \$datatype folder
}

## [Mingyu]: Uncomment to use the full sets of data types (need to export them from
##           6DMG_loader first!!)
#my @dTypes = ("NP", "NV", "NA", "NO", "NW", "NPNVNONANW", "NPNV", "NANWNO",
#	      "NP2D", "NV2D", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

## [Mingyu]: Uncomment to use the full sets of users
#my @usrs = ("A1", "C1", "C2", "C3", "C4", "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1", "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("M1", "C1");

use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes)
{
    foreach my $u (@usrs)
    {
	$pm->start and next;
	#========================================================
	#------ LeaveOneOut ------
	print "perl 1_build_iso_char_hmm_single.pl $u $data_dir $dType\n";
	system("perl 1_build_iso_char_hmm_single.pl $u $data_dir $dType");
	#========================================================
	$pm->finish;
    }
}
$pm->wait_all_children;
