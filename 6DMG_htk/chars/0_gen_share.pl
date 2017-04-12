#!/usr/bin/perl
# Mingyu @ May 6 2013
# Generate the shared files for all data types
# gestList, gestDic, gestGram, and gestNet

use strict;
use File::Path qw(make_path);


#-------------------------------------------------------------------------
# Prepare the word model, dictionary, grammer, and word network
#-------------------------------------------------------------------------
my $path = "share";
unless (-d $path){ make_path $path; }

my $hmmlist = "$path/gestList";
my $dic     = "$path/gestDic";
my $gram    = "$path/gestGram";
my $wnet    = "$path/gestNet";
open FILE_model, ">$hmmlist" or die $!; # gestList = hmmList (each gest has its own hmm)
open FILE_dic,   ">$dic"     or die $!;
open FILE_gram,  ">$gram"    or die $!;

my @gests = ();
foreach my $c ('A'..'Z')
{
    my $g = "upp_$c";
    push(@gests, $g);
    print FILE_model "$g\n";
    print FILE_dic   "$g\t$g\n";
}
print FILE_gram  "\$gest = ".join(' | ', @gests)." \;\n";
print FILE_gram  "( \$gest ) ";

close FILE_model or die $!;
close FILE_dic   or die $!;
close FILE_gram  or die $!;

system("HParse $gram $wnet");
