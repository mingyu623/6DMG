#!/usr/bin/perl
# Mingyu @ Apr 22 2013
# 1.  The script generates the hed file for HHEd for the decision tree
#     to tie the ligature models & leave the char model untouched
#     Questions for each state are different
# 1.1 1st subtree -> tie the 1st state
# 1.2 2nd subtree -> tie the 2nd state of lig models
# 1.3 3rd subtree -> tie the 3rd state 
# 2.  From "tiedlist":
# 2.1 "uniqueDict" - all the unique lig hmm models + 26 chars + fil
# 2.2 "fullDict"   - cover 26x26 ligs + 26 chars + fil for HVite
     
use strict;
use File::Copy;
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

# input
my $path          = "products/$dtype/$usr";
my $occStats      = "$path/trihmm2/stats2.txt";
my $triligHmmlist = "$path/triligHmmlist";
my $mlf           = "$path/mono_char_tri_lig.mlf";
my $fulllist      = "$path/fulllist";

# intermediate files
my $treeDir     = "$path/tree1";
my $subtree1    = "$treeDir/subtrees1";
my $subtree2    = "$treeDir/subtrees2";
my $subtree3    = "$treeDir/subtrees3";
my $subtreeHed1 = "$subtree1/subtree.hed";
my $subtreeHed2 = "$subtree2/subtree.hed";
my $subtreeHed3 = "$subtree3/subtree.hed";

# output
my $tiedlist    = "$treeDir/tiedlist";
my $uniqueDict  = "$treeDir/uniqueDict";
my $fullDict    = "$treeDir/fullDict";

unless(-d $subtree1){ make_path $subtree1; }
unless(-d $subtree2){ make_path $subtree2; }
unless(-d $subtree3){ make_path $subtree3; }
open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$treeDir/log_tree.log") or die $!;
open (STDERR, ">$treeDir/err_tree.log") or die $!;



#=====================================
# The full questions
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
#=====================================
my @S_broad = ("BDEFHKLMNPRTUVWXYZ", "AIJOQ"); # "CGS" are removed (duplicate)
my @E_broad = ("BDSX", "CEGHKLMQRZ", "NUVW"); # "ITY" "AF", "O", "JP" are removed (duplicate)

my @S = ("A", "BDHKLMNPRU", "CGS", "EFTZ", "IJ", "OQ", "VWXY");
my @E = ("AF", "BD", "C", "ELZ", "GHM", "ITY", "JS", "KQR", "NU", "O", "P", "VW", "X");


#=====================================
# Create HED for subtree1 (state[2])
# L-lig
#=====================================
open  HED1,">$subtreeHed1" or die $!;
print HED1 "RO 2.0 $occStats\n";
print HED1 "TR 0\n";

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
    print HED1 "QS \"$Q\"\t{$cond_str}\n";
}

print HED1 "TR 2\n";
print HED1 "TB 350.0 \"LIG_s2-\"\t{(*-lig+*).state[2]}\n";
print HED1 "ST \"$subtree1/subtree\"";
close HED1;

system("HHEd -H $path/trihmm2/hmmdefs -M $subtree1 $subtreeHed1 $triligHmmlist");

#=====================================
# Create HED for subtree2 (state[3])
# L-lig & lig+R
#=====================================
open HED2, ">$subtreeHed2" or die $!;
print HED2 "RO 2.0 $occStats\n";
print HED2 "TR 0\n";

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
    print HED2 "QS \"$Q\"\t{$cond_str}\n";
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
    print HED2 "QS \"$Q\"\t{$cond_str}\n";
}

print HED2 "TR 2\n";
print HED2 "TB 350.0 \"LIG_s3-\"\t{(*-lig+*).state[3]}\n";
print HED2 "ST \"$subtree2/subtree\"";
close HED2;

system("HHEd -H $subtree1/hmmdefs -M $subtree2 $subtreeHed2 $triligHmmlist");


#=====================================
# Create HED for subtree2 (state[4])
# lig+R
#=====================================
open HED3, ">$subtreeHed3" or die $!;
print HED3 "RO 2.0 $occStats\n";
print HED3 "TR 0\n";

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
    print HED3 "QS \"$Q\"\t{$cond_str}\n";
}

print HED3 "TR 2\n";
print HED3 "TB 350.0 \"LIG_s4-\"\t{(*-lig+*).state[4]}\n";
print HED3 "ST \"$subtree3/subtree\"";
close HED3;

system("HHEd -H $subtree2/hmmdefs -M $subtree3 $subtreeHed3 $triligHmmlist");


#=====================================
# Merge the 3 subtrees to "trees"
#=====================================
my %Q_hash = ();
open SUB1, "$subtree1/subtree" or die $!;
my $state2_str = "";
while(my $line = <SUB1>)
{
    if ($line =~ /^QS '(.+)'/) # question
    {
	$Q_hash{$1} = $line;
    }
    elsif ($line =~ /^lig/) # start of a lig tie state
    {
	$state2_str = $line;
	while ($line = <SUB1>)
	{
	    $state2_str = $state2_str.$line;
	}
    }
}
close SUB1;

open SUB2, "$subtree2/subtree" or die $!;
my $state3_str = "";
while(my $line = <SUB2>)
{
    if ($line =~ /^QS '(.+)'/) # question
    {
	$Q_hash{$1} = $line;
    }
    elsif ($line =~ /^lig/) # start of a lig tie state
    {
	$state3_str = $line;
	while ($line = <SUB2>)
	{
	    $state3_str = $state3_str.$line;
	}
    }
}
close SUB2;

open SUB3, "$subtree3/subtree" or die $!;
my $state4_str = "";
while(my $line = <SUB3>)
{
    if ($line =~ /^QS '(.+)'/) # question
    {	
	$Q_hash{$1} = $line;
    }
    elsif ($line =~ /^lig/) # start of a lig tie state
    {
	$state4_str = $line;
	while ($line = <SUB3>)
	{
	    $state4_str = $state4_str.$line;
	}
    }
}
close SUB3;

open TREE, ">$treeDir/trees" or die $!;
foreach my $k (sort keys %Q_hash)
{
    print TREE $Q_hash{$k};
}
print TREE "\n";
print TREE $state2_str;
print TREE $state3_str;
print TREE $state4_str;
close TREE;

#====================================================
# Create tree.hed
# Run HHEd again to generate the fulllist & tiedlist
#====================================================
my $hmm3Dir = "$treeDir/trihmm3";
unless (-d $hmm3Dir){ make_path $hmm3Dir; }

open  TREEHED, ">$treeDir/tree.hed" or die $!;
print TREEHED "LT \"$treeDir/trees\"\n";
print TREEHED "AU \"$fulllist\"\n";  # the fulllist needs to be generated!
print TREEHED "CO \"$tiedlist\"\n";
close TREEHED;

system("HHEd -H $subtree3/hmmdefs -M $hmm3Dir $treeDir/tree.hed $triligHmmlist");
print "Manually craft $treeDir/trees with subtrees\n";
print "HHEd generates $hmm3Dir/hmmdefs + $tiedlist\n";



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
