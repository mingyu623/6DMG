#!/usr/bin/perl
# Mingyu Chen @ Sep 03 2011
# User Independent case
# This script collects the results of all datatypes

opendir($dh, "exp2");
my @myDataTypes = grep(-d "exp2/$_" &&  ! /^\.{1,2}$/, readdir($dh));
@list = ("trn", "tstR", "tstL");

foreach my $tgt (@list)
{
    open F_write, ">exp2/$tgt"."_res.txt" or die $!;
    foreach my $dtype (@myDataTypes)
    {
        print "Collect $dtype $tgt\n";
	print F_write "$dtype\t";
	my $file = "exp2/$dtype"."_$tgt.txt";
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
