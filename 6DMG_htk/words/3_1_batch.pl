#!/usr/bin/perl
# Mingyu @ May 6 2013
# A script to launch all the simulations (leave-one-out)
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

## [Mingyu]: iso ligModel performs the best
#my @ligModels = ("flat", "tie", "iso");
my @ligModels = ("iso");

## [Mingyu]: Uncomment to use the full sets of users
#my @usrs = ("A1", "C1", "C2", "C3", "C4", "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1", "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("A1", "C1", "C2");

use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes)
{
    foreach my $ligModel (@ligModels)
    {
	foreach my $u (@usrs)
	{
	    $pm->start and next;
	    #========================================================
	    #------ LeaveOneOut ------
	    print "pid($$)\t3_0_train_lig_single.pl $data_dir $dType $u $ligModel\n";
	    system("perl 3_0_train_lig_single.pl $data_dir $dType $u $ligModel");
	    #========================================================
	    $pm->finish;
	}
    }
}
$pm->wait_all_children;
