#!/usr/bin/perl
# Mingyu @ Apr 23 2013
# A script to launch all 3_viterbi_bigram_nbest
use strict;

my @dTypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#	    "Z2", "K1", "T2", "M3", "J4",
#	    "D1", "W1", "T3");
my @usrs = ("M1", "C1");

my @vocs = ("100", "100f", "1k", "1kf");
my @detOpts = ("det", "merge", "gt");

use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes

foreach my $dType (@dTypes) {
    foreach my $u (@usrs) {
        $pm->start and next;
        foreach my $detOpt (@detOpts) {
            foreach my $tree (0..1) {
                foreach my $voc (@vocs) {
                    #========================================================
                    #------ LeaveOneOut w/ N-Best
                    # (N=5 hardcoded in 3_0_viterbi_bigram_nbest)------
                    print "pid($$)\t3_0_viterbi_bigram_nbest.pl $dType $tree $u $voc $detOpt\n";
                    system("perl 3_0_viterbi_bigram_nbest.pl $dType $tree $u $voc $detOpt");
                    #========================================================
                }
            }
        }
        $pm->finish;
    }
}
$pm->wait_all_children;
