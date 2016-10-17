#!/usr/bin/perl
# Mingyu Chen @ Aug 31 2011
# User Dependent case
# This script collects the results of each R-tester and do the average

if ($#ARGV <0)
{ 
    print "usage: exp1_avg_res [datatype1] .. [datatypen]\n";
    exit;
}

my @myDataTypes = @ARGV;

opendir($dh, "exp1") || die "exp1 doesn't exist!";
my @users = grep(-d "exp1/$_" && ! /^\.{1,2}$/, readdir($dh));

#-------------------------------------------------------------------------
# Average the results of different users
#-------------------------------------------------------------------------

open F_trn, ">exp1/trn_res.txt" or die $!;
open F_tst, ">exp1/tst_res.txt" or die $!;

foreach my $dtype (@myDataTypes)
{
    my $H1 = 0;  my $H2 = 0;
    my $S1 = 0;  my $S2 = 0;
    my $N1 = 0;  my $N2 = 0;

    foreach my $usr (@users)
    {
	print "Collect $dtype $usr\n";
	# test with trn results
	print F_trn "$dtype $usr: ";
	open F_trn_res, "<exp1/$usr/$dtype"."_trn.txt" or die $!;
	my $content1 = "\n";
	my @lines1 = <F_trn_res>;
	for (@lines1)
	{
	    if ($_ =~ /^WORD/)
	    {
		$content1 = $_;
		$_ =~ /H=(\d+), D=\d+, S=(\d+), I=\d+, N=(\d+)/;
		$H1 += $1;
		$D1 += $2;
		$N1 += $3;
	    }
	}
	close F_trn_res;
	print F_trn $content1;

	# test with tst results
	print F_tst "$dtype $usr: ";
	open F_tst_res, "<exp1/$usr/$dtype"."_tst.txt" or die $!;
	my $content2 = "\n";
	my @lines2 = <F_tst_res>;
	for (@lines2)
	{
	    if ($_ =~ /^WORD/)
	    {
		$content2 = $_;
		$_ =~ /H=(\d+), D=\d+, S=(\d+), I=\d+, N=(\d+)/;
		$H2 += $1;
		$D2 += $2;
		$N2 += $3;
	    }
	}
	close F_tst_res;
	print F_tst $content2;
    }

    print F_trn "===============================================================\n";
    print F_trn "dtype $dtype: ";
    if ($N1>0)
    {
	my $acc1 = sprintf("%5.2f", $H1/$N1*100);
	print F_trn "Acc=$acc1% [H=$H1, S=$S1, N=$N1]\n";
    }
    else
    {
	print F_trn "\n";
    }
    print F_trn "===============================================================\n\n\n";

    print F_tst "===============================================================\n";
    print F_tst "dtype $dtype: ";
    if ($N2>0)
    {
	my $acc2 = sprintf("%5.2f", $H2/$N2*100);
	print F_tst "Acc=$acc2% [H=$H2, S=$S2, N=$N2]\n";
    }
    else
    {
	print F_tst "\n";
    }
    print F_tst "===============================================================\n\n\n";
}

close F_trn;
close F_tst;
