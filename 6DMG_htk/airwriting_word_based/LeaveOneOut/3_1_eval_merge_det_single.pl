#!/usr/bin/perl
# Mingyu @ Apr 26 2013
# 1.  Use the hmmdefs trained in 3_0_train_HMM_single.pl (with clean detection)
# 2.  Evaluate on the merged detection (5 test scripts, at most)
# 2.1 merge_tst.scp
# 2.2 merge_tstOOV.scp
# 2.3 merge_imprecise.scp
# 2.4 merge_impreciseOOV.scp
# 2.5 FA.scp
# 3.  Run leave-one-out cross validation on merged detection segments (exluding the outliers)
#     outlier: IMCOMPLETE word segment after merge
# 4.  Use the 1k-word vocab (i.e., dict, wdnet)

use strict;
use File::Path qw(make_path);
use File::stat;

my $dtype;
my $tstUsr;
if ($#ARGV !=1)
{
    print "usage: eval_merge_det_single [datatype] [tst usr]\n";
    exit;
}
else
{
    $dtype  = $ARGV[0]; # "AW", "PO", etc.
    $tstUsr = $ARGV[1];
}

my $path = "char_lig/$dtype/$tstUsr";
unless(-d $path){ make_path($path); }

# input 
my $merge_tstSCP          = "$path/merge_tst.scp";
my $merge_tstOovSCP       = "$path/merge_tstOOV.scp";
my $merge_impreciseSCP    = "$path/merge_imprecise.scp";
my $merge_impreciseOovSCP = "$path/merge_impreciseOOV.scp";
my $merge_faSCP           = "$path/merge_FA.scp";
my $merge_word_MLF        = "$path/merge_ref.mlf";
unless (-f $merge_tstSCP) { die "Cannot find test scp for merge detection results!\n"; }

# output
my $dec     = "$path/dec_merge_tst.mlf";
my $decOOV  = "$path/dec_merge_tstOOV.mlf";
my $decIm   = "$path/dec_merge_imprecise.mlf";
my $decImOOV= "$path/dec_merge_impreciseOOV.mlf";
my $decFA   = "$path/dec_merge_FA.mlf";

#-------------------------------------------------------------------------
# Pipe stdout and stderr to log/err files
#-------------------------------------------------------------------------
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/log_merge_det.txt") or die $!;
open (STDERR, ">$path/err_merge_det.txt") or die $!;

#-------------------------------------------------------------------------
# HVite + HResults
#-------------------------------------------------------------------------
my $opt = "-A -T 1";
my $hmmdef  = "$path/hmm3/hmmdefs";
my $wdnet   = "char_lig/wdnet1k";
my $dict    = "char_lig/dict1k";
my $hmmlist = "char_lig/hmmList";

system("HVite $opt -H $hmmdef -S $merge_tstSCP -i $dec -w $wdnet $dict $hmmlist");
system("HResults $opt -I $merge_word_MLF $hmmlist $dec");

system("HVite $opt -H $hmmdef -S $merge_tstOovSCP -i $decOOV -w $wdnet $dict $hmmlist");
system("HResults $opt -I $merge_word_MLF $hmmlist $decOOV");

unless (stat($merge_impreciseSCP)->size == 0){
    system("HVite $opt -H $hmmdef -S $merge_impreciseSCP -i $decIm -w $wdnet $dict $hmmlist");
    system("HResults $opt -I $merge_word_MLF $hmmlist $decIm");
}

unless (stat($merge_impreciseOovSCP)->size == 0){
    system("HVite $opt -H $hmmdef -S $merge_impreciseOovSCP -i $decImOOV -w $wdnet $dict $hmmlist");
    system("HResults $opt -I $merge_word_MLF $hmmlist $decImOOV");
}

unless (stat($merge_faSCP)->size == 0){
    system("HVite $opt -H $hmmdef -S $merge_faSCP -i $decFA -w $wdnet $dict $hmmlist");
    system("HResults $opt -I $merge_word_MLF $hmmlist $decFA");
}
#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/err_merge_det.txt")->size == 0) # no stderr
{
    unlink("$path/err_merge_det.txt");
}
