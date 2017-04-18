#!/usr/bin/perl
# Mingyu @ Apr 26 2013
# Summarize the results of 3_viterbi_bigram_nbest

use strict;
use File::Path qw(make_path);
use List::Util qw(sum);
use Math::NumberCruncher;


my @dtypes = ("NP2DuvNV2D");
#my @usrs = ("M1", "C1", "J1", "C3", "C4",
#            "E1", "U1", "Z1", "I1", "L1",
#	    "Z2", "K1", "T2", "M3", "J4",
#	    "D1", "W1", "T3");
my @usrs = ("M1", "C1");
my @vocs = ("100", "100f", "1k", "1kf");
my @nbests = (1, 2, 3, 5);

# The log file names generated from different detOption:
# "det"   -> bigram
# "merge" -> merge
my @logNames = ("bigram", "merge");

unless (-d "results") { make_path("results"); }
foreach my $logName (@logNames) {
    foreach my $nbest (@nbests) {
        foreach my $voc (@vocs) {
            open LOG, ">results/res_$logName\_$voc"."_$nbest"."best.txt" or die $!;
            foreach my $t (0..1) {
                foreach my $dtype (@dtypes) {
                    my @word_err = ([],[],[],[],[]); # precise, imprecise, preciseOOV, impreciseOOV, FA
                    my @word_cnt = ([],[],[],[],[]);
                    my @char_err = ([],[],[],[],[]);
                    my @char_cnt = ([],[],[],[],[]);

                    foreach my $u (@usrs) {
                        my @hits = (0,0,0,0,0); # flags to indicate if certain HResult is executed
                        my $path = "products/$dtype/$u/tree$t";
                        open LOG_TREE, "$path/log_dec_$logName\_$voc\_nbest.log" or die $!;
  
                        OUTER:while( my $line = <LOG_TREE> ) {
                            if ($line =~ /^HResults -A -d $nbest/) {
                                my $idx;
                                if    ($line =~ /$logName\_nbest_$voc/) { $idx = 0; } # 0-> precise
                                elsif ($line =~ /$logName\_nbest_OOV/)  { $idx = 1; } # 1-> precise OOV
                                elsif ($line =~ /imprecise_nbest_$voc/) { $idx = 2; } # 2-> imprecise
                                elsif ($line =~ /imprecise_nbest_OOV/)  { $idx = 3; } # 3-> imprecise OOV
                                elsif ($line =~ /FA/)                   { $idx = 4; } # 4-> false alarm
                                else  { die "! Fail to parse log !\n"; }
                                $hits[$idx] = 1;

                                INNER:while ($line = <LOG_TREE>) {
                                    if ($line =~ /^SENT:/) {
                                        if ($line =~ /H=([\d]+), S=([\d]+), N=([\d]+)/) {
                                            push @{$word_err[$idx]}, $2;
                                            push @{$word_cnt[$idx]}, $3;
                                        }
                                    }
                                    elsif ($line =~ /^WORD:/) {
                                        if ($line =~ /H=([\d]+), D=([\d]+), S=([\d]+), I=([\d]+), N=([\d]+)/) {
                                            push @{$char_err[$idx]}, $2+$3+$4;
                                            push @{$char_cnt[$idx]}, $5;
                                            last INNER;
                                        }
                                    }
                                }
                            }
                        }
                        close LOG_TREE;
                        for my $i (0..4) {
                            if ($hits[$i] eq 0) { # "that" HResult is not executed: cnt=err=0
                                push @{$word_err[$i]}, 0;
                                push @{$word_cnt[$i]}, 0;
                                push @{$char_err[$i]}, 0;
                                push @{$char_cnt[$i]}, 0;
                            }
                        }
                    }

                    my @word_err_sum = (0,0,0,0,0,0);
                    my @word_cnt_sum = (0,0,0,0,0,0);
                    my @char_err_sum = (0,0,0,0,0,0);
                    my @char_cnt_sum = (0,0,0,0,0,0);

                    print LOG "[$dtype] tree$t\n";
                    print LOG "\tprecise\t\timprecise\tFA\tprecise\timprecise\n";
                    print LOG "\t\t(oov)\t\t(oov)\t\tavg\tavg\n";
                    print LOG "-------------------------------------------------------------\n";
                    foreach my $i (0..scalar(@usrs)-1) {
                        print LOG sprintf("%s\t", $usrs[$i]);
                        for my $j (0..4) {
                            print LOG sprintf("%2d/%3d\t", $word_err[$j][$i],$word_cnt[$j][$i]);
                            $word_err_sum[$j] += $word_err[$j][$i];
                            $word_cnt_sum[$j] += $word_cnt[$j][$i];
                            $char_err_sum[$j] += $char_err[$j][$i];
                            $char_cnt_sum[$j] += $char_cnt[$j][$i];
                        }
                        my $precise_err_rate   = ($word_err[0][$i]+$word_err[1][$i])/($word_cnt[0][$i]+$word_cnt[1][$i])*100;
                        print LOG sprintf ("%5.2f\t", $precise_err_rate);
		    
                        if ($word_cnt[2][$i] + $word_cnt[3][$i] > 0){
                            my $imprecise_err_rate = ($word_err[2][$i]+$word_err[3][$i])/($word_cnt[2][$i]+$word_cnt[3][$i])*100;
                            print LOG sprintf("%5.2f\n", $imprecise_err_rate);
                        }else{
                            print LOG sprintf("    -\n");
                        }
                    }
                    my $word_avg_0 = $word_err_sum[0]/$word_cnt_sum[0]*100; # precise
                    my $word_avg_1 = $word_err_sum[1]/$word_cnt_sum[1]*100; # imprecise
                    my $word_avg_2 = $word_err_sum[2]/$word_cnt_sum[2]*100; # precise OOV
                    my $word_avg_3 = $word_err_sum[3]/$word_cnt_sum[3]*100; # imprecise OOV
                    my $word_avg_4; # FA
                    eval {
                        $word_avg_4 = $word_err_sum[4]/$word_cnt_sum[4]*100;
                    } or do {
                        $word_avg_4 = 0;
                    };

                    my $char_avg_0 = $char_err_sum[0]/$char_cnt_sum[0]*100; # precise
                    my $char_avg_1 = $char_err_sum[1]/$char_cnt_sum[1]*100; # imprecise
                    my $char_avg_2 = $char_err_sum[2]/$char_cnt_sum[2]*100; # precise OOV
                    my $char_avg_3 = $char_err_sum[3]/$char_cnt_sum[3]*100; # imprecise OOV
                    my $char_avg_4; # FA
                    eval {
                        $char_avg_4 = $char_err_sum[4]/$char_cnt_sum[4]*100; # FA
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
                    print LOG "-------------------------------------------------------------\n";
                    print LOG sprintf("(word):\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n",
                                      $word_avg_0, $word_avg_1, $word_avg_2, $word_avg_3, $word_avg_4,
                                      $precise_word_avg, $imprecise_word_avg);

                    print LOG sprintf("(char):\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\t%5.2f\n",
                                      $char_avg_0, $char_avg_1, $char_avg_2, $char_avg_3, $char_avg_4,
                                      $precise_char_avg, $imprecise_char_avg);
                    print LOG "-------------------------------------------------------------\n";
                    print LOG sprintf("precise   detection: %5.2f\%\n", $precise_word_cnt/$all_word_cnt*100);
                    print LOG sprintf("imprecise detection: %5.2f\%\n", $imprecise_word_cnt/$all_word_cnt*100);
                    print LOG sprintf("word error rate:     %5.2f\%\n", $all_word_err/$all_word_cnt*100);
                    print LOG "\n\n";
                }
            }
            close LOG;
        }
    }
}
