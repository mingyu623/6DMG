#!/usr/bin/perl
# Mingyu @ Apr 22 2013  [ Leave-One-Out]
#
# 1.  The script generates the hed file for HHEd for the decision tree
#     to tie the ligature models & leave the char model untouched
# 2.  Run HHEd to create trees + tiedlist
# 3   From "tiedlist":
# 3.1 "uniqueDict" - all the unique lig hmm models + 26 chars + fil
# 3.2 "fullDict"   - cover 26x26 ligs + 26 chars + fil for HVite


use strict;
use File::Path qw(make_path);
use File::stat;

my $dtype;
my $usr;
if ($#ARGV !=1)
{
    print "usage: make_tree [datatype] [tst usr]\n";
    print "[tst usr]: the leave-one-out test user\n";
    exit;
}
else
{
    $dtype = $ARGV[0];
    $usr   = $ARGV[1];
}

#input
my $path    = "products/$dtype/$usr";
my $mlf     = "$path/mono_char_tri_lig.mlf";
my $inDir   = "$path/trihmm2";
my $hmmlist = "$path/triligHmmlist";
my $fulllist= "$path/fulllist";

#output
my $treeDir = "$path/tree0";
my $treeHed = "$treeDir/tree.hed";
my $trees   = "$treeDir/trees";
my $tiedlist= "$treeDir/tiedlist";
my $uniqueDict = "$treeDir/uniqueDict";
my $fullDict   = "$treeDir/fullDict";

unless(-d $treeDir){ make_path $treeDir; }
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$treeDir/log_tree.log") or die $!;
open (STDERR, ">$treeDir/err_tree.log") or die $!;


#====================================================
# Create HED for the decision tree
# The question categories (narrow)
# S1: A
# S2: BDHKLMNPRU
# S3: CGS
# S4: EFTZ
# S5: IJ
# S6: OQ
# S7: VWXY
# E1: AF
# E2: BD
# E3: C
# E4: ELZ
# E5: GHM
# E6: ITY
# E7: JS
# E8: KQR
# E9: NU
# E10:O
# E11:P
# E12:VW
# E13:X
#====================================================
# Questions
# QS "L_BD" {upp_B-*,upp_D-*}
# QS "R_OQ" {*-upp_O,*-upp_Q}
# Tie states
# TB 350.0 "LIG_s2-" {(*-lig+*).state[2]}
#====================================================
my @S_broad = ("BDEFHKLMNPRTUVWXYZ", "AIJOQ"); # "CGS" are removed (duplicate)
my @E_broad = ("BDSX", "CEGHKLMQRZ", "NUVW"); # "ITY" "AF", "O", "JP" are removed (duplicate)

my @S = ("A", "BDHKLMNPRU", "CGS", "EFTZ", "IJ", "OQ", "VWXY");
my @E = ("AF", "BD", "C", "ELZ", "GHM", "ITY", "JS", "KQR", "NU", "O", "P", "VW", "X");


open HED, ">$treeHed" or die $!;
print HED "RO 2.0 $inDir/stats2.txt\n";
print HED "TR 0\n";

# lig+R
foreach my $q (@S_broad, @S)
{
    my $Q = "R_$q";
    my @chars = split(undef, $q);
    my @conds = ();
    foreach (@chars)
    {
	push @conds, "*+upp_$_";
    }
    my $cond_str = join(',', @conds);
    print HED "QS \"$Q\"\t{$cond_str}\n";
}

# L-lig
foreach my $q (@E_broad, @E)
{
    my $Q = "L_$q";
    my @chars = split(undef, $q);
    my @conds = ();
    foreach (@chars)
    {
	push @conds, "upp_$_-*";
    }
    my $cond_str = join(',', @conds);
    print HED "QS \"$Q\"\t{$cond_str}\n";
}

print HED "TR 2\n";

# the simplet tie command...
foreach my $n (2..4)
{
    print HED "TB 350.0 \"LIG_s$n-\"\t{(*-lig+*).state[$n]}\n";
}

print HED "AU \"$fulllist\"\n";  # the fulllist needs to be generated!
print HED "CO \"$tiedlist\"\n";
print HED "ST \"$trees\"";
close HED;


#====================================================
# HHEd with tree.hed outputs tiedlist & trees
#====================================================
my $hmm3Dir = "$treeDir/trihmm3";
unless (-d $hmm3Dir){ make_path $hmm3Dir; }

system("HHEd -H $inDir/hmmdefs -M $hmm3Dir $treeHed $hmmlist");
print "HHEd with $treeHed => $tiedlist\n";

#====================================================
# Create uniqueDict & fullDict
#====================================================
open TIEDLIST, $tiedlist      or die $!;
open FULLDICT, ">$fullDict"   or die $!;
open UNIQUE,   ">$uniqueDict" or die $!;

foreach my $line (<TIEDLIST>)
{
    chomp($line);
    if ($line =~ /^upp_([A-Z])-lig\+upp_([A-Z])$/)
    {
	print FULLDICT "$1-$2 [] \t$line\n";
	print UNIQUE   "$1-$2 [] \t$line\n";
    }
    elsif ($line =~ /^upp_([A-Z])-lig\+upp_([A-Z]) (upp_[A-Z]-lig\+upp_[A-Z])$/)
    {
	print FULLDICT "$1-$2 [] \t$3\n";
    }
    elsif ($line =~ /^upp_([A-Z])$/)
    {
	print FULLDICT "$1\t$line\n";
	print UNIQUE   "$1\t$line\n";	
    }
    elsif ($line =~ /^fil/)
    {
	print FULLDICT "fil [] \tfil\n";
	print UNIQUE   "fil [] \tfil\n";

	print FULLDICT "FIL\tfil\n";
	print UNIQUE   "FIL\tfil\n";
    }
}

close TIEDLIST;
close FULLDICT;
close UNIQUE;
print "Create $uniqueDict and $fullDict\n";


#====================================================
# HERest twice with tiedlist after clustering
#====================================================
my $hmm4Dir = "$treeDir/trihmm4";
my $hmm5Dir = "$treeDir/trihmm5";
unless(-d $hmm4Dir){ make_path $hmm4Dir; }
unless(-d $hmm5Dir){ make_path $hmm5Dir; }

system("HERest -A -I $mlf -s $hmm4Dir/stats3.txt -S $path/train.scp -H $hmm3Dir/hmmdefs -M $hmm4Dir $tiedlist");
system("HERest -A -I $mlf -s $hmm5Dir/stats4.txt -S $path/train.scp -H $hmm4Dir/hmmdefs -M $hmm5Dir $tiedlist");


open (STDOUT, ">&REGOUT") or die "Can't restore STDOUT: $!\n";
close REGOUT;
close STDERR;


# Finish: clean up
if (stat("$treeDir/err_tree.log")->size == 0) # no stderr
{
    unlink("$treeDir/err_tree.log");
}
