#!/usr/bin/perl
# Mingyu @ May 6 2013
# 1. Train the ligature model with existing motion char models (build_iso_char_hmm.pl)
# 2. The dictionary, word network & HMM list are constructed by (dict_wdnet_prepare.pl)
# 3. Read hmmList and merge A-Z + multi-lig HMMs in one macro file
# 4. Embedded re-estimate A-Z + multi-lig HMMs
# 5. leave-one-out with $usr to specify the testing user (test with 40-word vocab)

use strict;
use File::Path qw(make_path remove_tree);
use File::Copy;
use File::stat;

my $data_dir;
my $dtype;
my $run;
my $tstUsr;
my $ligModel;
if ($#ARGV !=3)
{
    print "usage: train_lig [data_dir] [datatype] [test usr] [lig model]\n";
    print "[lig model]= flat : use the HCompV flat start initial for lig models\n";
    print "             iso  : use the manually segmented iso lig from M1's data\n";
    print "             tie  : use tie-state lig models\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];
    $dtype    = $ARGV[1]; # "AW", "PO", etc.
    $tstUsr   = $ARGV[2];
    $ligModel = $ARGV[3];
    if ( ($ligModel ne "flat") and ($ligModel ne "iso") and ($ligModel ne "tie") )
    {
	print "[lig model] is wrong\n";
	exit;
    }
}

my @words = (
    #===== set 0 =====
    "ABC",
    "CBS",
    "CNN",
    "DISCOVERY",
    "DISNEY",
    "ESPN",
    "FOX",
    "HBO",
    "NBC",
    "TBS",
    
    #===== set 1 =====
    "BBC",
    "FX",
    "HULU",
    "TNT",
    "MUSIC",    
    "JAZZ",
    "ROCK",
    "DRAMA",
    "MOVIE",
    "SPORT",

    #===== set 2 =====
    "WEATHER",
    "NEWS",
    "MLB",
    "NFL",
    "TRAVEL",
    "POKER",
    "FOOD",
    "KID",
    "MAP",
    "TV",

    #===== set 3 =====
    "GAME",
    "VOICE",
    "CALL",
    "MAIL",
    "MSG",
    "FB",
    "YOU",
    "GOOGLE",
    "SKYPE",
    "QUIZ"
);

my $path = "char_lig/$dtype/LeaveOneOut/$ligModel/$tstUsr";
my @usrs = ("A1", "C1", "C2", "C3", "C4",
	    "E1", "G1", "G2", "G3", "I1",
	    "I2", "I3", "J1", "J3", "L1",
	    "M1", "S1", "U1", "Y1", "Y3",
	    "Z1", "Z2");
my @trnUsrs = ();
foreach my $u (@usrs)
{
    if ($u ne $tstUsr)
    {
	push(@trnUsrs, $u);
    }
}

#-------------------------------------------------------------------------
# Prepare the training & testing script
#-------------------------------------------------------------------------
my $opt = "-A -T 1";
my $trn_script = "$path/trn.scp";    # specify the training "files"
my $tst_script = "$path/tst.scp";
my $trn_mlf = "$path/recog_trn.mlf"; # store the results of HVite
my $tst_mlf = "$path/recog_tst.mlf";
my $hmm0 = "$path/hmm0";
my $hmm1 = "$path/hmm1";
my $hmm2 = "$path/hmm2";
my $hmm3 = "$path/hmm3";
my $proto = "proto/$dtype/template_3";
unless(-e $proto){ system("perl 0_gen_single_proto.pl $dtype 3"); }

#!! dtype independent variables !!
my $charMlf = "mlf/char_lig.mlf"; # char level mlf (w/ lig)
my $wordMlf = "mlf/word.mlf";     # word level mlf
my $hmmList = "char_lig/hmmList"; # hmmList0 contains A-Z + lig HMMs
my $dict    = "char_lig/dict";
my $wdnet   = "char_lig/wdnet";

unless (-d $hmm0){ make_path "$hmm0"; }
unless (-d $hmm1){ make_path "$hmm1"; }
unless (-d $hmm2){ make_path "$hmm2"; }
unless (-d $hmm3){ make_path "$hmm3"; }

open FILE_trn, ">$trn_script" or die $!;
open FILE_tst, ">$tst_script" or die $!;

foreach my $w (@words)
{
    foreach my $u (@trnUsrs)
    {
	foreach my $j (1..5)
	{
	    my $trn_name = sprintf("%s_%s_t%02d.htk", $w, $u, $j);
	    print FILE_trn "$data_dir/data_$dtype/$trn_name\n";
	}
    }
    foreach my $j (1..5)
    {
	my $tst_name = sprintf("%s_%s_t%02d.htk", $w, $tstUsr, $j);
	print FILE_tst "$data_dir/data_$dtype/$tst_name\n";
    }
}
close FILE_trn;
close FILE_tst;

open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/../log_$tstUsr.txt") or die $!;
open (STDERR, ">$path/../err_$tstUsr.txt") or die $!;

#-------------------------------------------------------------------------
# 1. HCompV: Initialize the "lig" model (output to hmm0)
# 2. Read the existing A-Z HMMs from iso_char
# 3. Generate the HMM macro file
#-------------------------------------------------------------------------
#*******************************************************
# flat: HCompV initializes the lig HMMs (the same initial values for all ligs)
#*******************************************************
system("HCompV $opt -v 0.0001 -I $charMlf -S $trn_script -M $hmm0 -o lig $proto"); # update variance only (0 mean)
foreach my $e (1..7)
{
    foreach my $s (1..3)
    {
	my $ligName = "lig_E$e"."S$s";
	open(LIG_READ, "$hmm0/lig")      or die "Could not open $hmm0/lig";
	open(LIG_WRITE,">$hmm0/$ligName") or die "Could not write $hmm0/$ligName";
	foreach my $l (<LIG_READ>)
	{
	    if ($l =~ m/~h \"lig\"/)
	    {
		print LIG_WRITE "~h \"$ligName\"\n";
	    }
	    else
	    {
		print LIG_WRITE $l;
	    }
	}
	close LIG_READ;
	close LIG_WRITE;
    }
}

#my $src_dir = "iso_char/$dtype/$usr/hmm2";
my $src_dir = "iso_char/$dtype/all/hmm2";  # Mingyu:(temporally hack, $usr = LeaveOneOut)
print "Copy from $src_dir\n";
my @src_files = glob("$src_dir/upp_*");
foreach my $src_file (@src_files)
{
    if ($src_file =~ m/(upp_[A-Z])/)
    {
	copy($src_file, "$hmm0/$1") or die "File cannot be copied.";
	print "Copy to $hmm0: $1\n";
   }
}

open (HMM_LIST, $hmmList) or die "Coud not open $hmmList";
open (HMM_DEF_FLAT, ">$hmm0/hmmdefs_flat") or die "Could not open $hmm0/hmmdefs_flat";
foreach my $line (<HMM_LIST>)
{
    chomp($line);
    open(ISO_CHAR, "$hmm0/$line") or die "Could not open HMM $hmm0/$line";
    foreach my $content (<ISO_CHAR>)
    {
	print HMM_DEF_FLAT $content;
    }
    print HMM_DEF_FLAT "\n\n";
    print "Copy to hmmdefs: $line\n";
}
close HMM_DEF_FLAT;
close HMM_LIST;

#*******************************************************
# tie: Create the tied-state HMM defs
#*******************************************************
if ($ligModel eq "tie") 
{
    my $tie_hed = "mlf/tie.hed";
    system("HHEd -T 1 -H $hmm0/hmmdefs_flat -M $hmm0 -w hmmdefs_tie $tie_hed $hmmList");

}

#*********************************************************
# iso: Copy the iso ligs from M1's data
# This will *OVERWRITE* the HCompV lig HMMs
# For non-existing iso ligs, the HCompV ligs will be used      
#*********************************************************
my @iso_ligs = (
    "lig_E1S1",
    "lig_E1S2",
    "lig_E1S3",
    "lig_E2S1",
    "lig_E2S2",
    "lig_E2S3",
    "lig_E3S1",
    "lig_E3S2",
    "lig_E3S3",
    "lig_E4S1",
    "lig_E4S2",
#    "lig_E4S3", # 0 occurence
    "lig_E5S1",
    "lig_E5S2",
#    "lig_E5S3", # 0 occurence
    "lig_E6S1",
#    "lig_E6S2", # too short, e.g., O->O
#    "lig_E6S3", # too short, e.g., O->G
    "lig_E7S1",
    "lig_E7S2",
#    "lig_E7S3", # too short, e.g., U->S
);

if ($ligModel eq "iso") 
{
    my $iso_ligs_path = "iso_lig/$dtype/hmm2";
    foreach my $lig (@iso_ligs)
    {    
	copy("$iso_ligs_path/$lig", "$hmm0/$lig") or die "File cannot be copied.";
    }
    
    open (HMM_DEF_ISO, ">$hmm0/hmmdefs_iso") or die "Could not open $hmm0/hmmdefs_iso";
    open (HMM_LIST, $hmmList) or die "Coud not open $hmmList";
    foreach my $line (<HMM_LIST>)
    {
	chomp($line);
	open(ISO_CHAR, "$hmm0/$line") or die "Could not open HMM $hmm0/$line";
	foreach my $content (<ISO_CHAR>)
	{
	    print HMM_DEF_ISO $content;
	}
	print HMM_DEF_ISO "\n\n";
	print "Copy to hmmdefs_iso: $line\n";
	close ISO_CHAR;
    }
    close HMM_DEF_SIO;
}
close HMM_LIST;

#-------------------------------------------------------------------------
# HERest (1,2,3): Embedded re-estimate char + lig HMMs (output to hmm1, hmm2, hmm3)
#-------------------------------------------------------------------------
# specify the HMM (flat from HCompV or tie-state or iso-lig) here
my $hmmdefs = "hmmdefs_$ligModel"; 

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

# Evaluation
#system("HVite $opt -H $hmm3/$hmmdefs -S $trn_script -i $trn_mlf -w $wdnet $dict $hmmList");
system("HVite $opt -H $hmm3/$hmmdefs -S $tst_script -i $tst_mlf -w $wdnet $dict $hmmList");
#system("HResults $opt -I $wordMlf $hmmList $trn_mlf");
system("HResults $opt -I $wordMlf $hmmList $tst_mlf");

#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/../err_$tstUsr.txt")->size == 0) # no stderr
{
    unlink("$path/../err_$tstUsr.txt");
}
