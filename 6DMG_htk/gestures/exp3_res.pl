#!/usr/bin/perl
# Mingyu @ Jul 01 2012
# User Independent case
# This script calculate the std of results from exp3_res.pl

if ($#ARGV <0)
{ 
    print "usage: exp3_res [datatype1] .. [datatypen]\n";
    exit;
}

@myDataTypes = @ARGV;

#-------------------------------------------------------------------------
# 1. Prepare the results scripts (trn, tst)_mlf.scp
#-------------------------------------------------------------------------
foreach my $dtype (@myDataTypes)
{
    print "Prepare the mlf scripts for $dtype\n";
    open F_trn_res, ">exp3/$dtype/trn_mlf.scp" or die $!;
    open F_tst_res, ">exp3/$dtype/tst_mlf.scp" or die $!;

    @runs = glob("exp3/$dtype/log*.txt");
    foreach my $run (@runs)
    {
	$run =~ /log(.*).txt/;
	$runStr = $1;
	unless (-e "exp3/$dtype/err$runStr.txt")
	{
	    # exp3_single finishes correctly
	    my $path = "exp3/$dtype/run$runStr";
	    my $trn_res = "$path/trn.mlf";
	    my $tst_res = "$path/tst.mlf";
	    print F_trn_res "$trn_res\n";
	    print F_tst_res "$tst_res\n";
	}
    }

    close F_trn_res;
    close F_tst_res;
}

#-------------------------------------------------------------------------
# 2. Collect the recognition results (HResults)
#-------------------------------------------------------------------------
use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes
my @list = ("trn", "tst");
my $gMLF = "mlf/gest.mlf";


open (REGOUT, ">&STDOUT") or die "Can't open REGOUT: $!\n";

foreach my $dtype (@myDataTypes)
{
    foreach my $tgt (@list)
    {
	$pm->start and next;
	#--------------------------------------------------------
	print REGOUT "pid($$) Collect results of $dtype $tgt\n";
	my $hmmlist = "exp3/$dtype/run001/gestList";
	my $scp = "exp3/$dtype/$tgt"."_mlf.scp";
	open(STDOUT, ">exp3/$dtype"."_$tgt.txt");
	system("HResults -A -T 1 -p -I $gMLF $hmmlist -S $scp");
	close STDOUT;
	#--------------------------------------------------------
	$pm->finish;
    }
}
$pm->wait_all_children;

open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
print "done!\n";

