#!/usr/bin/perl
# Mingyu @ Apr 28 2013
# Adjust the "event error rate" to the true "word error rate"
# based on "handLabel_word_result.txt"
# Only adjust the 1-best test case

use strict;

my $dtype;
my $treeNum;
my $voc;
my $verbose;
if ($#ARGV != 2 and $#ARGV != 3)
{
    print "word_err_adjust_single [datatype] [tree#] [voc] [verbose]\n";
    print " [tree#] = 0: use the hmmdefs from decision tree 0\n";
    print "           1: use the hmmdefs from decision tree 1 (3 subtrees)\n";
    print " [voc]      : 100, 100f, 1k, 1kf\n";
    print " [verbose]  : \"optional\", 0, 1, or 2\n";
    exit;
}
else
{
    $dtype   = $ARGV[0];
    $treeNum = $ARGV[1];
    $voc     = $ARGV[2];
    if ($#ARGV==3){
        $verbose = $ARGV[3];
    }else{
        $verbose = 0;
    }
}


my @usrs = ("M1", "C1", "J1", "C3", "C4",
            "E1", "U1", "Z1", "I1", "L1",
            "Z2", "K1", "T2", "M3", "J4",
            "D1", "W1", "T3");

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

#----------------------------------------------------
# Read "handLabel_word_result.txt" first
#
# U1_LIVI       0      -> 0: imcomplete word => 1 word error no matter what
# U1_MUCH 1 M   2 UCH  -> U1_MUCH1 + U1_MUCH2 complete the word MUCH
#----------------------------------------------------
my %HoH;
my $handLabel = "../../../data_htk/airwriting_spot/log/data_NP2DuvNV2D/handLabel_word_result.txt";
open HAND_LABEL, $handLabel or die $!;
foreach my $line (<HAND_LABEL>)
{
    chomp($line);
    if ($line =~ m/^([A-Z][0-9])_([A-Z]+)\s+(.+)/)
    {
        my $usr  = $1;
        my $word = $2;
        my $desc = $3;
        $HoH{$usr}{$word} = $desc;
    }
}
close HAND_LABEL;
#----------------------------------------------------
# Collect the adjustment of the imprecise & imprecise OOV part:
# Convert event error rate to word error rate
#----------------------------------------------------
my %word_errs;
my %word_cnts;
my %event_errs;
my %event_cnts;

my %word_errs_OOV;
my %word_cnts_OOV;
my %event_errs_OOV;
my %event_cnts_OOV;

foreach my $u (keys %HoH)
{
    #----------------------------------------------------------------------------------
    # 1. event error rate-> word error rate for imprecise_$voc.mlf
    #----------------------------------------------------------------------------------
    my $decfile = "products/$dtype/$u/tree$treeNum/dec_imprecise_nbest_$voc.mlf";
    $word_errs{$u}  = 0;
    $word_cnts{$u}  = 0;
    $event_errs{$u} = 0;
    $event_cnts{$u} = 0;

    unless (open DEC_FILE, $decfile) {
        print " WARNING: file doesn't exist. $decfile!\n";
        next;
    }
    while (my $line = <DEC_FILE>)
    {
        if ($line =~ m/$u\_([A-Z]+)[0-9]\.rec/)
        {
            my $w = $1;
            if (exists $HoH{$u}{$w}){
                my @descs = split(' ', $HoH{$u}{$w});
                my $event_err = 0;
                my $event_cnt = 0;
                my $word_err  = 0;
                if ($descs[0] == 0){
                    shift(@descs); shift(@descs); # remove 0 x
                    $word_err = 1;
                }

                for (my $i=0; $i<scalar(@descs); $i+=2)
                {
                    my $decLab = "";
                    my $seg = $descs[$i];
                    my $lab = $descs[$i+1];
                    if ($i>0){ $line = <DEC_FILE>; }

                    if ($line =~ m/$w$seg\.rec/){
                        $event_cnt += 1;
                        $line = <DEC_FILE>;
                        while ($line ne "///\n")  # pump until hits the end of the 1st match
                        {
                            if ($line =~ m/([A-Z]+)/){
                                $decLab = $decLab.$1;
                            }
                            $line = <DEC_FILE>;
                        }
                        if ($decLab ne $lab){
                            $event_err += 1;
                            $word_err = 1; # event error means partial word wrong
                        }
                        if ($verbose>1){ print "$u\t$w$seg\t$decLab\n"; }

                        while ($line ne ".\n") {
                            $line = <DEC_FILE>;  # pump until the end of this n-best decoding result
                        }
                    }
                }
                if ($verbose>1){
                    print "event: $event_err\/$event_cnt, word_err:$word_err\n";
                }

                # finish one "word" (may be a couple events)
                $word_errs{$u}  += $word_err;
                $word_cnts{$u}  += 1;
                $event_errs{$u} += $event_err;
                $event_cnts{$u} += $event_cnt;
            }
        }
    }
    close DEC_FILE;

    # finish one user's words that requires handLabel
    if ($verbose){
        printf("%s:\tevent: %2d/%2d, word:%2d/%2d\n",
               $u, $event_errs{$u}, $event_cnts{$u},
               $word_errs{$u}, $word_cnts{$u});
    }

    #----------------------------------------------------------------------------------
    # 2. event error rate-> word error rate for imprecise_OOV_$voc.mlf
    #----------------------------------------------------------------------------------
    my $decOovfile = "products/$dtype/$u/tree$treeNum/dec_imprecise_nbest_OOV_$voc.mlf";
    $word_errs_OOV{$u}  = 0;
    $word_cnts_OOV{$u}  = 0;
    $event_errs_OOV{$u} = 0;
    $event_cnts_OOV{$u} = 0;

    unless (open DEC_OOV_FILE, $decOovfile) {
        print " WARNING: decOovfile doesn't exist. $decOovfile\n";
        next;
    }
    while (my $line = <DEC_OOV_FILE>)
    {
        if ($line =~ m/$u\_([A-Z]+)[0-9]\.rec/)
        {
            my $w = $1;
            if (exists $HoH{$u}{$w}){
                my @descs = split(' ', $HoH{$u}{$w});
                my $event_err = 0;
                my $event_cnt = 0;
                my $word_err  = 0;

                if ($descs[0] == 0){
                    shift(@descs); shift(@descs); # remove 0 x
                    $word_err = 1;
                }

                for (my $i=0; $i<scalar(@descs); $i+=2)
                {
                    my $decLab = "";
                    my $seg = $descs[$i];
                    my $lab = $descs[$i+1];
                    if ($i>0){ $line = <DEC_OOV_FILE>; }

                    if ($line =~ m/$w$seg\.rec/){
                        $event_cnt += 1;
                        $line = <DEC_OOV_FILE>;
                        while ($line ne "///\n")  # pump until hits the end of the 1st match
                        {
                            if ($line =~ m/([A-Z]+)/){
                                $decLab = $decLab.$1;
                            }
                            $line = <DEC_OOV_FILE>;
                        }
                        if ($decLab ne $lab){
                            $event_err += 1;
                            $word_err = 1;
                        }
                        if ($verbose>1){ print "$u\t$w$seg\t$decLab\n"; }

                        while ($line ne ".\n") {
                            $line = <DEC_OOV_FILE>;  # pump until the end of this n-best decoding result
                        }
                    }
                }
                if ($verbose>1){
                    print "event: $event_err\/$event_cnt, word_err:$word_err\n";
                }

                # finish one "word" (may be a couple events)
                $word_errs_OOV{$u}  += $word_err;
                $word_cnts_OOV{$u}  += 1;
                $event_errs_OOV{$u} += $event_err;
                $event_cnts_OOV{$u} += $event_cnt;
            }
        }
    }
    close DEC_OOV_FILE;

    # finish one user's words that requires handLabel
    if ($verbose){
        printf("%s OOV:\tevent: %2d/%2d, word:%2d/%2d\n\n",
               $u, $event_errs_OOV{$u}, $event_cnts_OOV{$u},
               $word_errs_OOV{$u}, $word_cnts_OOV{$u});
    }
}


#----------------------------------------------------------------------------------
# 3. Re-generate the original event-error-rate table
#----------------------------------------------------------------------------------
my @word_err = ([],[],[],[],[]); # precise, imprecise, preciseOOV, impreciseOOV, FA
my @word_cnt = ([],[],[],[],[]);
my @char_err = ([],[],[],[],[]);
my @char_cnt = ([],[],[],[],[]);

# Read the original event-error-rate table
foreach my $u (@usrs)
{
    my @hits = (0,0,0,0,0); # flags to indicate if certain HResult is executed

    my $path = "products/$dtype/$u/tree$treeNum";
    unless (open LOG_TREE, "$path/log_dec_bigram_$voc\_nbest.log") {
        print " WARNING: log file doesn't exist! $path/log_dec_bigram_$voc\_nbest.log\n";
        next;
    }
    OUTER:while( my $line = <LOG_TREE> )
    {
        if ($line =~ /^HResults -A -d 1 /)
        {
            my $idx = 0;
            if    ($line =~ /bigram_nbest_$voc/)   { $idx = 0; } # 0-> precise
            elsif ($line =~ /bigram_nbest_OOV/)    { $idx = 1; } # 1-> precise OOV
            elsif ($line =~ /imprecise_nbest_$voc/){ $idx = 2; } # 2-> imprecise
            elsif ($line =~ /imprecise_nbest_OOV/) { $idx = 3; } # 3-> imprecise OOV
            elsif ($line =~ /FA/)            { $idx = 4; } # 4-> false alarm
            else  { die "! Fail to parse log !\n"; }
            $hits[$idx] = 1;

            INNER:while ($line = <LOG_TREE>)
            {
                if ($line =~ /^SENT:/){
                    if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/){
                        push @{$word_err[$idx]}, $2;
                        push @{$word_cnt[$idx]}, $3;
                    }
                }
                elsif ($line =~ /^WORD:/){
                    if ($line =~ /H=([\d]+), D=([\d]+), S=([\d]+), I=([\d]+), N=([\d]+)/){
                        push @{$char_err[$idx]}, $2+$3+$4;
                        push @{$char_cnt[$idx]}, $5;
                        last INNER;
                    }
                }
            }
        }
    }
    close LOG_TREE;

    for my $i (0..4)
    {
        if ($hits[$i] eq 0) # "that" HResult is not executed: cnt=err=0
        {
            push @{$word_err[$i]}, 0;
            push @{$word_cnt[$i]}, 0;
            push @{$char_err[$i]}, 0;
            push @{$char_cnt[$i]}, 0;
        }
    }
}

