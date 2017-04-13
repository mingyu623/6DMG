#!/usr/bin/perl
# Mingyu @ May 6 2013
# A script to launch all the simulations (scability on 1k-word vocab)
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
#my @dTypes = ("NPNV", "NP2DNV2D", "NANWNO", "NPNVNONANW", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

## [Mingyu]: iso ligModel performs the best
#my @ligModels = ("flat", "tie", "iso");
my @ligModels = ("iso");

use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes)
{
    foreach my $ligModel (@ligModels)
    {
	$pm->start and next;
	#========================================================
	#------ Extension Vocabulary------
	print "pid($$)\t4_0_train_lig_single.pl $data_dir $dType $ligModel\n";
	system("perl 4_0_train_lig_single.pl $data_dir $dType $ligModel");
	#========================================================
	$pm->finish;
    }
}
$pm->wait_all_children;
