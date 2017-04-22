#!/usr/bin/perl
# Mingyu @ Apr 23 2013
# A script to launch
# 0) 1_0_init_fil
# 1) 1_1_prep_trn_scp_hmmdef_single
# 2) 1_2_prep_merge_tst_scp_single
# 3) 1_3_prep_det_tst_scp_single
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
    print "1_0_init_fil.pl $dType\n";
    system("perl 1_0_init_fil.pl $dType");
    foreach my $u (@usrs)
    {
	$pm->start and next;
	#========================================================
	#------ LeaveOneOut on CLEAN detection results ------
	print  "pid($$)\t1_1_prep_trn_scp_hmmdef_single.pl $dType $u\n";
	system("perl 1_1_prep_trn_scp_hmmdef_single.pl $dType $u");

	#------ LeaveOneOut on MERGE detection results ------
	print  "pid($$)\t1_2_prep_merge_tst_scp_single.pl $dType $u\n";
	system("perl 1_2_prep_merge_tst_scp_single.pl $dType $u");

	#--- LeaveOneOut on all detection results (w/o merge) ---
	print "pid($$)\t1_3_prep_det_tst_scp_single.pl $dType $u\n";
	system("perl 1_3_prep_det_tst_scp_single.pl $dType $u");

        #--- LeaveOneOut on ground-truth segments -----
        print "pid($$)\t1_4_prep_groundtruth_tst_scp_single.pl $dType $u\n";
        system("perl 1_4_prep_groundtruth_tst_scp_single.pl $dType $u");
	#========================================================
	$pm->finish;
    }
}
$pm->wait_all_children;
