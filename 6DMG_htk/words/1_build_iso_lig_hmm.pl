#!/usr/bin/perl
# Mingyu @ Dec 10 2012
# User Dependent case
# Train the iso lig HMMs with all trials of M1 (manually labeled)
# S1-S3
# E1-E7
# Total 21 ligs, but some of them *DO NOT* have labels in the samples

use File::Path qw(make_path remove_tree);
use File::stat;
use strict;

my $data_dir;
my $dtype;
if ($#ARGV !=1)
{
    print "use M1 manually labeled data.\n";
    print "usage: build_lig_hmm [data_dir] [datatype]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];  # the base path to the \$datatype folder
    $dtype    = $ARGV[1];  # "AW", "PO", etc.
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

my @trn_words_E4S3 = (
    "PC", "UPG", "GPS", "PST"
);

my @trn_words_E5S3 = (
    "ACC", "ACT", "BAC", "FAC", "EAC",
    "PAC", "MAC", "ACA", "ACR", "JAC",
    "RAC", "VAC", "LAC", "AC",  "ACH",
    "AGE", "AGA", "AGR", "MAG", "PAG",
    "AGO", "AS",  "WAS", "HAS", "BAS",
    "ASS", "LAS", "CAS", "EAS", "PAS",
    "ASK", "FAS", "ASI", "MAS", "GAS",
    "TAS", "ASP"
    );

#-------------------------------------------------------------------------
# Define the ligs in use
#-------------------------------------------------------------------------
my @gests = (
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
    "lig_E4S3", # 4*5 occurences in trn_words_E4S3
    "lig_E5S1",
    "lig_E5S2",
    "lig_E5S3", # 37  occurences in trn_words_E5S3
    "lig_E6S1",
#    "lig_E6S2", # too short, e.g., O->O
#    "lig_E6S3", # too short, e.g., O->G
    "lig_E7S1",
    "lig_E7S2",
#    "lig_E7S3", # too short, e.g., U->S
);

#-------------------------------------------------------------------------
# Set some common parameters
# Check directories and setup paths
# Prepare the log and err files (Redirect STDOUT & STDERR)
#-------------------------------------------------------------------------
my $gMLF  = "mlf/char_lig_manual_M1.mlf";  # global def of char+lig MLF
my $path  = "iso_lig/$dtype";
my $trn_script = "$path/train.scp";
my $tst_script = "$path/test.scp";
my $hmm0  = "$path/hmm0";
my $hmm1  = "$path/hmm1";
my $hmm2  = "$path/hmm2";
my $trnMLF= "$path/trn.mlf";
my $tstMLF= "$path/tst.mlf";
my $opt    = "-A -T 1";
my $minVar = "-v 0.001";

unless (-d $hmm0){ make_path "$hmm0"; }
unless (-d $hmm1){ make_path "$hmm1"; }
unless (-d $hmm2){ make_path "$hmm2"; }

open FILE_trn, ">$trn_script" or die $!;   
foreach my $w (@words)
{
    # use all data for lig model training (for word recognition)
    foreach my $j (1..5)
    {
	my $trn_name = sprintf("%s_M1_t%02d.htk", $w, $j);
	print FILE_trn "$data_dir/data_$dtype/$trn_name\n";	
    }
}
foreach my $w (@trn_words_E4S3)
{
    foreach my $j (1..5)
    {
	my $trn_name = sprintf("%s_M1_t%02d.htk", $w, $j);
	print FILE_trn "$data_dir/data_$dtype/$trn_name\n";
    }
}
foreach my $w (@trn_words_E5S3)
{
    my $trn_name = sprintf("%s_M1_t01.htk", $w);
    print FILE_trn "$data_dir/data_$dtype/$trn_name\n";
}
close FILE_trn;

open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/log.txt") or die $!;
open (STDERR, ">$path/err.txt") or die $!;

#-------------------------------------------------------------------------
# Prepare the word model, dictionary, grammer, and word network
#-------------------------------------------------------------------------
my $hmmlist = "$path/gestList";
my $dic     = "$path/gestDic";
my $gram    = "$path/gestGram";
my $wnet    = "$path/gestNet";
open FILE_model, ">$hmmlist" or die $!; # gestList = hmmList (each gest has its own hmm)
open FILE_dic,   ">$dic"     or die $!;
open FILE_gram,  ">$gram"    or die $!;

foreach my $g (@gests)
{
    print FILE_model "$g\n";
    print FILE_dic   "$g\t$g\n";
}
print FILE_gram  "\$gest = ".join(' | ', @gests)." \;\n";
print FILE_gram  "( \$gest ) ";

close FILE_model or die $!;
close FILE_dic   or die $!;
close FILE_gram  or die $!;

&systemE("HParse $gram $wnet", "Error: HParse()");

#-------------------------------------------------------------------------
# Training
# HCompV & HInit & HRest
# -A: print current prompt argument
# -T: trace
# -S: script for data files (.htk)
# -M: output HMM dir
# -o: output name of the HMM
# -n: use the Var from HCompV
#-------------------------------------------------------------------------
my $proto = "proto/$dtype/template_3"; # the HMM proto
unless (-e $proto){ system("perl 0_gen_single_proto.pl $dtype 3"); }

foreach my $gest (@gests)
{    
    ## Mingyu: after proper linear scaling, HCompV seems to work worse than HInit directly.
    #&systemE("HCompV $opt -I $gMLF -l $gest -S $trn_script -M $hmm0 -o $gest $proto",
    #         "Error: HCompV()");
    #&systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -n $hmm0/$gest",
    #         "Error: HInit()"); # -n use the var from
    &systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -o $gest $proto", "Error: HInit()");
    &systemE("HRest  $opt -I $gMLF -l $gest -S $trn_script -M $hmm2 $hmm1/$gest", "Error: HRest()");
}

#-------------------------------------------------------------------------
# Recognition
# HVite & HResults
# Mingyu: HRestuls in upper layer after 50 trials
#-------------------------------------------------------------------------
# Test with the training set
#&systemE("HVite $opt -d $hmm2 -S $trn_script -i $trnMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Test with the testing set
#&systemE("HVite $opt -d $hmm2 -S $tst_script -i $tstMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Collect recognition results
#&systemE("HResults $opt -p -I $gMLF $hmmlist $trnMLF", "Error: HResults()");
#&systemE("HResults $opt -p -I $gMLF $hmmlist $tstMLF", "Error: HResults()");


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

#-------------------------------------------------------------------------
# systemE()-Execute perl's system() and then catch any error.
#-------------------------------------------------------------------------
sub systemE
{
    # Get arguments
    my ($commandString, $optionalString) = @_;
    system($commandString)==0  or die "Error: $optionalString:$?\n";
}

#-------------------------------------------------------------------------
# extract()-Return certain line of a given file
#-------------------------------------------------------------------------
sub extract
{
    my ($filename, $line_no)=@_;
    my $line;
    open (FILE, $filename) || die "$filename can't be opened $! ";
    if ($line_no =~ /\D/) {
        while ($line=<FILE>) {
            if ($line =~ /$line_no/) {
                return $line;
            }
        }
    }
    else {
	foreach (1..$line_no) {
	    $line = <FILE>;
        }
        return $line;
    }
}
