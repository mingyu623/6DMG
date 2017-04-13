#!/usr/bin/perl
# Mingyu @ Oct 14 2012
# 1. Use A-Z + "multi-lig" HMMs for motion word modeling
# 2. Use the iso char HMMs built from 1_build_iso_char_hmm.pl
# 3. Generate the wdnet and dict for the motion word recognition task
# 4. Convert the word level mlf (word.mlf) to char level mlf (char_lig.mlf)

use strict;
use File::Path qw(make_path remove_tree);

my $path = "char_lig";
unless (-d $path){ make_path "$path" };

my @words = (
    #===== set 1 =====
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
    
    #===== set 2 =====
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

    #===== set 3 =====
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

    #===== set 4 =====
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
my @trn_words = (@words, @trn_words_E4S3, @trn_words_E5S3);

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

my @chars = (
	  "upp_A",
	  "upp_B",
	  "upp_C",
	  "upp_D",
	  "upp_E",
	  "upp_F",
	  "upp_G",
	  "upp_H",
	  "upp_I",
	  "upp_J",
	  "upp_K",
	  "upp_L",
	  "upp_M",
	  "upp_N",
	  "upp_O",
	  "upp_P",
	  "upp_Q",
	  "upp_R",
	  "upp_S",
	  "upp_T",
	  "upp_U",
	  "upp_V",
	  "upp_W",
	  "upp_X",
	  "upp_Y",
          "upp_Z"
);

#******************************************
# The one I will use for multi-lig(2) models
#S1: BDEFHKLMNPRTUVWXYZ
#S2: AIJOQ
#S3: CGS
#
#E1: BDSX
#E2: ITY
#E3: CEGHKLMQRZ
#E4: JP
#E5: AF
#E6: O
#E7: NUVW
#******************************************
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

foreach my $s (1..3)
{
    print "S$s: ";
    for my $key (sort keys %S_hash)
    {
	if ($S_hash{$key}==$s)
	{
	    print $key;
	}
    }
    print "\n";
}

foreach my $e (1..7)
{
    print "E$e: ";
    for my $key (sort keys %E_hash)
    {
	if ($E_hash{$key}==$e)
	{
	    print $key
	}
    }
    print "\n";
}

#-------------------------------------------------------------------------
# Prepare the word model, dictionary, grammer, and word network
#-------------------------------------------------------------------------
my $hmmlist = "$path/hmmList";
my $dict    = "$path/dict";      # 40 words
my $gram    = "$path/gram";
my $wnet    = "$path/wdnet";
my $dict_trn= "$path/dict_trn";  # 40 + 4 + 37 words (for iso lig trn)
my $gram_trn= "$path/gram_trn";
my $wnet_trn= "$path/wdnet_trn";
my $dict_exp= "$path/dict_exp";  # 40 + 1000 words
my $gram_exp= "$path/gram_exp";
my $wnet_exp= "$path/wdnet_exp";

open FILE_model, ">$hmmlist" or die $!;
open FILE_dic,   ">$dict"    or die $!;
open FILE_gram,  ">$gram"    or die $!;
open FILE_dic_trn, ">$dict_trn" or die $!;
open FILE_gram_trn,">$gram_trn" or die $!;
open FILE_dic_exp, ">$dict_exp" or die $!;
open FILE_gram_exp,">$gram_exp" or die $!;

foreach my $c (@chars)
{
    print FILE_model "$c\n";
}

# insert the ligature models
# S1-S3 -> E1-E7: total 21 lig models
foreach my $e (1..7)
{
    foreach my $s (1..3)
    {
	print FILE_model "lig_E$e"."S$s\n"; 
    }
}

# compile the dictionary (40 words)
foreach my $w (@words)
{
    my @sub_chars = split(undef,$w);
    my @hmm_chars = ();
    foreach my $c (@sub_chars)
    {
	push(@hmm_chars, "upp_$c");
    }

    my $sub_char_str = $hmm_chars[0];
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]  };
	my $lig = "lig_E$e"."S$s";
	$sub_char_str .= " $lig $hmm_chars[$i]"
    }
    print FILE_dic     "$w\t$sub_char_str\n";
}

