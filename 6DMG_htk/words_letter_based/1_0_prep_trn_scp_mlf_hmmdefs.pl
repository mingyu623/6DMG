#!/usr/bin/perl
# Mingyu @ Mar 7 2013 [ Leave-One-Out cross validation ]
# 1.  Generate the training script for 40 words
# 2.  Generate the mono-char, tri-lig lable files (mlf) for 40 words
# 3.1 Create the hmmList (triligHmmlist)
# 3.2 Create the full hmmList (fulllist: 26 chars + 26x26 ligs)
# 4.  A stats for the triligHmmlist
# 5.1 Clone the lig  models from multi_lig2 (after HERest) for the initial values of trilig
# 5.2 Clone the char models from multi_lig2 (after HERest) for the initial values of chars
# 5.3 Generate "trihmm0/hmmdefs" (5.1 + 5.2)
# 6   Create tieTransP.hed & use HHEd to tie the transition prob of "trihmm0/hmmdefs"
# 7   Run HERest twice trihmm0/hmmdefs -> trihmm1/hmmdefs -> trihmm2/hmmdefs

use strict;
use File::Copy;
use File::Path qw(make_path);

my $data_dir;
my $dtype;
my $usr;
if ($#ARGV !=2)
{
    print "usage: prep_trn_scp_mlf_hmmdefs [data_dir] [datatype] [tst usr]\n";
    print " [data_dir]: the base path to the \$datatype folder\n";
    print " [tst usr]:  the leave-one-out test user excluded from the traing set\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];
    $dtype    = $ARGV[1];
    $usr      = $ARGV[2];
}

my $path = "products/$dtype/$usr";
unless(-d $path){ make_path $path; }
my $MLF       = "$path/mono_char_tri_lig.mlf";
my $trnSCP    = "$path/train.scp";
my $tstSCP    = "$path/test.scp";
my $hmmlist   = "$path/triligHmmlist";
my $fulllist  = "$path/fulllist";
my $STAT      = "$path/trilig_stats.txt";


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

#my @trn_words_E4S3 = (
#    "PC", "UPG", "GPS", "PST"
#);

#my @trn_words_E5S3 = (
#    "ACC", "ACT", "BAC", "FAC", "EAC",
#    "PAC", "MAC", "ACA", "ACR", "JAC",
#    "RAC", "VAC", "LAC", "AC",  "ACH",
#    "AGE", "AGA", "AGR", "MAG", "PAG",
#    "AGO", "AS",  "WAS", "HAS", "BAS",
#    "ASS", "LAS", "CAS", "EAS", "PAS",
#    "ASK", "FAS", "ASI", "MAS", "GAS",
#    "TAS", "ASP"
#    );


my @usrs = ("A1", "C1", "C2", "C3", "C4",
	    "E1", "G1", "G2", "G3", "I1",
	    "I2", "I3", "J1", "J3", "L1",
	    "M1", "S1", "U1", "Y1", "Y3",
	    "Z1", "Z2");
my %trilig_hash = ();

my @trnUsrs;
if ($usr eq "all"){
    @trnUsrs = @usrs;
}
else{
    foreach (@usrs){
	if ($_ ne $usr){
	    push(@trnUsrs, $_);
	}
    }
}

#=======================================================
# Create mono char + tri_lig MLF
#=======================================================
open MLF, ">$MLF" or die $!;
print MLF "#!MLF!#\n";
foreach my $w (@words)
{
    my @sub_chars = split(undef, $w);
    my $chars = "upp_$sub_chars[0]\n";
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $E = $sub_chars[$i-1];
	my $S = $sub_chars[$i];
	my $lig = "upp_$E-lig+upp_$S";
	$chars = $chars."$lig\n"."upp_$S\n";

	$trilig_hash{$lig} += 1;
    }

    foreach my $u (@usrs)
    {
	foreach my $t (1..5)
	{
	    my $file = sprintf("%s_%s_t%02d.lab", $w, $u, $t);
	    print MLF "\"*/$file\"\n";
	    print MLF $chars;
	    print MLF ".\n";
	}
    }
}

