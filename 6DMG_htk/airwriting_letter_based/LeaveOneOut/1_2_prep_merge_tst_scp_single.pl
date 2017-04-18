#!/usr/bin/perl
# Mingyu @ Apr 23 2013 [ Leave-One-Out cross validation on MERGED detection]
# 1. Generate the testing script for all various cases of merged detection results
#    1) precise:     precise detection, i.e., head/tail offset < 50 and overlap > 80%
#    2) imprecise:   
#    3) false alarm: nonoverlap with length >  60
#    4) discard:     nonoverlap with length <= 60 (won't even pass to recognizer)
#    ! words in outliers needs extra care (should be excluded from imprecise set)
#
# 2. Generate the corresponding merge_ref.mlf for HResults

use strict;
use Cwd qw(abs_path);

my $dtype;
my $tstUsr;

if ($#ARGV !=1)
{
    print "usage: prep_merge_tst_scp_single [datatype] [tst usr]\n";
    print " [tst usr]: the leave-one-out test user\n";
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
my $detBaseDir = "../../../data_htk/airwriting_spot_merge";
$detBaseDir = abs_path($detBaseDir);
my $logDir = "$detBaseDir/log/data_$dtype";
unless (-d $logDir) { die "logDir doesn't exist at $logDir!\n"; }
my $path = "products/$dtype/$tstUsr";
unless(-d $path){ make_path $path; }

# output
my $merge_tstSCP          = "$path/merge_tst.scp";
my $merge_tstOovSCP       = "$path/merge_tstOOV.scp";
my $merge_impreciseSCP    = "$path/merge_imprecise.scp";
my $merge_impreciseOovSCP = "$path/merge_impreciseOOV.scp";
my $merge_FaSCP     = "$path/merge_FA.scp";
my $merge_MLF       = "$path/merge_ref.mlf";

#=======================================================
# Read "outlier.txt" and generate outlier_hash (for fast outlier lookup)
# "outliers" are imcomplete words even after merge 
# U1_LIVI2	LIV
#=======================================================
my %outlier_hash;
open F_OUTLIER, "$logDir/outlier.txt" or die $!;
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
# 1. Create merge_tst.scp & merge_tstOOV.scp (precise detections)
# 2. Create merge_imprecise.scp & merge_impreciseOOV.scp (imprecise detections)
# The "outliers" should be excluded
#=======================================================
open tstSCP,   ">$merge_tstSCP"    or die $!;
open tstOovSCP,">$merge_tstOovSCP" or die $!;
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

open tstSCP2,    ">$merge_impreciseSCP" or die $!;
open tstOovSCP2, ">$merge_impreciseOovSCP" or die $!;
open F_IMPRECISE, "$logDir/imprecise_$tstUsr.txt" or die $!;
while (my $line = <F_IMPRECISE>)
{
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	my $fname = $tstUsr."_".$1.$2;
	if (exists $outlier_hash{$fname}) # check if it's an outlier
	{
	    next;
	}
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
print "Create\t$merge_tstSCP\n";
print "\t$merge_tstOovSCP\n";
print "\t$merge_impreciseSCP\n";
print "\t$merge_impreciseOovSCP\n";

#=======================================================
# Create false_alarm.scp
#=======================================================
open tstFASCP, ">$merge_FaSCP" or die $!;

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
print "Create $merge_FaSCP\n";


#=======================================================
# Generate merge_ref.mlf for HResults
# The MLF contains the lables for:
# 1. precise
# 2. imprecse + outlier (if any)
# 3. false alarm (if any)
#=======================================================
open MLF, ">$merge_MLF" or die $!;
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
    if ($line =~ m/^$tstUsr\_([A-Z]+)\s(\d) of \d/)
    {
	my $fname = $tstUsr."_".$1.$2;
	my @chars;
	if (exists $outlier_hash{$fname}) # check if it's an outlier
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
print "Create $merge_MLF (for HResults)\n"
