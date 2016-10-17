#!/usr/bin/perl
# Mingyu @ Jul 08 2012
# User Independent case (Leave-one-out)
# This script calculate the mean and std of results from exp3.pl
use Math::NumberCruncher;

opendir($dh, "exp3");
my @myDataTypes = grep(-d "exp3/$_" &&  ! /^\.{1,2}$/, readdir($dh));

#-------------------------------------------------------------------------
# 1. Locate the results mlf
# 2. Run HResults only on the tst set (faster)
#-------------------------------------------------------------------------
open (REGOUT, ">&STDOUT") or die "Can't open REGOUT: $!\n";
my $gMLF = "mlf/gest.mlf";

foreach my $dtype (@myDataTypes)
{
    print REGOUT "HResults of $dtype\n";
    @runs = glob("exp3/$dtype/log*.txt");
    foreach my $run (@runs)
    {
	$run =~ /log(.*).txt/;
	$runStr = $1;
	unless (-e "exp3/$dtype/err$runStr.txt")
	{
	    # exp3_single finishes correctly
	    #print REGOUT "Collect results of $dtype run $runStr\n";
	    my $hmmlist = "exp3/$dtype/run001/gestList";
	    my $mlf = "exp3/$dtype/run$runStr/tst.mlf";
	    open(STDOUT, ">exp3/$dtype/run$runStr/hresults_tst.txt");
	    system("HResults -A -T 1 -p -I $gMLF $hmmlist $mlf");
	    close STDOUT;
	}
    }
}

open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";

#-------------------------------------------------------------------------
# 3. Calculate average and std of all results of exp3
#-------------------------------------------------------------------------
open F_stats, ">exp3/tst_stats.txt";
foreach my $dtype (@myDataTypes)
{
    print "Calculate avg & std of exp3 of $dtype\n";
    @runs = glob("exp3/$dtype/log*.txt");
    my @acc_array=();
    my @acc_array_L = ();
    my @acc_array_R = ();
    foreach my $run (@runs)
    {
	$run =~ /log(.*).txt/;
	$runStr = $1;
	my $file = "exp3/$dtype/run$runStr/hresults_tst.txt";
	if (-e $file)
	{
	    open F_read, "<$file" or die $!;
	    my @lines = <F_read>;
	    for (@lines)
	    {
		if ($_ =~ /^WORD: %Corr=([\d]+\.[\d]+),/)
		{		    
		    push(@acc_array, $1);
		    if ($runStr < 22) # Right-hand
		    {
			push(@acc_array_R, $1);
		    }
		    else
		    {
			push(@acc_array_L, $1);
		    }
		}
	    }
	}
    }

    my $avg_acc = Math::NumberCruncher::Mean(\@acc_array);;
    my $std_acc = Math::NumberCruncher::StandardDeviation(\@acc_array);
    my $avg_acc_R = Math::NumberCruncher::Mean(\@acc_array_R);;
    my $std_acc_R = Math::NumberCruncher::StandardDeviation(\@acc_array_R);
    my $avg_acc_L = Math::NumberCruncher::Mean(\@acc_array_L);;
    my $std_acc_L = Math::NumberCruncher::StandardDeviation(\@acc_array_L);

    printf F_stats "$dtype\n";

    printf F_stats "All: %2.2f\t%2.2f\n",   $avg_acc, $std_acc;
    printf F_stats "R:   %2.2f\t%2.2f\n",   $avg_acc_R, $std_acc_R;
    printf F_stats "L:   %2.2f\t%2.2f\n\n", $avg_acc_L, $std_acc_L;
}

close F_stats;
close REGOUT;
