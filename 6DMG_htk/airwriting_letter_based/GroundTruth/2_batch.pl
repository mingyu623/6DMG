#!/usr/bin/perl
# Mingyu @ Apr 23 2013
# A script to launch all 2_0_make_tree & 2_1_make_subtree
use strict;

my @dTypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#	    "Z2", "K1", "T2", "M3", "J4",
#	    "D1", "W1", "T3");
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
	print  "pid($$)\t2_0_make_tree.pl $dType $u\n";
	system("perl ../LeaveOneOut/2_0_make_tree.pl $dType $u");

	print "pid($$)\t2_1_make_subtree.pl $dType $u\n";
	system("perl ../LeaveOneOut/2_1_make_subtree.pl $dType $u");
	#========================================================
	$pm->finish;
    }
}
$pm->wait_all_children;