# Adjust the imprecise & imprecise OOV part
# then, print
my @word_err_sum = (0,0,0,0,0);
my @word_cnt_sum = (0,0,0,0,0);
my @char_err_sum = (0,0,0,0,0);
my @char_cnt_sum = (0,0,0,0,0);
print "[$dtype] tree$treeNum\n";
print "\tprecise\t\timprecise\tFA\tprecise\timprecise\n";
print "\t\t(oov)\t\t(oov)\t\tavg\tavg\n";
print "-------------------------------------------------------------\n";
foreach my $i (0..scalar(@usrs)-1)
{
    # ADJUST HERE!
    my $u = $usrs[$i];
    if (exists $word_cnts{$u}) # imprecise part
    {
        if ($verbose) {
            print "$u: ";
            printf("imprecise words: adj_err=%2d-%2d+%2d=%2d adj_cnt=%2d-%2d+%2d=%2d\n",
                   $word_err[2][$i], $event_errs{$u}, $word_errs{$u},
                   $word_err[2][$i]-$event_errs{$u}+$word_errs{$u},
                   $word_cnt[2][$i], $event_cnts{$u},$word_cnts{$u},
                   $word_cnt[2][$i]-$event_cnts{$u}+$word_cnts{$u});
        }
        $word_err[2][$i] = $word_err[2][$i] - $event_errs{$u}     + $word_errs{$u};
        $word_cnt[2][$i] = $word_cnt[2][$i] - $event_cnts{$u}     + $word_cnts{$u};
    }

    if (exists $word_cnts{$usrs[$i]}) # imprecise OOV part
    {
        if ($verbose) {
            print "$u: ";
            printf("imprecise (OOV): adj_err=%2d-%2d+%2d=%2d adj_cnt=%2d-%2d+%2d=%2d\n",
                   $word_err[3][$i], $event_errs_OOV{$u}, $word_errs_OOV{$u},
                   $word_err[3][$i]-$event_errs_OOV{$u}+$word_errs_OOV{$u},
                   $word_cnt[3][$i], $event_cnts_OOV{$u}, $word_cnts_OOV{$u},
                   $word_cnt[3][$i]-$event_cnts_OOV{$u}+$word_cnts_OOV{$u});
        }
        $word_err[3][$i] = $word_err[3][$i] - $event_errs_OOV{$u} + $word_errs_OOV{$u};
        $word_cnt[3][$i] = $word_cnt[3][$i] - $event_cnts_OOV{$u} + $word_cnts_OOV{$u};
    }


    # PRINT
    print sprintf("%s\t", $usrs[$i]);
    for my $j (0..4)
    {
        print sprintf("%2d/%3d\t", $word_err[$j][$i],$word_cnt[$j][$i]);
        $word_err_sum[$j] += $word_err[$j][$i];
        $word_cnt_sum[$j] += $word_cnt[$j][$i];
        $char_err_sum[$j] += $char_err[$j][$i];
        $char_cnt_sum[$j] += $char_cnt[$j][$i];
    }
    my $precise_err_rate;
    eval {
        $precise_err_rate = ($word_err[0][$i]+$word_err[1][$i])/($word_cnt[0][$i]+$word_cnt[1][$i])*100;
    } or do {
        $precise_err_rate = 0;
    };
    print sprintf ("%5.2f\t", $precise_err_rate);

    if ($word_cnt[2][$i] + $word_cnt[3][$i] > 0){
        my $imprecise_err_rate = ($word_err[2][$i]+$word_err[3][$i])/($word_cnt[2][$i]+$word_cnt[3][$i])*100;
        print sprintf("%5.2f\n", $imprecise_err_rate);
    }else{
        print sprintf("    -\n");
    }
}

