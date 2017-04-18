#!/usr/bin/perl
# Mingyu @ Apr 25 2013 [ Leave-One-Out cross validation on detection]
# 1. Generate the testing script for all various cases of detection results
#    1) precise:     precise detection, i.e., head/tail offset < 50 and overlap > 80%
#    2) imprecise:   
#    3) false alarm: nonoverlap with length >  60
#    4) discard:     nonoverlap with length <= 60 (won't even pass to recognizer)
#    ! words in HandLabel_result need extra care
#
# 2. Generate the corresponding det_ref.mlf for HResults

use strict;
use Cwd qw(abs_path);

my $dtype;
my $tstUsr;

if ($#ARGV !=1)
{
    print "usage: prep_tst_scp_single [datatype] [tst usr]\n";
    print "[tst usr]: the leave-one-out test user\n";
    exit;
}
else
{
    $dtype = $ARGV[0];
    $tstUsr   = $ARGV[1];
}

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

my @trnUsrs;
foreach (@usrs){
    if ($_ ne $tstUsr){
	push(@trnUsrs, $_);
    }
}

# input
my $detBaseDir = "../../../data_htk/airwriting_spot";
$detBaseDir = abs_path($detBaseDir);
my $logDir = "$detBaseDir/log/data_$dtype";
unless (-d $logDir) { die "logDir doesn't exist at $logDir!\n"; }
my $path = "products/$dtype/$tstUsr";

# output
my $tstSCP          = "$path/test.scp";
my $tstOovSCP       = "$path/testOOV.scp";
my $impreciseSCP    = "$path/imprecise.scp";
my $impreciseOovSCP = "$path/impreciseOOV.scp";
my $faSCP           = "$path/FA.scp";
my $detMLF          = "$path/det_ref.mlf";

#=======================================================
# Read "handLabel_result.txt" and generate outlier_hash (for fast lookup)
# C1_OPEN1	O
# C1_OPEN2	PEN
#=======================================================
my %outlier_hash;
open F_OUTLIER, "$logDir/handLabel_result.txt" or die $!;
while (my $line = <F_OUTLIER>)
{
    if ($line =~ m/^$tstUsr/)
    {
	my @tmp = split(' ', $line);
	$outlier_hash{$tmp[0]} = $tmp[1];
    }
}
close F_OUTLIER;

#=======================================================
# 1. Create tst.scp & tstOOV.scp (precise detections)
# 2. Create imprecise.scp & impreciseOOV.scp (imprecise detection)
# C1_ACCO	1 of 1
#=======================================================
open tstSCP,   ">$tstSCP"    or die $!;
open tstOovSCP,">$tstOovSCP" or die $!;
open F_PRECISE,"$logDir/precise_$tstUsr.txt"   or die $!;
while (my $line = <F_PRECISE>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	if (exists $words_hash{$1})
	{
	    print tstSCP "$detBaseDir/precise/data_$dtype/$tstUsr\_$1$2.htk\n";
	}
	else
	{
	    print tstOovSCP "$detBaseDir/precise/data_$dtype/$tstUsr\_$1$2.htk\n";
	}
    }
}
close F_PRECISE;
close tstSCP;
close tstOovSCP;

open tstSCP2,    ">$impreciseSCP" or die $!;
open tstOovSCP2, ">$impreciseOovSCP" or die $!;
open F_IMPRECISE, "$logDir/imprecise_$tstUsr.txt" or die $!;
while (my $line = <F_IMPRECISE>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d:\s(\d+)/)
    {
	if ($3 <= 60){ next; } # seg is too short: discard!
	my $fname = $tstUsr."_".$1.$2;	
	if (exists $words_hash{$1})
	{
	    print tstSCP2 "$detBaseDir/imprecise/data_$dtype/$fname.htk\n";
	}
	else
	{
	    print tstOovSCP2 "$detBaseDir/imprecise/data_$dtype/$fname.htk\n";
	}
    }
}
close F_IMPRECISE;
close tstSCP2;
close tstOovSCP2;
print "Create\t$tstSCP\n";
print "\t$tstOovSCP\n";
print "\t$impreciseSCP\n";
print "\t$impreciseOovSCP\n";

#=======================================================
# Create false_alarm.scp
#=======================================================
open tstFASCP, ">$faSCP" or die $!;

open F_FalseAlarm, "$logDir/falsealarm_$tstUsr.txt" or die $!;
while (my $line = <F_FalseAlarm>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	print tstFASCP "$detBaseDir/falsealarm/data_$dtype/$tstUsr\_$1$2.htk\n";
    }
}

close F_FalseAlarm;
close tstFASCP;
print "Create $faSCP\n";


#=======================================================
# Generate det_ref.mlf for HResults
# The MLF contains the lables for:
# 1. precise
# 2. imprecse (+ handLabel_result)
# 3. false alarm (if any)
#=======================================================
open MLF, ">$detMLF" or die $!;
print MLF "#!MLF!#\n";

open F_PRECISE,   "$logDir/precise_$tstUsr.txt"   or die $!;
while (my $line = <F_PRECISE>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	my @chars = split(undef, $1);
	print MLF "\"*/$tstUsr\_$1$2.lab\"\n";	
	print MLF join("\n", @chars);
	print MLF "\n.\n";
    }
}
close F_PRECISE;


open F_IMPRECISE, "$logDir/imprecise_$tstUsr.txt" or die $!;
while (my $line = <F_IMPRECISE>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d:\s(\d+)/)
    {
	if ($3<=60) { next; } # too short: discard
	my $fname = $tstUsr."_".$1.$2;
	my @chars;
	if (exists $outlier_hash{$fname}) # check if it needs handlabel
	{
	    if ($outlier_hash{$fname} eq '.'){
		@chars = ("FIL");
	    }else{
		@chars = split(undef, $outlier_hash{$fname});
	    }
	}
	else
	{
	    @chars = split(undef, $1);
	}
	print MLF "\"*/$tstUsr\_$1$2.lab\"\n";	
	print MLF join("\n", @chars);
	print MLF "\n.\n";	
    }
}
close F_IMPRECISE;


open F_FalseAlarm, "$logDir/falsealarm_$tstUsr.txt" or die $!;
while (my $line = <F_FalseAlarm>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	print MLF "\"*/$tstUsr\_$1$2.lab\"\n";
	print MLF "FIL\n.\n";
    }
}
close F_FalseAlarm;


close MLF;
print "Create $detMLF (for HResults)\n"
