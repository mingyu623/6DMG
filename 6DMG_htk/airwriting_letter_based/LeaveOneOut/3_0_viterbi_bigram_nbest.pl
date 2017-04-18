#!/usr/bin/perl
# Mingyu @ Apr 22 2013    [ Leave-One-Out ]
# Use bigram network with nbest decoding
# HVite with test.scp => dec.mlf
# HResults dec.mlf

use strict;
use File::Path qw(make_path);
use File::stat;

my $dtype;
my $treeNum;
my $usr;
my $voc;
my $detOption;
my $nbest = 5;  # set to 1, 2, 3, or 5
if ($#ARGV != 4) {
    print "usage: viterbi [datatype] [tree#] [tst usr] [voc] [detOption]\n";
    print " [tree#]= 0: use the hmmdefs from decision tree 0\n";
    print "          1: use the hmmdefs from decision tree 1 (3 subtrees)\n";
    print " [tst usr] : the leave-one-out test user\n";
    print " [voc] : 100, 100f, 1k, 1kf\n";
    print " [detOption] : det, merge\n";
    exit;
} else {
    $dtype   = $ARGV[0];
    $treeNum = $ARGV[1];
    $usr     = $ARGV[2];
    $voc     = $ARGV[3];
    $detOption = $ARGV[4];
    if ($treeNum!=0 && $treeNum!=1) {
	die "incorrect tree#: $treeNum\n";
    }
    if ($voc ne "100" and $voc ne "100f" and $voc ne "1k" and $voc ne "1kf") {
	die "incorrect wdnet with voc $voc\n";
    }
    if ($detOption ne "det" and $detOption ne "merge") {
        die "incorrect det option: $detOption\n";
    }
}

#input
my $path      = "products/$dtype/$usr";
my $treeDir   = "$path/tree$treeNum";
my $hmmdefs   = "$treeDir/trihmm5/hmmdefs";
my $dict      = "$treeDir/fullDict";
my $hmmlist   = "$treeDir/tiedlist";
my $wdnet     = "share/wdnet_bigram_$voc";
my $tstScp;
my $tstOovScp;
my $tstScp2;
my $tstOovScp2;
my $tstFaScp;
my $refMlf;
if ($detOption eq "det") {
    $tstScp    = "$path/test.scp";             # precise   detection 
    $tstOovScp = "$path/testOOV.scp";          # precise   detection OOV
    $tstScp2   = "$path/imprecise.scp";        # imprecise detection
    $tstOovScp2= "$path/impreciseOOV.scp";     # imprecise detection OOV
    $tstFaScp  = "$path/FA.scp";               # false alarm
    $refMlf    = "$path/det_ref.mlf";  # tailoered ref.mlf for *all* detection
} else {
    $tstScp    = "$path/merge_tst.scp";          # precise   detection 
    $tstOovScp = "$path/merge_tstOOV.scp";       # precise   detection OOV
    $tstScp2   = "$path/merge_imprecise.scp";    # imprecise detection
    $tstOovScp2= "$path/merge_impreciseOOV.scp"; # imprecise detection OOV
    $tstFaScp  = "$path/merge_FA.scp";           # false alarm
    $refMlf    = "$path/merge_ref.mlf";    # tailored ref.mlf for the merge case
}

#output
my $dec;
my $decOOV;
my $decIm;
my $decImOOV;
my $decFA;
if ($detOption eq "det") {
    $dec     = "$treeDir/dec_bigram_nbest_$voc.mlf";
    $decOOV  = "$treeDir/dec_bigram_nbest_OOV_$voc.mlf";
    $decIm   = "$treeDir/dec_imprecise_nbest_$voc.mlf";
    $decImOOV= "$treeDir/dec_imprecise_nbest_OOV_$voc.mlf";
    $decFA   = "$treeDir/dec_FA_nbest_$voc.mlf";
} else {
    $dec      = "$treeDir/dec_merge_nbest_$voc.mlf";
    $decOOV   = "$treeDir/dec_merge_nbest_OOV_$voc.mlf";
    $decIm    = "$treeDir/dec_merge_nbest_imprecise_$voc.mlf";
    $decImOOV = "$treeDir/dec_merge_nbest_imprecise_OOV_$voc.mlf";
    $decFA    = "$treeDir/dec_merge_nbest_FA_$voc.mlf";
}


#=======================================================
# HVite + HResults for test.scp
# HVite + HResults for testOOV.scp
# HVite + HResults for imprecise.scp
# HVite + HResults for impreciseOOV.scp
# HVite + HResults for FA.scp
#=======================================================
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
if ($detOption eq "det") {
    open (STDOUT, ">$treeDir/log_dec_bigram_$voc\_nbest.log") or die $!;
    open (STDERR, ">$treeDir/err_dec_bigram_$voc\_nbest.log") or die $!;
} else {
    open (STDOUT, ">$treeDir/log_dec_merge_$voc\_nbest.log") or die $!;
    open (STDERR, ">$treeDir/err_dec_merge_$voc\_nbest.log") or die $!;
}

my $hviteOpt = "-A -T 1 -n $nbest $nbest -s 15.0";

system("HVite $hviteOpt -H $hmmdefs -S $tstScp -i $dec -w $wdnet $dict $hmmlist");
system("HVite $hviteOpt -H $hmmdefs -S $tstOovScp -i $decOOV -w $wdnet $dict $hmmlist");

foreach my $n (1, 2, 3, 5) {
    if ($n <= $nbest) {
        system("HResults -A -d $n -I $refMlf $hmmlist $dec");
        system("HResults -A -d $n -I $refMlf $hmmlist $decOOV");
    }
}

unless (stat($tstScp2)->size == 0) {
    system("HVite $hviteOpt -H $hmmdefs -S $tstScp2 -i $decIm -w $wdnet $dict $hmmlist");
    foreach my $n (1, 2, 3, 5) {
        if ($n <= $nbest) {
            system("HResults -A -d $n -I $refMlf $hmmlist $decIm");
        }
    }
}

unless (stat($tstOovScp2)->size ==0) {
    system("HVite $hviteOpt -H $hmmdefs -S $tstOovScp2 -i $decImOOV -w $wdnet $dict $hmmlist");
    foreach my $n (1, 2, 3, 5) {
        if ($n <= $nbest) {
            system("HResults -A -d $n -I $refMlf $hmmlist $decImOOV");
        }
    }
}

unless (stat($tstFaScp)->size ==0) # false alarm(s) in the detection
{
    system("HVite $hviteOpt -H $hmmdefs -S $tstFaScp -i $decFA -w $wdnet $dict $hmmlist");
    foreach my $n (1, 2, 3, 5) {
        if ($n <= $nbest) {
        system("HResults -A -d $n -I $refMlf $hmmlist $decFA");
        }
    }
}

open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
close REGOUT;
close STDERR;


# Finish: clean up
if ($detOption eq "det") {
    if (stat("$treeDir/err_dec_bigram_$voc"."_nbest.log")->size == 0) { # no stderr
        unlink("$treeDir/err_dec_bigram_$voc"."_nbest.log");
    }
} else {
    if (stat("$treeDir/err_dec_merge_$voc\_nbest.log")->size == 0) { # no stderr
        unlink("$treeDir/err_dec_merge_$voc\_nbest.log");
    }
}