my $word_avg_0 = $word_err_sum[0]/$word_cnt_sum[0]*100; # precise
my $word_avg_1 = $word_err_sum[1]/$word_cnt_sum[1]*100; # precise OOV
my $word_avg_2 = $word_err_sum[2]/$word_cnt_sum[2]*100; # precise OOV
my $word_avg_3 = $word_err_sum[3]/$word_cnt_sum[3]*100; # imprecise OOV
my $word_avg_4; # FA
eval {
    $word_avg_4 = $word_err_sum[4]/$word_cnt_sum[4]*100;
} or do {
    $word_avg_4 = 0;
};

my $char_avg_0 = $char_err_sum[0]/$char_cnt_sum[0]*100; # precise
my $char_avg_1 = $char_err_sum[1]/$char_cnt_sum[1]*100; # precise OOV
my $char_avg_2 = $char_err_sum[2]/$char_cnt_sum[2]*100; # precise OOV
my $char_avg_3 = $char_err_sum[3]/$char_cnt_sum[3]*100; # imprecise OOV
my $char_avg_4; # FA
eval {
    $char_avg_4 = $char_err_sum[4]/$char_cnt_sum[4]*100;
} or do {
    $char_avg_4 = 0;
};

my $precise_word_avg   = ($word_err_sum[0]+$word_err_sum[1])/($word_cnt_sum[0]+$word_cnt_sum[1])*100;
my $imprecise_word_avg = ($word_err_sum[2]+$word_err_sum[3])/($word_cnt_sum[2]+$word_cnt_sum[3])*100;