#foreach my $w (@trn_words_E4S3)
#{
#    my @sub_chars = split(undef, $w);
#    my $chars = "upp_$sub_chars[0]\n";
#    foreach my $i (1..scalar(@sub_chars)-1)
#    {
#	my $E = $sub_chars[$i-1];
#	my $S = $sub_chars[$i];
#	my $lig = "upp_$E-lig+upp_$S";
#	$chars = $chars."$lig\n"."upp_$S\n";
#
#	$trilig_hash{$lig} += 1;
#    }
#    foreach my $t (1..5)
#    {
#	 my $file = sprintf("%s_M1_t%02d.lab", $w, $t);
#	 print MLF "\"*/$file\"\n";
#	 print MLF $chars;
#	 print MLF ".\n";
#    }
#}

#foreach my $w (@trn_words_E5S3)
#{
#    my @sub_chars = split(undef, $w);
#    my $chars = "upp_$sub_chars[0]\n";
#    foreach my $i (1..scalar(@sub_chars)-1)
#    {
#	my $E = $sub_chars[$i-1];
#	my $S = $sub_chars[$i];
#	my $lig = "upp_$E-lig+upp_$S";
#	$chars = $chars."$lig\n"."upp_$S\n";
#
#	$trilig_hash{$lig} += 1;
#   }
#    my $file = sprintf("%s_M1_t01.lab", $w);
#    print MLF "\"*/$file\"\n";
#    print MLF $chars;
#    print MLF ".\n";
#}
close MLF;
print "Create\t$MLF\n";

#=======================================================
# Create train.scp + test.scp
#=======================================================
open trnSCP, ">$trnSCP" or die $!;
foreach my $w (@words)
{
    foreach my $u (@trnUsrs)
    {
	foreach my $t (1..5)
	{
	    my $file = sprintf("%s_%s_t%02d.htk", $w, $u, $t);
	    print trnSCP "$data_dir/data_$dtype/$file\n";
	}
    }
}

#foreach my $w (@trn_words_E4S3)
#{
#    foreach my $j (1..5)
#    {
#	my $trn_name = sprintf("%s_M1_t%02d.htk", $w, $j);
#	print SCP "$data_dir/data_$dtype/$trn_name\n";
#    }
#}

#foreach my $w (@trn_words_E5S3)
#{
#    my $trn_name = sprintf("%s_M1_t01.htk", $w);
#    print SCP "$data_dir/data_$dtype/$trn_name\n";
#}
close trnSCP;

open tstSCP, ">$tstSCP" or die $!;
foreach my $w (@words)
{
    foreach my $t (1..5)
    {
	my $file = sprintf("%s_%s_t%02d.htk", $w, $usr, $t);
	print tstSCP "$data_dir/data_$dtype/$file\n";
    }
}
close tstSCP;

print "Create\t$trnSCP and $tstSCP\n";

#=======================================================
# Create triligHmmlist & fulllist
#=======================================================
open HMMLIST, ">$hmmlist" or die $!;
open STAT,    ">$STAT" or die $!;
foreach ('A'..'Z')
{
    print HMMLIST "upp_$_\n";
}

foreach my $k (sort keys(%trilig_hash))
{
    print HMMLIST "$k\n";
    print STAT "$k\t$trilig_hash{$k}\n";
}
close STAT;
close HMMLIST;

open FULLLIST, ">$fulllist" or die $!;
foreach my $C ('A'..'Z')
{
    print FULLLIST "upp_$C\n";
}
foreach my $L ('A'..'Z')
{
    foreach my $R ('A'..'Z')
    {
	print FULLLIST "upp_$L-lig+upp_$R\n";
    }
}
close FULLLIST;
print "Create\t$hmmlist\n";

#=======================================================
# store srcHmmList into hash first
#=======================================================
my $srcHmmlist = "../words_word_based/char_lig/$dtype/Extension/iso/hmm3/hmmdefs_iso";
my $outDir  = "$path/trihmm0";
my $hmmdefs = "$outDir/hmmdefs";
my $tieTranspHed = "$outDir/tieTransP.hed";
unless (-d $outDir){ make_path $outDir; }