# compile the dictionary for lig training (40 + 4 + 37)
foreach my $w (@trn_words)
{
    my @sub_chars = split(undef,$w);
    my @hmm_chars = ();
    foreach my $c (@sub_chars)
    {
	push(@hmm_chars, "upp_$c");
    }

    my $sub_char_str = $hmm_chars[0];
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]  };
	my $lig = "lig_E$e"."S$s";
	$sub_char_str .= " $lig $hmm_chars[$i]"
    }
    print FILE_dic_trn "$w\t$sub_char_str\n";    
}

# compile the exp dictionary (40 + 1000 words)
foreach my $w ((@words,@exp_words))
{
    my @sub_chars = split(undef,$w);
    my @hmm_chars = ();
    foreach my $c (@sub_chars)
    {
	push(@hmm_chars, "upp_$c");
    }

    my $sub_char_str = $hmm_chars[0];
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]  };
	my $lig = "lig_E$e"."S$s";
	$sub_char_str .= " $lig $hmm_chars[$i]"
    }
    print FILE_dic_exp  "$w\t$sub_char_str\n";
}

# Generate the grammar for the word network
print FILE_gram  "\$gest = ".join(' | ', @words)." \;\n";
print FILE_gram  "( \$gest ) ";

# Generate the grammar for the trn-lig word network
print FILE_gram_trn "\$gest = ".join(' | ', @trn_words)." \;\n";
print FILE_gram_trn "( \$gest ) ";

# Generate the grammar for the exp word network
print FILE_gram_exp "\$gest = ".join(' | ', @words).' | '.join(' | ', @exp_words)." \;\n";
print FILE_gram_exp "( \$gest ) ";

close FILE_model or die $!;
close FILE_dic   or die $!;
close FILE_gram  or die $!;
close FILE_dic_trn  or die $!;
close FILE_gram_trn or die $!;
close FILE_dic_exp  or die $!;
close FILE_gram_exp or die $!;

system("HParse $gram $wnet");
system("HParse $gram_trn $wnet_trn");
system("HParse $gram_exp $wnet_exp");

#-------------------------------------------------------------------------
# HLEd: Convert the word level mlf (word.mlf) to char level mlf
#-------------------------------------------------------------------------
my $cmdFile = "mlf/mk_char_lig.led";
my $wordMlf = "mlf/word.mlf";
my $charMlf = "mlf/char_lig.mlf";
system("HLEd -d $dict_exp -i $charMlf $cmdFile $wordMlf");

#-------------------------------------------------------------------------
# Get the stats of the multi-ligs in each set
#-------------------------------------------------------------------------
my @occ = (
    [(0) x 21],
    [(0) x 21],
    [(0) x 21],
    [(0) x 21],
    [(0) x 21]
);

foreach my $set (0..3)
{
    foreach my $i (0..9)
    {
	my $idx = $set*10 + $i;
	my $w = $words[$idx];
	my @sub_chars = split(undef,$w);

	foreach my $i (1..scalar(@sub_chars)-1)
	{
	    my $e = $E_hash{$sub_chars[$i-1]};
	    my $s = $S_hash{$sub_chars[$i]  };
	    my $ligIdx = $e-1 + ($s-1)*7;
	    $occ[$set][$ligIdx] += 1;
	}
    }
}


foreach my $w (@exp_words)
{
    my @sub_chars = split(undef, $w);

    foreach my $i (1..scalar(@sub_chars)-1)
    {
	 my $e = $E_hash{$sub_chars[$i-1]};
	 my $s = $S_hash{$sub_chars[$i]  };
	 my $ligIdx = $e-1 + ($s-1)*7;
	 $occ[4][$ligIdx] += 1;
    }
}

print "\n==================== lig stats ====================\n";
print "lig\t"."set1\t"."set2\t"."set3\t"."set4\t"."set exp\n";
foreach my $s (1..3)
{
    foreach my $e (1..7)
    {
	print "E$e"."S$s\t";
	my $ligIdx = ($s-1)*7 + $e-1;
	foreach my $set (0..4)
	{
	    print "$occ[$set][$ligIdx]\t";	
	}
	print "\n";
    }
}