my $precise_char_avg   = ($char_err_sum[0]+$char_err_sum[1])/($char_cnt_sum[0]+$char_cnt_sum[1])*100;
my $imprecise_char_avg = ($char_err_sum[2]+$char_err_sum[3])/($char_cnt_sum[2]+$char_cnt_sum[3])*100;

my $precise_word_cnt   = $word_cnt_sum[0]+$word_cnt_sum[1];
my $imprecise_word_cnt = $word_cnt_sum[2]+$word_cnt_sum[3];
my $all_word_err = ($word_err_sum[0]+$word_err_sum[1]+$word_err_sum[2]+$word_err_sum[3]+$word_err_sum[4]);
my $all_word_cnt = ($word_cnt_sum[0]+$word_cnt_sum[1]+$word_cnt_sum[2]+$word_cnt_sum[3]);
print "-------------------------------------------------------------\n";
print sprintf("(word):\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n",
                  $word_avg_0, $word_avg_1, $word_avg_2, $word_avg_3, $word_avg_4,
                  $precise_word_avg, $imprecise_word_avg);

print sprintf("(char):\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n",
                  $char_avg_0, $char_avg_1, $char_avg_2, $char_avg_3, $char_avg_4,
                  $precise_char_avg, $imprecise_char_avg);
print "-------------------------------------------------------------\n";
print sprintf("precise   detection: %5.2f\%\n", $precise_word_cnt/$all_word_cnt*100);
print sprintf("imprecise detection: %5.2f\%\n", $imprecise_word_cnt/$all_word_cnt*100);
print sprintf("word error rate:     %5.2f\%\n", $all_word_err/$all_word_cnt*100);
print "\n\n";
