#!/usr/bin/perl
# Mingyu @ Mar 13 2013    [ Leave-One-Out ]
#
# HVite with test.scp => dec.mlf
# HResults dec.mlf
#
# Extra options to choose from:
# 1) decision trees,
# 2) vocabulary to generate bigram

use strict;
use File::Path qw(make_path);
use File::stat;

my $dtype;
my $treeNum;
my $usr;
my $voc;
my $nbest = 5;  # set 1, 2, 3, or 5
if ($#ARGV != 3)
{
    print "usage: viterbi [datatype] [tree#] [tst usr] [voc]\n";
    print " [tree#]= 0: use the hmmdefs from decision tree 0\n";
    print "          1: use the hmmdefs from decision tree 1 (3 subtrees)\n";
    print " [tst usr] : the leave-one-out test user\n";
    print " [voc]     : na, 40, 40f, 1k, 1kf, or 100k\n";
    print "             na means no bigram\n";
    exit;
}
else
{
    $dtype   = $ARGV[0];
    $treeNum = $ARGV[1];
    $usr     = $ARGV[2];
    $voc     = $ARGV[3];
    if ($treeNum!=0 && $treeNum!=1) {
	die "incorrect tree#: $treeNum\n";
    }
    if ($voc ne "na" and $voc ne "40" and $voc ne "40f" and
        $voc ne "1k" and $voc ne "1kf" and $voc ne "100k") {
	die "incorrect wdnet with voc $voc\n";
    }
}

#input
my $path     = "products/$dtype/$usr";
my $treeDir  = "$path/tree$treeNum";
my $tstScp   = "$path/test.scp";
my $hmmdefs  = "$treeDir/trihmm5/hmmdefs";
my $dict     = "$treeDir/fullDict";
my $hmmlist  = "$treeDir/tiedlist";
my $refMlf   = "share/word_ref.mlf";
my $wdnet;
if ($voc eq "na") {
    $wdnet = "share/wdnet";
} else {
    $wdnet = "share/wdnet_bigram_$voc";
}

#output
my $dec = "$treeDir/dec_bigram_$voc\_nbest.mlf";


#=======================================================
# HVite + HResults for test.scp
#=======================================================
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$treeDir/log_dec_bigram_$voc"."_nbest.log") or die $!;
open (STDERR, ">$treeDir/err_dec_bigram_$voc"."_nbest.log") or die $!;

if ($nbest <= 1) {
    system("HVite -A -T 1 -s 15.0 -H $hmmdefs -S $tstScp -i $dec -w $wdnet $dict $hmmlist");
} else {
    system("HVite -A -T 1 -n $nbest $nbest -s 15.0 -H $hmmdefs -S $tstScp -i $dec -w $wdnet $dict $hmmlist");
}

foreach my $n (1, 2, 3, 5) {
    if ($n <= $nbest) {
        system("HResults -A -d $n -I $refMlf $hmmlist $dec");
    }
}

open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
close REGOUT;
close STDERR;


# Finish: clean up
if (stat("$treeDir/err_dec_bigram_$voc"."_nbest.log")->size == 0) # no stderr
{
    unlink("$treeDir/err_dec_bigram_$voc"."_nbest.log");
}
