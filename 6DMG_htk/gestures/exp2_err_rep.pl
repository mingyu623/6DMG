#!/usr/bin/perl
# Mingyu Chen @ Sep 03 2011
# User Independent case
# This script reports the runs that fails to complete (errXXX.txt exists)
# It also attempts to fix the "abnormal early termination problem"
# Run exp2_err_rep before exp2_res & exp2_res_rep;

use File::stat;

if ($#ARGV < 1)
{ 
    print "usage: exp2_err_rep [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

$data_dir = $ARGV[0];
@myDataTypes = @ARGV[1..$#ARGV];

#-------------------------------------------------------------------------
# Search for "errXXX.txt"
#-------------------------------------------------------------------------
open F_err, ">exp2/err_rep.txt" or die $!;

my $err_cnt = 0;
foreach my $dtype (@myDataTypes)
{
    my @errList = glob("exp2/$dtype/err*.txt");
    foreach my $run (@errList)
    {
	my $true_err = 0;
	do {
	    if (stat("$run")->size==0) # abnormal early termination
	    {
		$run =~ /err(.*).txt/;
		print "REDO exp2_single.pl $dtype $1 $data_dir\n";
		system("perl exp2_single.pl $dtype $1 $data_dir");
	    }
	    else # a real Error occurs at exp2_single.pl
	    {
		$true_err = 1;
		$err_cnt += 1;
		print F_err "$run\n";		
	    }
	} while(-e $run && $true_err==0);
    }
}

print F_err "Total: $err_cnt errors\n";
close F_err;
exit;
