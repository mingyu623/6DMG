#!/usr/bin/perl
# Mingyu Chen @ Sep 02 2011
# User Dependent case
# This script reports the runs that fails to complete (errXXX.txt exists)
# It also attempts to fix the "abnormal early termination problem"
# Run exp1_err_rep before exp1_res & exp1_avg_res;

use File::stat;

if ($#ARGV < 1)
{ 
    print "usage: exp1_err_rep [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

$data_dir = $ARGV[0];
@myDataTypes = @ARGV[1..$#ARGV];

@userR = ("B1", "B2", "C1", "C2", "D1", "J1", "J2", "J3", "J5", "M1",
          "M2", "M3", "R2", "S1", "S2", "T1", "T2", "U1", "W1", "Y1",
          "Y3");

#-------------------------------------------------------------------------
# Search for "errXXX.txt"
#-------------------------------------------------------------------------
open F_err, ">exp1/err_rep.txt" or die $!;

my $err_cnt = 0;

foreach my $usr (@userR)
{
    foreach my $dtype (@myDataTypes)
    {
	my @errList = glob("exp1/$usr/$dtype/err*.txt");
	foreach my $run (@errList)
	{
	    my $true_err = 0;
	    do {	   
		if (stat("$run")->size==0) # abnormal early termination
		{
		    $run =~ /err(.*).txt/;
		    print ("REDO exp1_single.pl $usr $dtype $1 $data_dir\n");
		    system("perl exp1_single.pl $usr $dtype $1 $data_dir");
		}
		else # a real Error occurs at exp1_single.pl
		{
		    $true_err = 1;
		    $err_cnt += 1;
		    print F_err "$run\n";
		}
	    } while(-e $run && $true_err==0);
	}
    }
}

print F_err "Total: $err_cnt errors\n";
close F_err;
exit;
