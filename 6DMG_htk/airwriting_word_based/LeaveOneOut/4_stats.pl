#!/usr/bin/perl
# Mingyu @ Apr 26 2013
# Summarize the results of 3_train_HMM_single

use strict;
use Statistics::Basic qw(:all nofill);

my @dTypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#	    "Z2", "K1", "T2", "M3", "J4",
#	    "D1", "W1", "T3");
my @usrs = ("M1", "C1");

## Get the stats of the recognition results on the training set
open(LOG_FILE, ">res_train.txt");
foreach my $dtype (@dTypes)
{
    my @word_err = ([]);
    my @word_cnt = ([]);
    my @word_err_sum = (0);
    my @word_cnt_sum = (0);

    foreach my $u (@usrs)
    {
	my $file = "char_lig/$dtype/$u/log.txt";
	open FILE, $file or die $!;
	while (my $line = <FILE>)
	{
	    if ($line =~ /^  Rec :/)
	    {
		my $idx = 0; # trn
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
    print LOG_FILE "\ttrn\n";
    foreach my $i (0..scalar(@usrs)-1)
    {
        my $str = sprintf("%s\t%5.2f\n", $usrs[$i],
                          $word_err[0][$i]/$word_cnt[0][$i]*100);
	print LOG_FILE $str;

	foreach my $j (0..2)
	{
	    $word_err_sum[$j] += $word_err[$j][$i];	
	    $word_cnt_sum[$j] += $word_cnt[$j][$i];
	}
    }

    my $word_avg_0 = $word_err_sum[0]/$word_cnt_sum[0]*100; # trn
    print LOG_FILE sprintf("avg:\t%5.2f\n", $word_avg_0);
    print LOG_FILE "\n\n";
}

## Get the stats of the recognition results on the merged detected testing sets.
open(LOG, ">res_merge.txt") or die $!;
foreach my $dtype (@dTypes)
{
    # precise, imprecise, preciseOOV, impreciseOOV, FA
    my @word_err = ([],[],[],[],[]);
    my @word_cnt = ([],[],[],[],[]);
    my @word_err_sum = (0,0,0,0,0);
    my @word_cnt_sum = (0,0,0,0,0);

    foreach my $u (@usrs)
    {
	my @hits = (0,0,0,0,0); # flags to indicate if certain HResult is executed

	my $file = "char_lig/$dtype/$u/log_merge_det.txt";
	open FILE, $file or die $!;
	while (my $line = <FILE>)
	{
	    if ($line =~ /^  Rec :/)
	    {
		my $idx = 0;
		if    ($line =~ /tst.mlf$/)         { $idx = 0; } # precise
		elsif ($line =~ /tstOOV.mlf$/)      { $idx = 1; } # precise OOV
		elsif ($line =~ /imprecise.mlf$/)   { $idx = 2; } # imprecise
		elsif ($line =~ /impreciseOOV.mlf$/){ $idx = 3; } # imprecise OOV
		elsif ($line =~ /FA.mlf$/)          { $idx = 4; } # FA
		else  { die "! Fail to parse log !\n"; }
		$hits[$idx] = 1;
		
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

	for my $i (0..4)
	{
	    if ($hits[$i] eq 0) # "that" HResult is not executed: cnt=err=0
	    {
		push @{$word_err[$i]}, 0;
		push @{$word_cnt[$i]}, 0;
	    }
	}
    }

    print LOG "[$dtype]\n";
    print LOG "\tprecise\t\timprecise\tFA\tprecise\timprecise\n";
    print LOG "\t\t(oov)\t\t(oov)\t\tavg\tavg\n";
    print LOG "-------------------------------------------------------------\n";
    foreach my $i (0..scalar(@usrs)-1)
    {
	print LOG sprintf("%s\t", $usrs[$i]);
	for my $j (0..4)
	{
	    print LOG sprintf("%2d/%3d\t", $word_err[$j][$i],$word_cnt[$j][$i]);
	    $word_err_sum[$j] += $word_err[$j][$i];
	    $word_cnt_sum[$j] += $word_cnt[$j][$i];
	}
	my $precise_err_rate   = ($word_err[0][$i]+$word_err[1][$i])/($word_cnt[0][$i]+$word_cnt[1][$i])*100;
	print LOG sprintf ("%5.2f\t", $precise_err_rate);	       

	if ($word_cnt[2][$i] + $word_cnt[3][$i] > 0){
	    my $imprecise_err_rate = ($word_err[2][$i]+$word_err[3][$i])/($word_cnt[2][$i]+$word_cnt[3][$i])*100;
	    print LOG sprintf("%5.2f\n", $imprecise_err_rate);
	}else{
	    print LOG sprintf("    -\n");
	}
    }

    my $word_avg_0 = $word_err_sum[0]/$word_cnt_sum[0]*100; # precise
    my $word_avg_1 = $word_err_sum[1]/$word_cnt_sum[1]*100; # precise OOV
    my $word_avg_2 = $word_err_sum[2]/$word_cnt_sum[2]*100; # precise OOV
    my $word_avg_3 = $word_err_sum[3]/$word_cnt_sum[3]*100; # imprecise OOV
    my $word_avg_4; #x FA
    eval {
        $word_avg_4 = $word_err_sum[4]/$word_cnt_sum[4]*100;
    } or do {
        $word_avg_4 = 0;
    };

    my $precise_word_avg   = ($word_err_sum[0]+$word_err_sum[1])/($word_cnt_sum[0]+$word_cnt_sum[1])*100;
    my $imprecise_word_avg = ($word_err_sum[2]+$word_err_sum[3])/($word_cnt_sum[2]+$word_cnt_sum[3])*100;
    my $precise_word_cnt   = $word_cnt_sum[0]+$word_cnt_sum[1];
    my $imprecise_word_cnt = $word_cnt_sum[2]+$word_cnt_sum[3];
    my $all_word_err = ($word_err_sum[0]+$word_err_sum[1]+$word_err_sum[2]+$word_err_sum[3]+$word_err_sum[4]);
    my $all_word_cnt = ($word_cnt_sum[0]+$word_cnt_sum[1]+$word_cnt_sum[2]+$word_cnt_sum[3]);

    print LOG "-------------------------------------------------------------\n";
    print LOG sprintf("(cnt):\t%5d\t%5d\t%5d\t%5d\t%5d\n",
		      $word_cnt_sum[0],$word_cnt_sum[1],$word_cnt_sum[2],$word_cnt_sum[3],$word_cnt_sum[4]);
    print LOG "-------------------------------------------------------------\n";
    print LOG sprintf("(word):\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n",
		      $word_avg_0, $word_avg_1, $word_avg_2, $word_avg_3, $word_avg_4,
		      $precise_word_avg, $imprecise_word_avg);	   
    print LOG "-------------------------------------------------------------\n";
    print LOG sprintf("precise   detection: %5.2f\%\n", $precise_word_cnt/$all_word_cnt*100);
    print LOG sprintf("imprecise detection: %5.2f\%\n", $imprecise_word_cnt/$all_word_cnt*100);
    print LOG sprintf("word error rate:     %5.2f\%\n", $all_word_err/$all_word_cnt*100);
    print LOG "\n\n";
}
