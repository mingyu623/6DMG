#!/usr/bin/perl
# Mingyu Chen @ Jul 02 2012
# User Independent case (Leave-one-out)
# This script collects the results of all datatypes

opendir($dh, "exp3");
my @myDataTypes = grep(-d "exp3/$_" &&  ! /^\.{1,2}$/, readdir($dh));
@list = ("trn", "tst");

foreach my $tgt (@list)
{
    open F_write, ">exp3/$tgt"."_res.txt" or die $!;
    foreach my $dtype (@myDataTypes)
    {
	print F_write "$dtype\t";
	my $file = "exp3/$dtype"."_$tgt.txt";
	if (-e $file)
	{
	    open F_read, "<$file" or die $!;
	    my @lines = <F_read>;
	    for (@lines)
	    {
		if ($_ =~ /^WORD/)
		{
		    print F_write $_;
		}
	    }
	    close F_read;
	}
	else
	{
	    print F_write "\n";
	}
    }
    close FILE;
}
