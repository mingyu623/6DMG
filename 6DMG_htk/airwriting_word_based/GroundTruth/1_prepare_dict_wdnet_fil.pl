#!/usr/bin/perl
# Mingyu @ Jun 4 2013
# 1. Generate the wdnet and dict for the motion word recognition task (100-word vocab + 1k-word vocab)
#    Enforce the "fil" model at the begin and end of each word (in the dict!)
# 2. Copy the word level mlf (word.mlf) from 6DMG_htk_spot/truth/mlf (from filtered ground truth)
# 3. Convert the word level mlf (word.mlf) to char level mlf (char_lig.mlf)

use strict;
use File::Path qw(make_path remove_tree);
use File::Copy;

my $path = "char_lig";
unless (-d $path){ make_path "$path" };

my @words_common = (  # common 100 words
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

my @words_unique = ( # extra unique 900 words
    "TIPS","COVE","GOLF","BENE","MONI","HAND","BREA","WEEK","ADMI","INDE",
    "STUD","AUST","FISH","UNIV","NEAR","GOD", "TEAM","FIVE","LESS","MIDD",
    "MICH","USUA","SHOE","SHOR","SELF","PICT","MISS","MENU","THIS","CITI",
    "POLI","BELO","PHYS","FAST","CROS","BRIT","ALRE","AFRI","AUTO","RSS", 
    "GAS", "MATT","CARD","PLEA","SCHO","PICS","FRON","SETT","JUN", "GOOD",
    "WENT","ACCO","LEAR","THEN","MILI","FRIE","FIEL","PROG","INSI","MAJO",
    "IMPL","GRAP","CATE","ANIM","CARE","DOG", "SEVE","EFFO","LOND","SOLU",
    "AMER","LEAD","SEP", "FIRE","CLIC","SUIT","LEAV","PROT","HELP","GEOR",
    "AGO", "FUND","AUDI","CD",  "OWNE","KIDS","TOO", "FURN","THAT","EXTE",
    "SEAS","HOME","ASK", "SUCC","GOVE","HOWE","RUN", "EMPL","NIGH","PERI",
    "KING","HER", "JAN", "BILL","LINE","LITT","GREE","HOW", "SOFT","EMAI",
    "GROW","LAND","POWE","STRA","MESS","FOR", "SERI","FROM","TH",  "TRAN",
    "MAKE","CAMP","ENTI","FEW", "PRO", "THE", "YOUR","LIMI","HUMA","QUES",
    "THEM","GENE","APPE","HOT", "MULT","FRI", "SCOR","SUND","ANSW","COMI",
    "GROU","INTO","KEYW","CABL","RICH","TAX", "MATC","YOU", "RING","GO",  
    "FLOW","AVER","NY",  "POSS","GRAN","HIS", "AUTH","WHET","SILV","BECA",
    "THAN","CURR","RATH","FAX", "NATU","LOCA","PROB","CALE","REPR","AMON",
    "ELSE","OFTE","INTE","VIDE","OPIN","ADD", "PAUL","IF",  "LYRI","BEGI",
    "HOUS","OBJE","ASSE","BUT", "STUF","MAR", "CHOI","FACI","GUES","CELL",
    "INST","PAGE","WORL","SORT","THIR","MAKI","WORD","EUR", "ADVE","FLOR",
    "FEEL","DIVI","SECO","VEHI","BLUE","GOOG","DO",  "ACRO","US",  "MAIN",
    "LIGH","FURT","JOHN","NEVE","COLL","OTHE","END", "APPL","MOND","DRIV",
    "CLOS","MINI","BASE","TOYS","EURO","SPEN","REVI","DAY", "POST","ANY", 
    "EITH","ENTE","UPON","MEDI","BEAC","WIND","OIL", "DATA","RESE","PERS",
    "BELI","DECE","MARC","SIGN","TELL","TRUE","MUSI","SALE","MAIL","ELEC",
    "GERM","VOLU","SCOT","VOTE","LETT","IS",  "SIMI","SEE", "SAFE","GUID",
    "TOGE","TV",  "CLAS","VARI","EACH","INTR","CALI","EVEN","MAN", "LOVE",
    "GLOB","IMPR","BAR", "TRY", "ALWA","THEY","TURN","WHEN","BE",  "DEGR",
    "RUNN","SPOR","STRE","CENT","AL",  "USED","HIGH","OPPO","CONC","ORGA",
    "FUCK","NOT", "SPEE","SINC","FOOD","DRUG","ST",  "RECO","PART","AMAZ",
    "DOUB","WIDE","YET", "TICK","THRO","LOSS","BAND","WAR", "CONT","HAVE",
    "LEGA","MOVI","CRED","PATI","ABOV","OPTI","PREV","ACT", "MANA","OCT", 
    "SUBJ","SUCH","MON", "CULT","SITE","DURI","CARR","WIRE","SELL","ORIG",
    "IDEA","READ","LINK","HALF","PRE", "ITS", "THOU","FOLL","LESB","FACT",
    "CHAN","UNIO","ITEM","ARE", "LOT", "VIRG","WHOL","ACTU","ERRO","EXIS",
    "ANOT","JUST","EFFE","DUE", "FRAN","TERM","URL", "FAR", "AUCT","REPO",
    "SONG","AROU","AVAI","WHER","HAPP","LOW", "PAST","STOP","DOMA","CASI",
    "WEAT","FUNC","HOPE","DOWN","ACCE","DEAT","BRAN","ANNU","SONY","HTML",
    "EARL","ACAD","SHIP","TOUR","ALLO","GAY", "COPY","BLOG","HILL","SHE", 
    "RELI","SUBM","REDU","WHY", "RESP","NEWS","WEB", "USE", "RE",  "EN",  
    "EXPR","YOUN","REAL","APR", "RULE","YAHO","RELA","SO",  "SPAC","DEC", 
    "MOBI","STOR","SPON","SERV","GOLD","MANU","SEAR","PRAC","PRIN","CAPI",
    "LIVI","SUPP","RETU","DEVE","CLIE","MEMB","YES", "OCTO","ALON","ME",  
    "NEW", "BECO","CHUR","WISH","BAD", "CASE","JOBS","SUGG","DIGI","PAPE",
    "GIRL","WHAT","BROW","GREA","ONCE","MOVE","ADDI","CONF","WAS", "JOB", 
    "FALL","ANNO","UNIT","ITAL","TWO", "BASK","WHIC","PROC","CAUS","STYL",
    "CASH","JAPA","METH","BUY", "AIR", "WATE","NAME","MANY","WOUL","MARK",
    "MILL","INDI","AND", "HAVI","EVER","OH",  "FAVO","WANT","LICE","DECI",
    "CHOO","CONS","CHAP","UK",  "COMP","ALL", "LOST","CLUB","HE",  "AGE", 
    "INCL","SEPT","FIND","MY",  "ANYT","VERY","STAT","ATTE","SEEN","CHIL",
    "PRES","BODY","VE",  "LIKE","EAST","SHOP","LOWE","REMA","OUTS","PURC",
    "LEFT","SKIL","SOME","IDEN","PROD","HEAL","FIRS","FRID","HAD", "AUG", 
    "CO",  "COMM","REST","PRIC","GAME","DESI","DOCU","ASSI","DEAL","MILE",
    "CA",  "FOOT","LA",  "BOX", "HOLI","PLAY","WASH","NOV", "HEAR","PUBL",
    "INFO","ALBU","REFE","PORT","FUN", "WITH","BIT", "ET",  "ART", "SAY", 
    "RISK","WORK","STIL","WILL","PDF", "OR",  "PASS","SUBS","PAYM","OUT", 
    "THRE","SYST","SHAL","TALK","RESU","COME","DAIL","FILE","DOES","ECON",
    "DE",  "AUGU","CERT","NO",  "LOAN","TO",  "SURE","NON", "MORT","YELL",
    "AFTE","GIFT","APRI","EDIT","AREA","IMAG","THEI","WELC","HIM", "HEAD",
    "FORM","PRIV","INDU","UP",  "AMOU","PARK","II",  "PRIO","GARD","PURP",
    "NONE","FOUR","ABOU","VIEW","ADUL","PARE","JULY","REMO","BABY","POSI",
    "PROF","STAF","FORU","RIGH","CANA","JANU","PHOT","DETA","EDUC","TEXT",
    "HOST","TOTA","USR", "MOTO","RESO","NOW", "GOIN","MINU","BANK","YEAR",
    "PROV","LAST","SHAR","SHOU","LEAS","FINE","AN",  "BID", "ANAL","ENER",
    "MIGH","CHRI","ALSO","BEAU","PC",  "COLO","ENTR","LET", "GETT","ROBE",
    "MODE","TABL","CART","EXCH","RIVE","OFFI","TELE","SAVE","MEMO","DETE",
    "NATI","MATE","CORP","INCR","MEAS","NET", "JUNE","LATE","MEAN","APPR",
    "STOC","IMPO","TECH","PHON","FORC","THIN","UNDE","RADI","WE",  "INVE",
    "CAME","MAY", "NUDE","THER","WEIG","BRIN","MICR","WERE","WELL","BACK",
    "UNTI","SIDE","KIND","INSU","AM",  "BETT","QUOT","RENT","SHOW","LAKE",
    "TAKE","SUMM","DATE","PER", "ONE", "SING","LOGI","ROAD","BIG", "EXEC",
    "BY",  "SPRI","BUSI","MARY","NOTI","AWAR","TIME","RATI","GET", "PLAN",
    "FEBR","DELI","GOT", "JOUR","DEFI","PM",  "FULL","LOOK","FEDE","BEST",
    "EASY","FOCU","WHO", "PRIM","TOP", "BASI","COLU","CARS","STAR","ALTH",
    "CAN", "ISLA","VIA", "AS",  "AWAY","EQUI","SAME","REGU","ENOU","NICE",
    "ENGI","QUIC","CLOT","DEVI","CITY","OLD", "EXPE","PUT", "WRIT","MONE",
    "OFFE","OUTD","GRAD","FACE","BAY", "GALL","RED", "SCIE","MORE","FEB", 
    "SAID","COUN","ENVI","SOUN","CHEA","DOIN","TEAC","FINA","FREN","SUN", 
    "MEN", "TREE","AGRE","EXCE","NEED","SPEC","LL",  "ARTS","WOMA","SIX", 
    "TEXA","BATT","LIST","USA", "CALL","MAGA","LINU","OVER","JAME","BEEN",
    "CHIN","FUTU","OUR", "ESTA","TRAC","REGI","NETW","FORE","DESK","POPU",
    "FIGU","TRAI","NUMB","DIRE","WAY", "CONN","SIMP","HOLD","HELD","STEP",
    "HERE","LOG", "EXTR","NOVE","LANG","ID",  "ARTI","COM", "SEEM","PERM",
    "ASIA","KEEP","COUR","PROP","REME","LENG","FREE","ADDE","BOOK","WHIT",
    "AT",  "MACH","TYPE","RECE","QUAL","DAVI","NECE","RUSS","SAMP","PERC",
    "MOST","JUL", "RATE","TODA","HOTE","WATC","INCO","STRU","ABLE","FLAS",
    "CUST","PORN","SAYS","DONE","PAY", "HAS", "AGEN","TUES","REAS","USER",
    "RANG","DC",  "SAN", "CLEA","OPER","ON",  "IN",  "ONLI","PACK","LOGO",
    "ACTI","THES","DEPA","ONLY","IT",  "DISC","FILM","ADVI","CHAT","PEOP",
    "SCHE","TOWN","SCRE","LAW", "LIBR","TREA","PLUS","ORDE","DISP","OF",  
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

# End points have 7 sets
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
my $dict    = "$path/dict";      # 100 common words
my $gram    = "$path/gram";
my $wnet    = "$path/wdnet";
my $dict1k  = "$path/dict1k";    # 100 common + 900 unique words
my $gram1k  = "$path/gram1k";
my $wnet1k  = "$path/wdnet1k";

open FILE_model, ">$hmmlist" or die $!;
open FILE_dic,   ">$dict"    or die $!;
open FILE_gram,  ">$gram"    or die $!;
open FILE_dic1k, ">$dict1k"  or die $!;
open FILE_gram1k,">$gram1k"  or die $!;

foreach my $c ('A'..'Z')
{
    print FILE_model "upp_$c\n";
}

# insert the filler model (fil)
print FILE_model "fil\n";

# insert the ligature models
# S1-S3 -> E1-E7: total 21 lig models
foreach my $e (1..7)
{
    foreach my $s (1..3)
    {
	print FILE_model "lig_E$e"."S$s\n"; 
    }
}

# compile the dictionary (100 common words)
# force "fil" at the begin and end of each word
# add also single "fil" for false alarm
print FILE_dic "fil\tfil\n";
foreach my $w (@words_common)
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
    print FILE_dic     "$w\tfil $sub_char_str fil\n";
}

# compile the complete dictionary (100 common + 900 unique words)
# force "fil" at the begin and end of each word
# add also single "fil" for false alarm
print FILE_dic1k "fil\tfil\n";
foreach my $w (@words_common,@words_unique)
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
    print FILE_dic1k  "$w\tfil $sub_char_str fil\n";
}

