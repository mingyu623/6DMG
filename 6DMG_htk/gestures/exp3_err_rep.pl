#!/usr/bin/perl
# Mingyu Chen @ Jul 02 2011
# User Independent case (leave-one-out)
# This script reports the runs that fails to complete (errXXX.txt exists)
# It also attempts to fix the "abnormal early termination problem"
# Run exp3_err_rep before exp3_res & exp3_all_res;

use File::stat;

if ($#ARGV < 1)
{ 
    print "usage: exp3_err_rep [data_dir] [datatype1] .. [datatypen]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}

$data_dir = $ARGV[0];
@myDataTypes = @ARGV[1..$#ARGV];

#-------------------------------------------------------------------------
# Search for "errXXX.txt"
#-------------------------------------------------------------------------
open F_err, ">exp3/err_rep.txt" or die $!;

my $err_cnt = 0;
foreach my $dtype (@myDataTypes)
{
    my @errList = glob("exp3/$dtype/err*.txt");
    foreach my $run (@errList)
    {
	my $true_err = 0;
	my $attempt  = 0;
	do {
	    if ((stat("$run")->size==0) && ($attempt<2)) # abnormal early termination
	    {
		$attempt += 1;
		$run =~ /err(.*).txt/;
		print "REDO exp3_single.pl $dtype $1 $data_dir(size 0), attempt $attempt\n";
		system("perl exp3_single.pl $dtype $1 $data_dir");
	    }
	    else # a real Error occurs at exp3_single.pl
	    {
		open F_read, "<$run" or die $!;
		my $first_line = <F_read>;
		if (($first_line =~ /^Error: Error:/) && ($attempt<2))
		{
                    # unepected Windows cmd problem
		    $attempt += 1;
		    $run =~ /err(.*).txt/;
		    print "REDO exp3_single.pl $dtype $1 $data_dir (unknown error)".
                        ", attempt $attempt\n";
		    system("perl exp3_single.pl $dtype $1 $data_dir");
		}
		else
		{
		    $true_err = 1;
		    $err_cnt += 1;
		    print F_err "$run\n";
		}
	    }
	}while(-e $run && $true_err==0);
    }
}

print F_err "Total: $err_cnt errors\n";
close F_err;
print "Total: $err_cnt errors\n";

exit;
