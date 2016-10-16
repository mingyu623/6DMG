#!/usr/bin/perl
# Mingyu @ Aug 29 2011
# User Dependent case
# This script only collects the results from exp1.pl and computes the recognition
# accuracy and confusion matrix for the training/testing sets.

if ($#ARGV <0)
{ 
    print "usage: exp1_res [datatype1] .. [datatypen]\n";
    exit;
}

my @myDataTypes = @ARGV;

opendir($dh, "exp1") || die "exp1 doesn't exist!";
my @users = grep(-d "exp1/$_" && ! /^\.{1,2}$/, readdir($dh));

#-------------------------------------------------------------------------
# 1. Collect the MLF files and prepare the script
# 2. Collect the recognition results (HResults)
#-------------------------------------------------------------------------
my $gMLF = "mlf/gest.mlf";

open (REGOUT, ">&STDOUT") or die "Can't open REGOUT: $!\n";

foreach my $usr (@users)
{
    foreach my $dtype (@myDataTypes)
    {
	# Prepare the MLF scripts
	my $trn_scp = "exp1/$usr/$dtype/trn_mlf.scp";
	my $tst_scp = "exp1/$usr/$dtype/tst_mlf.scp";
	open F_trn_res, ">$trn_scp" or die $!;
	open F_tst_res, ">$tst_scp" or die $!;
	my @trnMLFList = glob("exp1/$usr/$dtype/run*/trn.mlf");
	my @tstMLFList = glob("exp1/$usr/$dtype/run*/tst.mlf");

	foreach my $file (@trnMLFList) {print F_trn_res "$file\n"};
	foreach my $file (@tstMLFList) {print F_tst_res "$file\n"};

	close F_trn_res;
	close F_tst_res;


	# Collect results:  HResults
	my $hmmlist = "exp1/$usr/$dtype/run001/gestList";
	print REGOUT "Collect results of $usr $dtype";
	open(STDOUT,"> exp1/$usr/$dtype"."_trn.txt");
	system("HResults -A -T 1 -p -I $gMLF $hmmlist -S $trn_scp");
	close STDOUT;
	open(STDOUT,"> exp1/$usr/$dtype"."_tst.txt");
	system("HResults -A -T 1 -p -I $gMLF $hmmlist -S $tst_scp");
	close STDOUT;
	print REGOUT "\tDone.\n";
    }
}
open(STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
exit;