# Generate the grammar for the word network (100 common words)
print FILE_gram  "\$gest = ".join(' | ', ("fil",@words_common))." \;\n";
print FILE_gram  "(\$gest)";

# Generate the grammar for the word network (100 common + 900 unique words)
print FILE_gram1k "\$gest = ".join(' | ',("fil",@words_common,@words_unique))." \;\n";
print FILE_gram1k "(\$gest)";

close FILE_model  or die $!;
close FILE_dic    or die $!;
close FILE_gram   or die $!;
close FILE_dic1k  or die $!;
close FILE_gram1k or die $!;

system("HParse $gram   $wnet");
system("HParse $gram1k $wnet1k");


#-------------------------------------------------------------------------
# HLEd: Convert the word level mlf (word.mlf) to char level mlf
# word.mlf is copied from C:/Mingyu/6DMG_htk_spot/train/mlf
#-------------------------------------------------------------------------
my $srcMlf = "../../../data_htk/airwriting_spot/truth/mlf/word.mlf";
unless (-e $srcMlf){
    die "$srcMlf doesn't exist!".
        "run ../../../data_htk/airwriting_spot/train/gen_global_mlf.pl!\n"; }
my $cmdFile = "mlf/mk_char_lig.led";
my $wordMlf = "mlf/word.mlf";
my $charMlf = "mlf/char_lig.mlf";
copy ($srcMlf, $wordMlf);
unless (-e $cmdFile){ die "$cmdFile doesn't exist!"; }
system("HLEd -l * -d $dict1k -i $charMlf $cmdFile $wordMlf");


#-------------------------------------------------------------------------
# Get the stats of the multi-ligs in each set
#-------------------------------------------------------------------------
my @occ = (
    [(0) x 21],  # 100 common words
    [(0) x 21],  # 900 unique words
);

foreach my $w (@words_common)
{
    my @sub_chars = split(undef,$w);
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]  };
	my $ligIdx = $e-1 + ($s-1)*7;
	$occ[0][$ligIdx] += 1;
    }
}

foreach my $w (@words_unique)
{
    my @sub_chars = split(undef,$w);
    foreach my $i (1..scalar(@sub_chars)-1)
    {
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]  };
	my $ligIdx = $e-1 + ($s-1)*7;
	$occ[1][$ligIdx] += 1;
    }
}

print "\n==================== lig stats ====================\n";
print "lig\t"."common\t"."unique\n";
foreach my $s (1..3)
{
    foreach my $e (1..7)
    {
	print "E$e"."S$s\t";
	my $ligIdx = ($s-1)*7 + $e-1;
	print "$occ[0][$ligIdx]\t";	
	print "$occ[1][$ligIdx]\n";
    }
}
