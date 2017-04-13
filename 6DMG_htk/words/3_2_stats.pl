#!/usr/bin/perl
# Mingyu @ May 6 2013
# Summarize the results of LeaveOneOut (3_0_train_lig_single.pl for all dTypes)

use strict;
use Math::NumberCruncher;

## [Mingyu]: Uncomment to use the full sets of data types (need to export them from
##           6DMG_loader first!!)
#my @dTypes = ("NPNV", "NP2DNV2D", "NANWNO", "NPNVNONANW", "NP2DNV2DNONANW");
my @dTypes = ("NPNV");

my @ligModels = ("iso");

## [Mingyu]: Uncomment to use the full sets of users
#my @usrs = ("A1", "C1", "C2", "C3", "C4", "E1", "G1", "G2", "G3", "I1",
#	    "I2", "I3", "J1", "J3", "L1", "M1", "S1", "U1", "Y1", "Y3",
#	    "Z1", "Z2");
my @usrs = ("A1", "C1", "C2");

foreach my $ligModel (@ligModels)
{
    #-----------------------------------------------------------
    # 1. Parse the recognition logs
    #-----------------------------------------------------------
    my @err_cnt = ();
    my $dtypeIdx = 0;
    foreach my $dtype (@dTypes)
    {
	foreach my $u (@usrs)
	{
	    my $file = "char_lig/$dtype/LeaveOneOut/iso/log_$u.txt";
	    open RECOG, $file or die "log.txt of $dtype, $u doesn't exist";

	    LOOP:while( my $line = <RECOG>)
	    {
		if ($line =~ /^SENT:/)
		{
		    if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/)
		    {
			push @{$err_cnt[$dtypeIdx]}, $2;
		    }
		    last LOOP;
		}
	    }
	}
	$dtypeIdx +=1;
    }

    #-----------------------------------------------------------
    # 2. Output the recognition results
    #-----------------------------------------------------------
    open LOG, ">res_leaveOneOut_$ligModel.txt" or die $!;
    print LOG "\t\t";
    foreach my $u (@usrs)
    {
	print LOG "$u  ";
    }
    print LOG "avg     std\n";
    print LOG "----------------------------------------------------------";
    print LOG "---------------------------------------------------------\n";
    my @avgs = ();
    my @stds = ();

    foreach my $dIdx (0..scalar(@dTypes)-1)
    {
	if (length($dTypes[$dIdx])<8){
	    print LOG "$dTypes[$dIdx]\t\t";
	}
	else{
	    print LOG "$dTypes[$dIdx]\t";
	}

	my @err = ();
	foreach my $uIdx (0..scalar(@usrs)-1)
	{
	    print LOG sprintf("%2d  ", $err_cnt[$dIdx][$uIdx]);
	    push(@err, $err_cnt[$dIdx][$uIdx]);
	}

	my $avg = Math::NumberCruncher::Mean(\@err);
	my $std = Math::NumberCruncher::StandardDeviation(\@err);
	push(@avgs, $avg);
	push(@stds, $std);
	print LOG sprintf("%5.3f  %5.3f\n", $avg, $std);
    }
    print LOG "----------------------------------------------------------";
    print LOG "---------------------------------------------------------\n";


    print LOG "\t\tWord error rate (in \%)\n";
    print LOG "---------------------------------------------------------\n";

    my $N = 200; # each subject writes 200 words
    foreach my $dIdx (0..scalar(@dTypes)-1)
    {
	if (length($dTypes[$dIdx])<8){
	    print LOG "$dTypes[$dIdx]\t\t";
	}
	else{
	    print LOG "$dTypes[$dIdx]\t";
	}

	print LOG sprintf("%5.3f (%5.3f)\n", $avgs[$dIdx]/$N*100, $stds[$dIdx]/$N*100);
    }
    close LOG;
}
