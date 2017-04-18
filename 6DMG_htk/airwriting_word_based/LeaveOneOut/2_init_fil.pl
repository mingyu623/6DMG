#!/usr/bin/perl
# Mingyu @ Apr 21 2013
# 1. Initialize "fil" HMM with HCompV

use strict;
use File::Path qw(make_path);
use Cwd qw(abs_path);

my $dtype;
if ($#ARGV != 0)
{
    die "usage: init_fil [datatype]\n";
}
else
{
    $dtype = $ARGV[0];
}

my $path = "char_lig/$dtype";
unless (-d $path){ make_path($path); }
#-------------------------------------------------------------------------
# Create all_dets.scp (contains all detected segments)
#-------------------------------------------------------------------------
my $detDir = "../../../data_htk/airwriting_spot/train/data_$dtype";
$detDir = abs_path($detDir);

unless (-d $detDir) { die "$detDir doesn't exist!\n"; }
open detSCP, ">$path/all_dets.scp" or die $!;

my @dets = glob("$detDir/*.htk"); # glob returns the full path
foreach my $det (@dets)
{
    print detSCP "$det\n";
}

#-------------------------------------------------------------------------
# HCompV for "fil" HMM (1 state, 1 GMM?)
# update variance only (0 mean)
#-------------------------------------------------------------------------
my $filHmm = "fil";
my $opt  = "-A -T 1 -v 0.0001";
my $proto = "proto/$dtype/template_1"; # the HMM proto
unless (-e $proto){ system("perl 0_gen_single_proto.pl $dtype 1"); }

system("HCompV $opt -S $path/all_dets.scp -M $path -o $filHmm $proto");

print "HCompV initializes \"fil\" HMM\n";
