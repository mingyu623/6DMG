#!/usr/bin/perl
# Construct the global MLF (include the start & end time info)
# [NOTE] The *time* here actually means the sample numbers.
use strict;
use File::stat;
use File::Path qw(make_path);

my $data_dir = "/home/mingyu/Development/6DMG/data_htk/gestures/NPNVNOs2";

if (! -d $data_dir) 
{
    die "$data_dir doesn't exist!";
}

if (! -d "mlf")
{
    make_path "mlf";
}
open (FILE, '>mlf/gest.mlf') or die $!;
print FILE "\#!MLF!\#\n";

my @files = glob("$data_dir/*.htk");
if ($#files < 0)
{
    die "$data_dir has no .htk files";
}

foreach my $file (@files)
{
    # Read the number of samples from the htk file header
    # An unsigned int32 in "network" (big-endian) order.
    open(my $fh, "<$file") or die "Cannot open $file";
    binmode $fh;
    read $fh, my $temp, 4;
    my $len = unpack("N", $temp);  # N for big-endian uint32
    close($fh);
 
    $file =~ m/(g\d\d)_(.*).htk/;
    print $1."_".$2.":  $len\n";
    print FILE "\"*/$1_$2.lab\"\n";
    print FILE "0\t$len\t$1\n";
    print FILE ".\n";
}

close(FILE);
