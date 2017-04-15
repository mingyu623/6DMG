#!/usr/bin/perl
# Mingyu @ Apr 18 2013
# use data_NP2DuvNV2D to construct the global word-level MLF (w/o alignment information)
#                                             char-level MLF
# the MLF contains the "selected (filtered)" detection results from MATLAB GMM writing detector
# the vocab of detected words < 1k

use strict;
use File::stat;
my $data_dir = "data_NP2DuvNV2D";

# Create the word level mlf for all detected words
open (FILE, '>mlf/word.mlf') or die $!;
print FILE "\#!MLF!\#\n";

# Create the char level mlf for all detected words
open (WORD_L, ">mlf/word_char.mlf") or die $!;
print WORD_L "\#!MLF!\#\n";

# Create the char level + multi ligs fro all detected words
open (WORD_ML, ">mlf/word_char_multi_lig2.mlf") or die $!;
print WORD_ML "\#!MLF!\#\n";


#==================================================
# The cluster I will use for multi-lig(2) models
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
#==================================================
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

#==================================================
#==================================================
my $cnt = 0;
my @files = glob($data_dir."/*.htk");
foreach my $file (@files)
{     
    $cnt += 1;
    $file =~ m/\/(.*)_([A-Z]+).htk/;
    my $w = $2;
    print $1."_".$2."\n";

    # word-level mlf
    print FILE "\"*/$1_$2.lab\"\n";
    print FILE "$w\n";
    print FILE ".\n";

    # char-level mlf
    print WORD_L "\"*/$1_$2.lab\"\n";
    my @sub_chars = split(undef,$w);
    while (scalar(@sub_chars)>1)
    {
	print WORD_L $sub_chars[0]."_\n";	
	shift(@sub_chars);
    }
    print WORD_L $sub_chars[0]."\n";
    print WORD_L ".\n";

    # char-level mlf + multi ligs
    print WORD_ML "\"*/$1_$2.lab\"\n";
    @sub_chars = split(undef,$w);
    print WORD_ML $sub_chars[0]."\n";
    foreach my $i (1..scalar(@sub_chars)-1)
    {	
	my $e = $E_hash{$sub_chars[$i-1]};
	my $s = $S_hash{$sub_chars[$i]};
	my $lig = "lig_E$e"."S$s";
	print WORD_ML $lig."\n";
	print WORD_ML $sub_chars[$i]."\n";
    }
    print WORD_ML ".\n";
    
}

close(FILE);
close(WORD_L);
close(WORD_ML);

print "Total $cnt detected word segments (filtered)\n";
