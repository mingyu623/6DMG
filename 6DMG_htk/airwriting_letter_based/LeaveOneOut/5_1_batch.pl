#!/usr/bin/perl
# Mingyu @ Apr 28 2013
# Adjust the "event-error-rate" to the true "word-error-rate" for all setups
# no "nbest" is considered for the adjustment

use strict;

my @dTypes = ("NP2DuvNV2D");
my @vocs   = ("100", "100f", "1k", "1kf");

foreach my $voc (@vocs)
{
    # pipe stdout to the log file
    open STDOUT, ">results/adj_bigram_$voc.txt" or die $!;
    foreach my $dtype (@dTypes)
    {
        foreach my $tree (0..1)
        {
            system("perl 5_0_word_err_adjust.pl $dtype $tree $voc");
        }
    }
    close STDOUT;
}