my $header;
my %hmm_hash = ();
open SRC, $srcHmmlist or die $!;
while(my $line = <SRC>)
{
    if ($line =~ /^~h "(.*)"/) # start of a HMM
    {
	my $hmmName = $1;
	my $model = "";

	while(my $content = <SRC>)
	{
	    $model = $model.$content;
	    if ($content =~ /^<ENDHMM>/){ last; }
	}

	$hmm_hash{$hmmName} = $model;
    }
    elsif ($line =~ /^~o/) # start of header
    {
	$header = $line;
	while (my $content = <SRC>)
	{
	    $header = $header.$content;
	    if ($content =~ /^<VECSIZE>/){ last; }
	}
    }
}
close SRC;


#===============================================
# Clone the proper hmm models to trilig Hmmlist
# e.g. upp_A-lig+upp_B <- lig_E5S1
#******************************************
# The one I will use for multi-lig(2) models
# S1: BDEFHKLMNPRTUVWXYZ
# S2: AIJOQ
# S3: CGS
# E1: BDSX
# E2: ITY
# E3: CEGHKLMQRZ
# E4: JP
# E5: AF
# E6: O
# E7: NUVW
#******************************************
#===============================================
# Start points have 3 sets
my %S_hash = (
    'A' => 2,
    'B' => 1,
    'C' => 3,
    'D' => 1,
    'E' => 1,
    'F' => 1,
    'G' => 3,
    'H' => 1,
    'I' => 2,
    'J' => 2,
    'K' => 1,
    'L' => 1,
    'M' => 1,
    'N' => 1,
    'O' => 2,
    'P' => 1,
    'Q' => 2,
    'R' => 1,
    'S' => 3,
    'T' => 1,
    'U' => 1,
    'V' => 1,
    'W' => 1,
    'X' => 1,
    'Y' => 1,
    'Z' => 1,
    );

# End points have 3 sets
my %E_hash = (
    'A' => 5,
    'B' => 1,
    'C' => 3,
    'D' => 1,
    'E' => 3,
    'F' => 5,
    'G' => 3,
    'H' => 3,
    'I' => 2,
    'J' => 4,
    'K' => 3,
    'L' => 3,
    'M' => 3,
    'N' => 7,
    'O' => 6,
    'P' => 4,
    'Q' => 3,
    'R' => 3,
    'S' => 1,
    'T' => 2,
    'U' => 7,
    'V' => 7,
    'W' => 7,
    'X' => 1,
    'Y' => 2,
    'Z' => 3,
    );

my %lig_hash = ();

open HMMLIST, $hmmlist   or die $!;
open HMMDEF, ">$hmmdefs" or die $!;
print HMMDEF $header;

while (my $line = <HMMLIST>)
{
    chomp($line);
    print HMMDEF "~h \"$line\"\n";
    if ($line =~ /upp_([A-Z])-lig\+upp_([A-Z])/) # lig
    {
	my $e = $E_hash{$1};
	my $s = $S_hash{$2};
	my $lig = "lig_E$e"."S$s";

	push @{$lig_hash{$lig}}, $line;

	print HMMDEF $hmm_hash{$lig};
	#print "copy HMM: $lig -> $line\n";
    }
    else # char
    {
	print HMMDEF $hmm_hash{$line};
	#print "copy HMM: $line -> $line\n";
    }
}
close HMMDEF;
close HMMLIST;
print "Copy\tHMMs to $hmmdefs\n";


#===============================================
# Generate the tieTransP.hed
#===============================================
open HED, ">$tieTranspHed" or die $!;
foreach my $k (sort keys %lig_hash)
{
    my $ligs = join(',', @{$lig_hash{$k}});
    print HED "TI T_$k {($ligs).transP}\n";
}
close HED;
print "Create\t$tieTranspHed\n";


#===============================================
# HHEd to tie the tranP with tieTransP.hed
#===============================================
system("HHEd -H $hmmdefs -M $outDir $tieTranspHed $hmmlist");
print "HHEd ties transP in $hmmlist\n";


#===============================================
# HERest twice
#===============================================
my $outDir1 = "$path/trihmm1";
my $outDir2 = "$path/trihmm2";
unless(-d $outDir1){ make_path $outDir1; }
unless(-d $outDir2){ make_path $outDir2; }

system("HERest -A -I $MLF -s $outDir1/stats1.txt -S $trnSCP -H $hmmdefs -M $outDir1 $hmmlist");
system("HERest -A -I $MLF -s $outDir2/stats2.txt -S $trnSCP -H $outDir1/hmmdefs -M $outDir2 $hmmlist");

