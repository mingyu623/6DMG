#!/usr/bin/perl
# Mingyu @ May 6 2013
# Summarize the results of Extension (4_0_train_lig_single.pl for all dTypes)

use strict;

my @dTypes = ("NPNV", "NP2DNV2D", "NANWNO", "NPNVNONANW", "NP2DNV2DNONANW");
my @ligModels = ("flat", "tie", "iso");

open LOG, ">res_extension.txt" or die $!;
print LOG "lig model->\t";
foreach (@ligModels)
{
    print LOG "     $_\t";
}
print LOG "\n";
print LOG "\t\tcnt\t WER(\%)\tcnt\t WER(\%)\tcnt\t WER(\%)\n";
print LOG "-------------------------------------------------------------------\n";

my $dIdx = 0;
foreach my $dtype (@dTypes)
{
    if (length($dTypes[$dIdx])<8){
	print LOG "$dTypes[$dIdx]\t\t";
    }
    else{
	print LOG "$dTypes[$dIdx]\t";
    }
    foreach my $ligModel (@ligModels)
    {
	my $file = "char_lig/$dtype/Extension/log_$ligModel.txt";
	if (-e $file)
	{
	    open RECOG, $file or die $!;
    	    LOOP:while (my $line = <RECOG>)
	    {
		if ($line =~ /recog\_tst\.mlf\n$/)
		{
		    while ($line = <RECOG>)
		    {
			if ($line =~ /^SENT:/){
			    if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/)
			    {
				print LOG sprintf("%2d\t%5.2f\t", $2, $2/$3*100);
			    }
			    last LOOP;
			}
		    }		    
		}
	    }
	    close RECOG;
	}
	else
	{
	    print LOG " -\t  -\t";
	}
    }
    print LOG "\n";
    $dIdx += 1;
}
close LOG;
