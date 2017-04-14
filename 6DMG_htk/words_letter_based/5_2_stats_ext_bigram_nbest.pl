#!/usr/bin/perl
# Mingyu @ May 9 2013
# Summarize the results of 5_1_batch.pl

use strict;
use File::Path qw(make_path);
use Math::NumberCruncher;

#my @dTypes = ("NPNV", "NANWNO", "NPNVNONANW", "NP2DNV2D", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

unless (-d "results") { make_path "results"; }
foreach my $voc ("1k", "1kf", "100k")
{
    foreach my $nbest (1, 2, 3, 5)
    {
	open LOG, ">results/results_ext_bigram_$voc\_$nbest"."best.txt" or die $!;
	foreach my $dtype (@dTypes)
	{
	    my @word_err_cnt  = ([],[]);
	    my @word_err_rate = ([],[]);
	    my @char_err_rate = ([],[]);
	    foreach my $t (0..1)
	    {	
		my $path = "products/$dtype/M1/tree$t";
		open LOG_TREE, "$path/log_dec_ext_bigram_$voc\_nbest.log" or die "$dtype tree$t $voc";

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
		close LOG_TREE;
	    }
	    
	    print LOG "[$dtype]\n";
	    print LOG "\ttree0\ttree1\n";
	    my $str = sprintf("%s\t%3.2f\t%3.2f\n", "M1", $word_err_cnt[0][0], $word_err_cnt[1][0]);
	    print LOG $str;
	    
	    print LOG "(WER \%)\n";
	    print LOG sprintf("avg:\t%5.2f\t%5.2f\n", $word_err_rate[0][0], $word_err_rate[1][0]);
	    
	    print LOG "(CER \%)\n";
	    print LOG sprintf("avg:\t%5.2f\t%5.2f\n", $char_err_rate[0][0], $char_err_rate[1][0]);
	    print LOG "\n\n";
	}
	close LOG;
    }
}
