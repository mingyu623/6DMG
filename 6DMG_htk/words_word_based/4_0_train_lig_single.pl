#!/usr/bin/perl
# Mingyu @ Feb 21 2013
# 1. Train the ligature model with existing motion char models (1_build_iso_char_hmm.pl)
# 2. The dictionary, word network & HMM list are constructed by (2_dict_wdnet_prepare.pl)
# 3. Read hmmList and merge A-Z + multi-lig HMMs in one macro file
# 4. Embedded re-estimate A-Z + multi-lig HMMs
# 5. The training data comes from 40-word dictionary by 22 users.  
# 6. The testing data is extension word set (1000 words) by M1.

use strict;
use File::Path qw(make_path remove_tree);
use File::Copy;
use File::stat;

my $data_dir;
my $dtype;
my $run;
my $tstUsr = "M1";
my $ligModel;
if ($#ARGV !=2)
{
    print "usage: train_lig [data_dir] [datatype] [lig model]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    print " [lig model]= flat : use the HCompV flat start initial for lig models\n";
    print "              iso  : use the manually segmented iso lig from M1's data\n";
    print "              tie  : use tie-state lig models\n";  
    exit;
}
else
{
    $data_dir = $ARGV[0];
    $dtype    = $ARGV[1]; # "AW", "PO", etc.
    $ligModel = $ARGV[2];
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

my $path = "char_lig/$dtype/Extension/$ligModel";
my @usrs = ("A1", "C1", "C2", "C3", "C4",
	    "E1", "G1", "G2", "G3", "I1",
	    "I2", "I3", "J1", "J3", "L1",
	    "M1", "S1", "U1", "Y1", "Y3",
	    "Z1", "Z2");
my @trnUsrs = @usrs;

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

#!! dtype independent variables !!
my $charMlf = "mlf/char_lig.mlf"; # char level mlf (w/ lig)
my $wordMlf = "mlf/word.mlf";     # word level mlf
my $hmmList = "char_lig/hmmList"; # hmmList0 contains A-Z + lig HMMs
my $dict_trn  = "char_lig/dict_trn";
my $wdnet_trn = "char_lig/wdnet_trn";
my $dict_exp  = "char_lig/dict_exp";
my $wdnet_exp = "char_lig/wdnet_exp";

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
foreach my $w (@exp_words)
{
    my $tst_name = sprintf("%s_M1_t01.htk", $w);
    print FILE_tst "$data_dir/data_$dtype/$tst_name\n";
}
close FILE_trn;
close FILE_tst;

open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/../log_$ligModel.txt") or die $!;
open (STDERR, ">$path/../err_$ligModel.txt") or die $!;

#-------------------------------------------------------------------------
# 1. HCompV: Initialize the "lig" model (output to hmm0)
# 2. Read the existing A-Z HMMs from iso_char
# 3. Generate the HMM macro file
#-------------------------------------------------------------------------
#*******************************************************
# flat: HCompV initializes the lig HMMs (the same initial values for all ligs)
#*******************************************************
my $proto = "proto/$dtype/template_3";
unless(-e $proto){ system("perl 0_gen_single_proto.pl $dtype 3"); }

# update variance only (0 mean)
system("HCompV $opt -v 0.0001 -I $charMlf -S $trn_script -M $hmm0 -o lig $proto");
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

## Mingyu:(temporally hack, $usr = LeaveOneOut)
#my $src_dir = "iso_char/$dtype/$usr/hmm2";
my $src_dir = "iso_char/$dtype/all/hmm2";
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
# 1. E6S2, E6S3, E7S3 are too short, and we use the HComp initial for HERest
# 2. E4S3/E5S3 use extra words from trn_words_E4S3/trn_words_E5S3
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
    close HMM_LIST;
}


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
#system("HVite $opt -H $hmm3/$hmmdefs -i $path/trn_align.mlf -m -y htk -I $wordMlf -S $trn_script $dict_trn $hmmList");

# Evaluation
#system("HVite $opt -H $hmm3/$hmmdefs -S $trn_script -i $trn_mlf -w $wdnet_trn $dict_trn $hmmList");
system("HVite $opt -H $hmm3/$hmmdefs -S $tst_script -i $tst_mlf -w $wdnet_exp $dict_exp $hmmList");
#system("HResults $opt -I $wordMlf $hmmList $trn_mlf");
system("HResults $opt -I $wordMlf $hmmList $tst_mlf");

#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/../err_$ligModel.txt")->size == 0) # no stderr
{
    unlink("$path/../err_$ligModel.txt");
}
