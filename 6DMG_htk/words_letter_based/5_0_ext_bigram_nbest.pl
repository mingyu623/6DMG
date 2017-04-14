#!/usr/bin/perl
# Mingyu @ May 8 2013    [test on the extention voc-1k of M1 data]
# Use bigram network with nbest decoding
# HVite with test.scp => dec.mlf
# HResults dec.mlf

use strict;
use File::Path qw(make_path);
use File::stat;

my $data_dir;
my $dtype;
my $treeNum;
my $usr = "M1";
my $voc;
my $nbest = 5;  # set to 1, 2, 3, or 5
if ($#ARGV !=3)
{
    print "usage: viterbi [data_dir] [datatype] [tree#] [voc]\n";
    print " [tree#]= 0: use the hmmdefs from decision tree 0\n";
    print "          1: use the hmmdefs from decision tree 1 (3 subtrees)\n";
    print " [voc]     : 1k, 1kf, or 100k\n";
    exit;
}
else
{
    $data_dir= $ARGV[0];
    $dtype   = $ARGV[1];
    $treeNum = $ARGV[2];
    $voc     = $ARGV[3];
    if ($treeNum!=0 && $treeNum!=1){
	die "incorrect tree#: $treeNum\n";
    }
    if ($voc ne "1k" and $voc ne "1kf" and $voc ne "100k"){
	die "incorrect wdnet with voc $voc\n";
    }
}
#input
my $path     = "products/$dtype/$usr";
my $treeDir  = "$path/tree$treeNum";
my $hmmdefs  = "$treeDir/trihmm5/hmmdefs";
my $dict     = "$treeDir/fullDict";
my $hmmlist  = "$treeDir/tiedlist";
my $wdnet    = "share/wdnet_bigram_$voc";
my $refMlf   = "share/word_ref.mlf";

#output
my $dec = "$treeDir/dec_ext_bigram_$voc\_nbest.mlf";

# sanity check for required input files
unless (-f $hmmdefs) {
    die "Please generate M1's hmmdefs first with:\n".
        " 1_0_prep_trn_scp_mlf_hmmdefs.pl $data_dir $dtype $usr\n".
        " 2_0_make_tree.pl $dtype $usr\n".
        " 2_1_make_subtree.pl $dtype $usr\n";
}
unless (-f $wdnet) {
    if (substr($voc, -1) eq 'f') {
        my $sub_voc = substr($voc, 0, -1);
        die "Please generate wdnet_bigram_$voc with\n".
            " 0_1_generate_wdnet_bigram.pl $sub_voc 0\n";
    } else {
        die "Please generate wdnet_bigram_$voc with\n".
            " 0_1_generate_wdnet_bigram.pl $voc 1\n";
    }
}

#=======================================================
# Generate the test script
#=======================================================
my @exp_words = (
    "THE", "OF",  "AND", "TO",  "IN",  "FOR", "IS",  "THA", "PRO", "THI", 
    "ON",  "WIT", "BY",  "COM", "NOT", "IT",  "ARE", "OR",  "CON", "NEW", 
    "BE",  "FRO", "AT",  "AS",  "ALL", "STA", "RES", "USE", "PRI", "MOR", 
    "HAV", "WAS", "CAN", "AN",  "INT", "SHO", "WIL", "SER", "WOR", "HOM", 
    "WE",  "ABO", "INF", "COU", "PAG", "CAR", "ONL", "US",  "SEA", "WHI", 
    "PAR", "POS", "IF",  "TIM", "FRE", "REA", "OTH", "WHE", "SIT", "PLA", 
    "PER", "MAN", "BUT", "DAT", "MY",  "OFF", "HAS", "ONE", "HER", "EVE", 
    "STO", "OUR", "ADD", "PRE", "FIN", "LIN", "NO",  "LIS", "DO",  "ACC", 
    "TRA", "INC", "OUT", "SEE", "CHA", "WEB", "HIS", "UNI", "MAY", "IND", 
    "HE",  "UP",  "ANY", "WHA", "MAR", "SEC", "HEA", "REP", "YEA", "THR", 
    "SOM", "WHO", "PHO", "HEL", "BUS", "MUS", "DAY", "APP", "ART", "RAT", 
    "HOW", "TOP", "HOT", "STU", "REC", "SEL", "GET", "MEM", "VIE", "ACT", 
    "DIS", "FIR", "BOO", "JAN", "LEA", "CLI", "SO",  "REL", "SUP", "POL", 
    "DES", "REV", "PUB", "MAI", "REG", "MON", "RIG", "ALS", "ITE", "SOU", 
    "SYS", "RE",  "PM",  "GRO", "NOW", "LOC", "VER", "MAK", "SPE", "OVE", 
    "DEV", "CHI", "ITS", "LIK", "BEE", "ME",  "HOU", "WER", "INS", "AM",  
    "CAL", "FIL", "WOU", "GAM", "CEN", "BAS", "DOW", "NAM", "DIR", "COL", 
    "THO", "TEC", "BAC", "SCH", "SUB", "NEE", "JUS", "CRE", "MOV", "GOO", 
    "BUY", "MES", "HIG", "KNO", "REQ", "PEO", "HAD", "FRI", "WEL", "NAT", 
    "PIC", "SEN", "GRE", "NET", "TAK", "COP", "ADV", "MED", "AVA", "BEC", 
    "ASS", "TOO", "LAS", "VID", "FEE", "CAS", "DEC", "SUC", "TWO", "CIT", 
    "ENT", "EMA", "NUM", "AUT", "GO",  "STR", "NEX", "MOS", "OPE", "DET", 
    "LON", "FOU", "UND", "SEX", "WIN", "GEN", "FUN", "SET", "MOD", "LOO", 
    "CAT", "ORD", "ENG", "SOF", "BET", "SIN", "CLA", "AFT", "PLE", "FAC", 
    "TER", "AME", "SHE", "BES", "MIN", "MAT", "CHE", "POW", "WAY", "SHA", 
    "JOB", "EXP", "SIG", "SAI", "AGE", "FUL", "SAM", "SPO", "PAY", "EAC", 
    "RET", "WAT", "SAL", "WAN", "OWN", "EST", "EAS", "NOR", "TEX", "VAL", 
    "IMP", "FOL", "SHI", "TYP", "EDU", "LOG", "DE",  "MIL", "GIV", "DOE", 
    "CUS", "CUR", "QUE", "IMA", "LIV", "ISS", "LIF", "CAM", "GUI", "DVD", 
    "WRI", "WOM", "SEP", "EDI", "LAT", "OCT", "FAM", "HAR", "ELE", "NOV", 
    "TEA", "EBA", "PAS", "WEE", "BEF", "DID", "ROO", "DIF", "BLO", "SAY", 
    "TEL", "EFF", "NON", "MEN", "POR", "USI", "MAD", "AGA", "BOT", "END", 
    "LOW", "LEV", "UK",  "MEA", "DEA", "FEA", "LAR", "SOC", "JUN", "HIM", 
    "REM", "LAW", "COS", "FOO", "COD", "JUL", "TIT", "BOA", "VIS", "POI", 
    "EUR", "LAN", "QUA", "BRO", "APR", "KIN", "UPD", "SIM", "TEE", "AUG", 
    "TOD", "BLA", "JOI", "OLD", "LIT", "SPA", "BUI", "BEI", "MUC", "FEB", 
    "WES", "SMA", "SCI", "GRA", "STE", "BEL", "GIF", "TES", "JOH", "MIC", 
    "MET", "GIR", "AWA", "RED", "ANO", "SOL", "MEE", "DEP", "DEL", "GOL", 
    "BEA", "POP", "PAP", "COR", "BIG", "OPT", "SON", "SIZ", "LET", "TOT", 
    "DUR", "HAN", "SUR", "GOV", "AUS", "LES", "AIR", "USA", "ARC", "DIG", 
    "FRA", "LOA", "ANN", "LOV", "RUN", "HOS", "GAL", "WHY", "WED", "EAR", 
    "SUN", "DOC", "CLO", "CD",  "REF", "LOS", "THU", "PUR", "KEY", "SAV", 
    "ENV", "AMO", "FLO", "CHR", "PAC", "AGR", "QUI", "RAN", "VAR", "ANA", 
    "SAN", "TRU", "LEF", "EQU", "YOR", "TAX", "EXA", "STI", "IDE", "TRY", 
    "BRI", "GAY", "PAT", "ASK", "AVE", "ARO", "LEG", "FIE", "EXC", "BOX", 
    "LIB", "LA",  "DAV", "HUM", "QUO", "WAR", "VE",  "DRI", "TAB", "BAN", 
    "COV", "MIS", "FUR", "EMP", "DEF", "TOW", "CEL", "YAH", "REN", "TRE", 
    "NEV", "YES", "LL",  "MAJ", "SAF", "CLE", "MAG", "GOI", "SAT", "LIG", 
    "FAS", "ECO", "ISL", "MOB", "SID", "CHO", "SUM", "GER", "EXT", "MAC", 
    "HOL", "VIR", "RUL", "SCO", "BRA", "ALT", "BOD", "ST",  "PC",  "TRI", 
    "LIM", "GOT", "FEW", "TUE", "CAP", "FAR", "POK", "MUL", "CLU", "FAQ", 
    "SEV", "ROA", "NIG", "AL",  "TAL", "AFF", "BIL", "INV", "YET", "LOT", 
    "SKI", "TOU", "MIG", "ANI", "OPP", "FUT", "SOR", "TUR", "KEE", "BLU", 
    "AFR", "ASI", "CER", "JAP", "HAL", "MAS", "AUD", "BEN", "DIE", "BEG", 
    "CO",  "ALW", "ENE", "BAB", "WAL", "FAX", "CA",  "ORG", "ALO", "ONC", 
    "PRA", "HAP", "ORI", "DOM", "RSS", "RAD", "BOY", "ID",  "II",  "GEO", 
    "ABL", "FIG", "DRU", "VOL", "WIS", "UNT", "PUT", "FAI", "DAI", "GOD", 
    "SCR", "WRO", "WEA", "ERR", "STY", "URL", "DON", "GAR", "NEA", "ADU", 
    "AGO", "FED", "TIC", "USU", "VOI", "CUL", "EIT", "MOT", "BAD", "TIP", 
    "FLA", "RIS", "UPO", "ROC", "MID", "GLO", "LYR", "ATT", "JOU", "ALR", 
    "ITA", "DUE", "ANS", "PLU", "WEI", "OFT", "VIA", "POO", "SPR", "AMA", 
    "WID", "PET", "ET",  "CAU", "CRI", "TOG", "NUD", "LIC", "WIR", "CHU", 
    "JAM", "FIV", "DAN", "ACA", "PAI", "ENO", "OIL", "KIT", "EXI", "ELS", 
    "PAU", "EXE", "MAX", "ALB", "ADM", "DOI", "DOG", "PAN", "DOU", "BIT", 
    "FIT", "BAR", "IRA", "RIC", "OBJ", "NY",  "USR", "CRO", "ACR", "RUS", 
    "NEC", "FUC", "BEH", "LAK", "GAS", "BRE", "TOY", "OH",  "EYE", "DIV", 
    "HIT", "ROB", "BAY", "WEN", "CAB", "DC",  "FAT", "CNE", "EN",  "MAL", 
    "GOA", "FAL", "FEM", "AD",  "HTM", "MOU", "GUY", "BED", "JAC", "SOO", 
    "NAV", "OBT", "ROL", "GUE", "OPI", "GLA", "FAV", "EG",  "ROU", "ANT", 
    "ALM", "ONT", "YEL", "HAI", "POT", "HUG", "LOU", "TEN", "HP",  "INN", 
    "BUD", "GMT", "HOR", "WAI", "PDF", "SMI", "HEN", "MEX", "TX",  "JEW", 
    "RIV", "TOL", "IP",  "HOP", "ENS", "ESP", "FIX", "ORA", "ALA", "RAC", 
    "VAC", "PA",  "SIX", "RD",  "MD",  "LTD", "IRE", "ZIP", "EVI", "VAN", 
    "HIL", "FAN", "RIN", "BIN", "NIC", "MS",  "BAL", "PUS", "AUC", "NOK", 
    "ELI", "DEG", "WON", "DAR", "BAT", "WOO", "XML", "SIL", "CIV", "ISB", 
    "IE",  "ABI", "PST", "ETC", "BOS", "BID", "III", "OK",  "USB", "FL",  
    "LEN", "MA",  "FOC", "MSN", "MB",  "PHE", "LE",  "OHI", "AZ",  "CUT", 
    "UNL", "TOM", "MIK", "PHY", "SAW", "JER", "HI",  "ANG", "INP", "BIB", 
    "GOE", "ILL", "PHP", "JAV", "DOO", "IL",  "ZEA", "LLC", "WIF", "LOR", 
    "NC",  "LEE", "VOT", "IBM", "MR",  "ROY", "OS",  "ENJ", "ISR", "ARG", 
    "KAN", "MM",  "ND",  "NAK", "BOR", "MYS", "JIM", "PP",  "GAV", "DEE", 
    "BOB", "ARI", "VEH", "VA",  "TAR", "XXX", "VEG", "SC",  "IMM", "PEN", 
    "CUM", "PIE", "ENA", "SCA", "JON", "BON", "COA", "COO", "PO",  "TH",  
    "ORE", "KON", "GA",  "LED", "ABS", "SES", "BEY", "DEM", "EL",  "PAL", 
    "MOM", "JOE", "JES", "RAP", "INI", "FIC", "SUI", "KM",  "WWW", "FEL", 
    "LCD", "WA",  "NJ",  "EU",  "DAK", "XP",  "JUM", "ARM", "XBO", "KNE", 
    "HON", "VHS", "IOW", "DAM", "COC", "BOU", "AU",  "FIS", "CDS", "IPO", 
    "HAW", "TEM", "ATL", "USD", "DEB", "LAC", "KOR", "AVO", "EVA", "SLI", 
    "MI",  "DOL", "GON", "KB",  "DJ",  "DAL", "PHI", "DR",  "JOS", "DI",  
    "BYT", "GEA", "BC",  "DIA", "TOR", "AC",  "DIC", "OKL", "ESS", "KEP", 
    "TAS", "EDG", "DRO", "PEA", "ZON", "MIA", "NT",  "AID", "SUG", "EIG", 
    "GAI", "GB",  "SD",  "CUP", "ACH", "CT",  "NEG", "ZUM", "PHA", "HIV", 
    "VS",  "APA", "IV",  "DNA", "AR",  "ASP", "UTA", "POC", "SEQ", "ADO", 
    "KEN", "CIS", "DED", "CM",  "SRC", "UPG", "MO",  "UNK", "ED",  "OCC", 
    "SA",  "SWI", "PDA", "DU",  "MER", "NA",  "VIC", "ERI", "ICO", "DSL", 
    "VIL", "TAY", "NE",  "GUA", "FUE", "IRI", "EM",  "TN",  "ROS", "DAU", 
    "AOL", "SWE", "UTC", "CIR", "ORL", "JEF", "SYD", "FES", "UPP", "KEV", 
    "UN",  "SQL", "ABU", "ADS", "RAI", "VOY", "MN",  "GPS", "EAT", "LAB", 
    "PDT", "EME", "EDW", "PR",  "AVG", "TON", "HAM", "BUR", "NUR", "AHE", 
    "PIN", "OZ",  "OBS", "ATO", "VIO", "EPI", "SQU", "COF", "NUC", "ARK", 
);
my $tstScp   = "$path/test_ext.scp";
open FILE_tst, ">$tstScp";
foreach my $w (@exp_words)
{
    my $tst_name = sprintf("%s_M1_t01.htk", $w);
    print FILE_tst "$data_dir/data_$dtype/$tst_name\n";
}
close FILE_tst;


#=======================================================
# HVite + HResults for test.scp
#=======================================================
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$treeDir/log_dec_ext_bigram_$voc"."_nbest.log") or die $!;
open (STDERR, ">$treeDir/err_dec_ext_bigram_$voc"."_nbest.log") or die $!;

if ($nbest <= 1) {
    system("HVite -A -T 1 -s 15.0 -H $hmmdefs -S $tstScp -i $dec -w $wdnet $dict $hmmlist");
} else {
    system("HVite -A -T 1 -n $nbest $nbest -s 15.0 -H $hmmdefs -S $tstScp -i $dec -w $wdnet $dict $hmmlist");
}

foreach my $n (1, 2, 3, 5) {
    if ($n <= $nbest) {
        system("HResults -A -d $n -I $refMlf $hmmlist $dec");
    }
}

open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
close REGOUT;
close STDERR;


# Finish: clean up
if (stat("$treeDir/err_dec_ext_bigram_$voc"."_nbest.log")->size == 0) # no stderr
{
    unlink("$treeDir/err_dec_ext_bigram_$voc"."_nbest.log");
}
