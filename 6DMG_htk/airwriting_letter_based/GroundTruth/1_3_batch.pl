#!/usr/bin/perl
# Mingyu @ Apr 23 2013
# A script to launch all 1_1_prep_trn_scp_hmmdef_single
#                        1_2_prep_tst_scp_single
use strict;

my @dTypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#           "Z2", "K1", "T2", "M3", "J4",
#           "D1", "W1", "T3");
my @usrs = ("M1", "C1");


use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes)
{
    print "1_0_init_fil.pl $dType\n";
    system("perl ../LeaveOneOut/1_0_init_fil.pl $dType");

    foreach my $u (@usrs)
    {
        $pm->start and next;
        #========================================================
        #------ LeaveOneOut training on GROUND TRUTH  ------
        print  "pid($$)\t1_1_prep_trn_scp_hmmdef_single.pl $dType $u\n";
        system("perl ../LeaveOneOut/1_1_prep_trn_scp_hmmdef_single.pl $dType $u");

        #------ LeaveOneOut testing  on GROUND TRUTH  ------
        print  "pid($$)\t1_2_prep_tst_scp_single.pl $dType $u\n";
        system("perl 1_2_prep_tst_scp_single.pl $dType $u");
        #========================================================
        $pm->finish;
    }
}
$pm->wait_all_children;
