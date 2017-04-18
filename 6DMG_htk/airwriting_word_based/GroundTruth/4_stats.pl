#!/usr/bin/perl
# Mingyu @ Jun 4 2013
# Summarize the results of 3_train_HMM_single

use strict;
use Statistics::Basic qw(:all nofill);

my @dTypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#	    "Z2", "K1", "T2", "M3", "J4",
#	    "D1", "W1", "T3");
my @usrs = ("M1", "C1");

## Get the stats of the recognition results on the testing set of
#  ground-truth airwriting segments
# [NOTE] We simply skip the viterbi decoding on the training set in
#        3_0_train_HMM_single.pl
open(LOG_FILE, ">res_truth.txt");
foreach my $dtype (@dTypes)
{
    my @word_err = ([],[]); # trn, tst
    my @word_cnt = ([],[]);
    my @word_err_sum = (0,0);
    my @word_cnt_sum = (0,0);

    foreach my $u (@usrs)
    {
	my $file = "char_lig/$dtype/$u/log.txt";
	open FILE, $file or die $!;
	while (my $line = <FILE>)
	{
	    if ($line =~ /^  Rec :/)
	    {
		my $idx = 0; # trn
		if    ($line =~ /tst.mlf$/){    $idx = 1; } # tst 
		
   	        INNER:while ($line = <FILE>)
		{
		    if ($line =~ /^SENT:/){
			if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/){
			    push @{$word_err[$idx]}, $2;
			    push @{$word_cnt[$idx]}, $3;
			    last INNER;
			}
       
		    }
		}
	    }
	}
	close FILE;
    }
    print LOG_FILE "[$dtype]:\n";
    print LOG_FILE "\ttrn\ttst\n";
    foreach my $i (0..scalar(@usrs)-1)
    {
	my $str = sprintf("%s\t  -  \t%5.2f\n", $usrs[$i],
			  #$word_err[0][$i]/$word_cnt[0][$i]*100,
			  $word_err[1][$i]/$word_cnt[1][$i]*100);
	print LOG_FILE $str;
			  
	$word_err_sum[1] += $word_err[1][$i];	
	$word_cnt_sum[1] += $word_cnt[1][$i];	
    }

    #my $word_avg_0 = $word_err_sum[0]/$word_cnt_sum[0]*100; # trn
    my $word_avg_1 = $word_err_sum[1]/$word_cnt_sum[1]*100; # tst

    print LOG_FILE sprintf("avg:\t  -  \t%5.2f\n", $word_avg_1);
    print LOG_FILE "\n\n";
}
