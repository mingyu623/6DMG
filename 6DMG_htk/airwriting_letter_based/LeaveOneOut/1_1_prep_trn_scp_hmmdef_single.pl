#!/usr/bin/perl
# Mingyu @ Apr 22 2013 [ Leave-One-Out cross validation on CLEAN detection results]
# 1.  Generate the training script for 100 words
# 2.  Generate the mono-char, tri-lig lable files (mlf) for 100 words
# 3.1 Create the hmmList (triligHmmlist)
# 3.2 Create the full hmmList (fulllist: 26 chars + 26x26 ligs + fil)
# 4.  A stats for the triligHmmlist
# 5.1 Clone the lig  models from multi_lig2 (after HERest) for the initial values of trilig
# 5.2 Clone the char models from multi_lig2 (after HERest) for the initial values of chars
# 5.3 Clone the fil  model  from word_spot_word_based (after HERest) for the initial values of fil
# 5.4 Generate "trihmm0/hmmdefs" (5.1 + 5.2 + 5.3)
# 6   Create tieTransP.hed & use HHEd to tie the transition prob of "trihmm0/hmmdefs"
# 7   Run HERest twice trihmm0/hmmdefs -> trihmm1/hmmdefs -> trihmm2/hmmdefs

use strict;
use File::Copy;
use File::Path qw(make_path);
use Cwd qw(abs_path);

my $dtype;
my $tstUsr;
if ($#ARGV !=1)
{
    print "usage: prep_trn_scp_mlf_hmmdefs [datatype] [tst usr]\n";
    print " [tst usr]: the leave-one-out test user\n";
    exit;
}
else
{
    $dtype = $ARGV[0];
    $tstUsr   = $ARGV[1];
}
my $path = "products/$dtype/$tstUsr";
unless(-d $path){ make_path $path; }
my $MLF       = "$path/mono_char_tri_lig.mlf";
my $trnSCP    = "$path/train.scp";
my $hmmlist   = "$path/triligHmmlist";
my $fulllist  = "$path/fulllist";
my $STAT      = "$path/trilig_stats.txt";

my @words_common = (  # 100 common words
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

my @usrs = ("M1", "C1", "J1", "C3", "C4",
            "E1", "U1", "Z1", "I1", "L1",
	    "Z2", "K1", "T2", "M3", "J4",
	    "D1", "W1", "T3");

my %trilig_hash = ();

my @trnUsrs;
foreach (@usrs){
    if ($_ ne $tstUsr){
	push(@trnUsrs, $_);
    }
}

#=======================================================
# Create mono char + tri_lig MLF
# All words from recording (not detection)
#=======================================================
my $detBaseDir = "../../../data_htk/airwriting_spot";
$detBaseDir = abs_path($detBaseDir);
my $truthDir = "$detBaseDir/truth/data_$dtype";
unless (-d $truthDir) {
    die "truthDir doesn't exist at $truthDir!\n";
}
my @recs = glob($truthDir."/*.htk");

open MLF, ">$MLF" or die $!;
print MLF "#!MLF!#\n";
foreach my $rec (@recs)
{
    $rec =~ m/([A-Z][0-9])_([A-Z]+).htk/;
    my $u = $1;
    my $w = $2;

    my @sub_chars = split(undef, $w);
    my $chars = "fil\n"; # force fil at start
    my $chars = $chars."upp_$sub_chars[0]\n"; 
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $E = $sub_chars[$i-1];
	my $S = $sub_chars[$i];
	my $lig = "upp_$E-lig+upp_$S";
	$chars = $chars."$lig\n"."upp_$S\n";
	
	$trilig_hash{$lig} += 1;
    }
    $chars = $chars."fil\n"; # force fil at end

    my $fn = sprintf("%s_%s.lab", $u, $w);
    print MLF "\"*/$fn\"\n";
    print MLF $chars;
    print MLF ".\n";
}

close MLF;
print "Create\t$MLF (full recordings)\n";

#=======================================================
# Create train.scp
# The train & (test) scripts use the detected results!
#=======================================================
my $detDir = "$detBaseDir/train/data_$dtype";

open trnSCP, ">$trnSCP" or die $!;

my @dets = glob("$detDir/*.htk"); # glob returns full path
foreach my $det (@dets)
{
    $det =~ m/([A-Z][0-9])_([A-Z]+).htk$/;
    if ($1 eq $tstUsr){
        # do nothing
    }
    else{
	print trnSCP "$det\n";
    }
}
close trnSCP;
print "Create\t$trnSCP\n";


#=======================================================
# Create triligHmmlist & fulllist
#=======================================================
open HMMLIST, ">$hmmlist" or die $!;
open STAT,    ">$STAT" or die $!;
print HMMLIST "fil\n";
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
print FULLLIST "fil\n";
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
# store srcHmmdef (chars, ligs) & filHmmdef (fil) into hash first
#=======================================================
my $srcHmmdef = "../../words_word_based/char_lig/$dtype/Extension/iso/hmm3/hmmdefs_iso";
my $filHmmdef = "products/$dtype/fil";
my $outDir  = "$path/trihmm0";
my $hmmdefs = "$outDir/hmmdefs";
my $tieTranspHed = "$outDir/tieTransP.hed";
unless (-d $outDir){ make_path $outDir; }

my $header;
my %hmm_hash = ();
open SRC, $srcHmmdef or die $!;
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

open SRC, $filHmmdef or die $!;
while(my $line = <SRC>)
{
    if ($line =~ /^~h "(.*)"/) # start of a HMM (lig)
    {
	my $hmmName = $1;
	my $model = "";
	while (my $content = <SRC>)
	{
	    $model = $model.$content;
	    if ($content =~ /^<ENDHMM>/){ last; }
	}
	$hmm_hash{$hmmName} = $model;
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

