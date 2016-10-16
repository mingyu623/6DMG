#!/usr/bin/perl
# Mingyu @ Aug 30 2011
# User Independent case
# This script only collects the results from exp2.pl

if ($#ARGV <0)
{ 
    print "usage: exp2_res [datatype1] .. [datatypen]\n";
    exit;
}

@myDataTypes = @ARGV;

#-------------------------------------------------------------------------
# 1. Prepare the results scripts (trn, tstR, tstL)_mlf.scp
#-------------------------------------------------------------------------
foreach my $dtype (@myDataTypes)
{
    print "Prepare the mlf scripts for $dtype\n";
    open F_trn_res,  ">exp2/$dtype/trn_mlf.scp" or die $!;
    open F_tstR_res, ">exp2/$dtype/tstR_mlf.scp" or die $!;
    open F_tstL_res, ">exp2/$dtype/tstL_mlf.scp" or die $!;

    @runs = glob("exp2/$dtype/log*.txt");
    foreach my $run (@runs)
    {
	$run =~ /log(.*).txt/;
	$runStr = $1;
	unless (-e "exp2/$dtype/err$runStr.txt")
	{
	    # exp2_single finishes correctly
	    my $path = "exp2/$dtype/run$runStr";
	    my $trn_res  = "$path/trn.mlf";
	    my $tstR_res = "$path/tstR.mlf";
	    my $tstL_res = "$path/tstL.mlf";
	    print F_trn_res  "$trn_res\n";
	    print F_tstR_res "$tstR_res\n";
	    print F_tstL_res "$tstL_res\n";
	}
    }

    close F_trn_res;
    close F_tstR_res;
    close F_tstL_res;
}

#-------------------------------------------------------------------------
# 2. Collect the recognition results (HResults)
#-------------------------------------------------------------------------
use Parallel::ForkManager;
my $pm = new Parallel::ForkManager( 6 ); # up to 6 processes
my @list = ("trn", "tstR", "tstL");
my $gMLF = "mlf/gest.mlf";

open (REGOUT, ">&STDOUT") or die "Can't open REGOUT: $!\n";

foreach my $dtype (@myDataTypes)
{
    foreach my $tgt (@list)
    {
	$pm->start and next;
	#--------------------------------------------------------
	print REGOUT "pid($$) Collect results of $dtype $tgt\n";
	my $hmmlist = "exp2/$dtype/run001/gestList";
	my $scp = "exp2/$dtype/$tgt"."_mlf.scp";
	open(STDOUT, "> exp2/$dtype"."_$tgt.txt");
	system("HResults -A -T 1 -p -I $gMLF $hmmlist -S $scp");
	#system("HResults -A -T 1 -p -I $gMLF $hmmlist -S $scp > exp2/$dtype"."_$tgt.txt");
	close STDOUT;
	#--------------------------------------------------------
	$pm->finish;
    }
}
$pm->wait_all_children;
open(STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
