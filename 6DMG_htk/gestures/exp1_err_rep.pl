#!/usr/bin/perl
# Mingyu Chen @ Sep 02 2011
# User Dependent case
# This script reports the runs that fails to complete (errXXX.txt exists)
# It also attempts to fix the "abnormal early termination problem"
# Run exp1_err_rep before exp1_res & exp1_avg_res;

use File::stat;

if ($#ARGV <0)
{ 
    print "usage: exp1_err_rep [datatype1] .. [datatypen]\n";
    exit;
}
@myDataTypes = @ARGV;

# check if the data types are valid
#@dataTypes = ("A", "AW", "P", "PO", "V", "VO");
#foreach my $my_dtype (@myDataTypes)
#{
#    my $valid = 0;
#    foreach my $dtype (@dataTypes)
#    {
#	if ($my_dtype eq $dtype) { $valid = 1; }
#    }
#    if ($valid==0)
#    {
#	print "invalid datatype $my_dtype\n";
#	exit;
#    }
#}

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
		    print ("REDO exp1_single.pl $usr $dtype $1\n");
		    system("perl exp1_single.pl $usr $dtype $1");
		}
		else # a real Error occurs at exp1_single.pl
		{
		    $true_err = 1;
		    $err_cnt += 1;
		    print F_err "$run\n";
		}
	    }while(-e $run && $true_err==0);
	}
    }
}

print F_err "Total: $err_cnt errors\n";
close F_err;
exit;
