#!/usr/bin/perl
# Mingyu @ Mar 11 2013
# Summarize the results of 3_1_batch

use strict;
use File::Path qw(make_path);
use Math::NumberCruncher;

#my @dTypes = ("NPNV", "NANWNO", "NPNVNONANW", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

#my @usrs = ("A1", "C1", "C2", "C3", "C4",
#	    "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1",
#	    "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("A1", "C1");

unless (-d "results") { make_path "results"; }

foreach my $bigram ("bigram_na", "bigram_40", "bigram_40f")
{
    foreach my $nbest (1, 2, 3, 5)
    {
	open LOG, ">results/results_$bigram"."_$nbest"."best.txt" or die $!;
	foreach my $dtype (@dTypes)
	{
	    my @word_err_cnt  = ([],[]);
	    my @word_err_rate = ([],[]);
	    my @char_err_rate = ([],[]);
	    foreach my $t (0..1)
	    {	
		foreach my $u (@usrs)
		{
		    my $path = "products/$dtype/$u/tree$t";
		    open LOG_TREE, "$path/log_dec_$bigram"."_nbest.log" or die "$dtype $u tree$t $bigram";
	       

		    OUTER:while( my $line = <LOG_TREE> )
		    {
			if ($line =~ /^HResults -A -d $nbest/)
			{
			    while ($line = <LOG_TREE>)
			    {
				if ($line =~ /^SENT:/){
				    if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/){
					push @{$word_err_cnt[$t]}, $2;
					push @{$word_err_rate[$t]}, $2/$3*100;
				    }		    
				}
				elsif ($line =~ /^WORD:/){
				    if ($line =~ /H=([\d]+), D=([\d]+), S=([\d]+), I=([\d]+), N=([\d]+)/){
					push @{$char_err_rate[$t]}, ($2+$3+$4)/$5*100;
					last OUTER;
				    }
				} 			    
			    }
			}
		    }		
		}
		close LOG_TREE;
	    }
	    
	    print LOG "[$dtype]\n";
	    print LOG "\ttree0\ttree1\n";
	    foreach my $i (0..scalar(@usrs)-1)
	    {
		my $str = sprintf("%s\t%3.2f\t%3.2f\n", $usrs[$i], $word_err_cnt[0][$i], $word_err_cnt[1][$i]);
		print LOG $str;
	    }
	    my $word0_avg = Math::NumberCruncher::Mean(\@{$word_err_rate[0]});
	    my $word0_std = Math::NumberCruncher::StandardDeviation(\@{$word_err_rate[0]});
	    my $char0_avg = Math::NumberCruncher::Mean(\@{$char_err_rate[0]});
	    my $char0_std = Math::NumberCruncher::StandardDeviation(\@{$char_err_rate[0]});
	    
	    my $word1_avg = Math::NumberCruncher::Mean(\@{$word_err_rate[1]});
	    my $word1_std = Math::NumberCruncher::StandardDeviation(\@{$word_err_rate[1]});
	    my $char1_avg = Math::NumberCruncher::Mean(\@{$char_err_rate[1]});
	    my $char1_std = Math::NumberCruncher::StandardDeviation(\@{$char_err_rate[1]});
	    
	    print LOG "(WER \%)\n";
	    print LOG sprintf("avg:\t%5.2f\t%5.2f\n", $word0_avg, $word1_avg);
	    print LOG sprintf("std:\t%5.2f\t%5.2f\n", $word0_std, $word1_std);
	    
	    print LOG "(CER \%)\n";
	    print LOG sprintf("avg:\t%5.2f\t%5.2f\n", $char0_avg, $char1_avg);
	    print LOG sprintf("std:\t%5.2f\t%5.2f\n", $char0_std, $char1_std);
	    print LOG "\n\n";
	}
	close LOG;
    }
}
