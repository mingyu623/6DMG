#!/usr/bin/perl
# Mingyu @ Jun 4 2013
# 0.  Use A-Z + "multi-lig" + "fil" HMMs for detected motion word recognition
# 1.1 Use the char/lig HMMs built from C:/Mingyu/6DMG_word_SNG1_multi_lig2/char_lig
# 1.2 "fil" HMM is initialized by init_fil.pl
# 2.  Read hmmList and merge A-Z + multi-lig + fil HMMs in one macro file
# 3.  Embedded re-estimate A-Z + multi-lig + fil HMMs
# 4.  Run one leave-one-out cross validation on (filtered) ground-truth word segments
#

use strict;
use File::Path qw(make_path);
use File::Copy;
use File::stat;
use Cwd qw(abs_path);

my $dtype;
my $tstUsr;
if ($#ARGV !=1)
{
    print "usage: train_HMM_single [datatype] [tst usr]\n";
    exit;
}
else
{
    $dtype  = $ARGV[0]; # "AW", "PO", etc.
    $tstUsr = $ARGV[1];
}

my $path = "char_lig/$dtype/$tstUsr";
unless(-d $path){ make_path($path); }

my @usrs = ("M1", "C1", "J1", "C3", "C4",
            "E1", "U1", "Z1", "I1", "L1",
	    "Z2", "K1", "T2", "M3", "J4",
	    "D1", "W1", "T3");
my @trnUsrs;
foreach (@usrs)
{
    if ($_ ne $tstUsr)
    {
	push(@trnUsrs, $_);
    }
}

my @words_common = (
"SET", "DAYS","ISSU","MAP", "LONG","LIFE","MONT","GIVE","DIFF","SEND",
"COUL","PLAC","SECU","COND","FAMI","CHAR","AGAI","TRAV","ADDR","EBAY",
"OPEN","FOUN","CHEC","WEBS","SECT","STAN","BEFO","DID", "OFF", "NOTE",
"MUST","VISI","THOS","USIN","BUIL","SOUT","FEAT","COST","RELE","CODE",
"LEVE","POIN","HARD","BOAR","HOUR","DVD", "HIST","DESC","UPDA","VERS",
"JOIN","VALU","TRAD","LARG","SOCI","REPL","TOOL","BETW","ADVA","DIST",
"TOPI","WOME","ROOM","ARCH","PERF","MEET","BLAC","TITL","LIVE","OWN", 
"BEIN","MUCH","FEED","BOTH","WEST","SMAL","ASSO","WHIL","ENGL","SIZE",
"SOUR","NEXT","SEX", "EXAM","JAZZ","ZIP", "FAQ", "REQU","QUIT","YORK",
"POKE","KNOW","OBJ", "GPS", "PSY", "PROJ","KEY", "SQUA","XBOX","ROCK",
);

my %words_hash;
foreach my $w (@words_common){ $words_hash{$w} = 1; }

#-------------------------------------------------------------------------
# Prepare the training & testing script
#-------------------------------------------------------------------------
my $detDir = "../../../data_htk/airwriting_spot/truth/data_$dtype";
$detDir = abs_path($detDir);
unless(-d $detDir) { die "training data doesn't exist at $detDir!\n"; }
my $trn_script = "$path/trn.scp";    # specify the training "files"
my $tst_script = "$path/tst.scp";    # test with the 150 words (100 common + 50 unique words)

open FILE_trn, ">$trn_script" or die $!;
open FILE_tst, ">$tst_script" or die $!;

my @dets = glob("$detDir/*.htk"); # glob returns the full path
foreach my $det (@dets)
{
    $det =~ m/([A-Z][0-9])_([A-Z]+).htk$/;
    if ($1 eq $tstUsr){
	print FILE_tst "$det\n";
    }
    else{
	print FILE_trn "$det\n";
    }
}

close FILE_trn;
close FILE_tst;


#-------------------------------------------------------------------------
# HTK parameters
#-------------------------------------------------------------------------
my $opt = "-A -T 1";
my $trn_mlf = "$path/recog_trn.mlf"; # store the results of HVite
my $tst_mlf = "$path/recog_tst.mlf";
my $hmm0 = "$path/hmm0";
my $hmm1 = "$path/hmm1";
my $hmm2 = "$path/hmm2";
my $hmm3 = "$path/hmm3";

#!! dtype independent variables !!
my $charMlf = "mlf/char_lig.mlf";     # char level mlf (w/ lig)
my $wordMlf = "mlf/word.mlf";         # word level mlf
my $hmmList = "char_lig/hmmList";     # hmmList contains A-Z + ligs + fil HMMs
my $dict  = "char_lig/dict1k";   # 100 common + 900 unique words
my $wdnet = "char_lig/wdnet1k";

unless (-d $hmm0){ make_path "$hmm0"; }
unless (-d $hmm1){ make_path "$hmm1"; }
unless (-d $hmm2){ make_path "$hmm2"; }
unless (-d $hmm3){ make_path "$hmm3"; }



#-------------------------------------------------------------------------
# 1.1 Copy the existing A-Z & lig HMMs from 6DMG_word_SNG1_multi_lig2/char_lig
# 1.2 Read the fil HMM created by init_fil.pl
# 2.  Generate the HMM macro file
#-------------------------------------------------------------------------
my $srcHmmDef = "../../words_word_based/char_lig/$dtype/Extension/iso/hmm3/hmmdefs_iso";
my $init_fil = "$path/../fil";

open(HMM_DEF, ">$hmm0/hmmdefs") or die $!;
open(SRC_DEF, $srcHmmDef) or die $!;
open(FIL_DEF, $init_fil)  or die $!;
foreach my $line (<FIL_DEF>){
    print HMM_DEF $line;
}
foreach my $line (<SRC_DEF>){
    print HMM_DEF $line;
}


#-------------------------------------------------------------------------
# Pipe stdout and stderr to log/err files
#-------------------------------------------------------------------------
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/log.txt") or die $!;
open (STDERR, ">$path/err.txt") or die $!;


#-------------------------------------------------------------------------
# HERest (1,2,3): Embedded re-estimate char + lig HMMs (output to hmm1, hmm2, hmm3)
#-------------------------------------------------------------------------
my $hmmdefs = "hmmdefs";

system("HERest $opt -I $charMlf -S $trn_script -H $hmm0/$hmmdefs -M $hmm1 $hmmList");
system("HERest $opt -I $charMlf -S $trn_script -H $hmm1/$hmmdefs -M $hmm2 $hmmList");
system("HERest $opt -I $charMlf -S $trn_script -H $hmm2/$hmmdefs -M $hmm3 $hmmList");


#-------------------------------------------------------------------------
# HVite: Viterbi decoding + align the training data (for further HERest)
# HResult: evaluate the recognition rates
#-------------------------------------------------------------------------
# Align the training data (for re-embedded re-estimate)
# Output the aligned results to "trn_align.mlf"
#system("HVite $opt -H $hmm3/$hmmdefs -i $path/trn_align.mlf -m -y htk -I $wordMlf -S $trn_script $dict $hmmList");

# Evaluation on the testing set
system("HVite $opt -H $hmm3/$hmmdefs -S $tst_script -i $tst_mlf -w $wdnet $dict $hmmList");

system("HResults $opt -I $wordMlf $hmmList $tst_mlf");

#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/err.txt")->size == 0) # no stderr
{
    unlink("$path/err.txt");
}
