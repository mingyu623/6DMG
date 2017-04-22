#!/usr/bin/perl
# Mingyu @ Apr 26 2013 [ Leave-One-Out cross validation on GROUND TRUTH]
# 1. Generate the testing scripts of common/OOV for a specific test user    
# 2. Generate the corresponding det_ref.mlf for HResults

use strict;
use File::Path qw(make_path);
use Cwd qw(abs_path);

my $dtype;
my $tstUsr;

if ($#ARGV !=1)
{
    print "usage: prep_tst_scp_single [datatype] [tst usr]\n";
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
my $detBaseDir = "../../../data_htk/airwriting_spot/";
$detBaseDir = abs_path($detBaseDir);
my $truthDir = "$detBaseDir/truth/data_$dtype";
my $logDir   = "$detBaseDir/log/data_$dtype"; 
unless (-d $logDir) { die "logDir doesn't exist at $logDir!\n"; }

# output
my $tstSCP    = "$path/test.scp";
my $tstOovSCP = "$path/testOOV.scp";
my $detMLF    = "$path/det_ref.mlf";


#=======================================================
# 1. Create tst.scp & tstOOV.scp
#=======================================================
open tstSCP,   ">$tstSCP"    or die $!;
open tstOovSCP,">$tstOovSCP" or die $!;

my @segs = glob("$truthDir/$tstUsr\_*.htk"); # glob returns full path
foreach my $seg (@segs)
{
    if ($seg =~ m/[A-Z][0-9]_([A-Z]+).htk$/)
    {
        if (exists $words_hash{$1}){
            print tstSCP "$seg\n";
        }
        else{
            print tstOovSCP "$seg\n";
        }
    }
}
close tstSCP;
close tstOovSCP;

print "Create\t$tstSCP\n";
print "\t$tstOovSCP\n";


#=======================================================
# Generate det_ref.mlf for HResults
#=======================================================
open MLF, ">$detMLF" or die $!;
print MLF "#!MLF!#\n";

foreach my $seg (@segs)
{    
    if ($seg =~ m/[A-Z][0-9]_([A-Z]+).htk$/)
    {
        my @chars = split(undef, $1);
        print MLF "\"*/$tstUsr\_$1$2.lab\"\n";  
        print MLF join("\n", @chars);
        print MLF "\n.\n";
    }
}

close MLF;
print "Create\t$detMLF (for HResults)\n"
