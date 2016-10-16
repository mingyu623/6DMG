#!/usr/bin/perl
# Mingyu @ Aug 30 2011
# User Independent case
# Train with random 5 right-handed users and test with:
# Exp 2.1: the rest 16 right-handers
# Exp 2.2: all 7 left-handers
# Run exp2.pl on top of exp2_single.pl (single run only)

use File::Path qw(make_path remove_tree);
use File::stat;

if ($#ARGV !=2)
{
    print "usage: exp2_single [datatype] [run#] [data_dir]\n";
    print " [data_dir]: the base path to the \$datatype folder\n";
    exit;
}
else
{
    $dtype = $ARGV[0]; # "AW", "PO", etc.
    $run   = $ARGV[1]; # specify the combination of trials for training
    $runStr= sprintf("%03d", $run); # $run should start from 1!
    $data_dir = $ARGV[2];
}

#-------------------------------------------------------------------------
# Define the gestures in use and the users
#-------------------------------------------------------------------------
@gests = ();
for (my $i=0; $i<20; $i++)
{
    $gests[$i] = sprintf("g%02d", $i);
}

@userL = ("D2", "F1", "J4", "R1", "S3", "W2", "Y2");
@userR = ("B1", "B2", "C1", "C2", "D1", "J1", "J2", "J3", "J5", "M1",
          "M2", "M3", "R2", "S1", "S2", "T1", "T2", "U1", "W1", "Y1",
          "Y3");

#-------------------------------------------------------------------------
# Set some common parameters
# Check directories and setup paths
# Prepare the log and err files (Redirect STDOUT & STDERR)
#-------------------------------------------------------------------------
$gMLF  = "mlf/gest.mlf";  # global def of gest MLF
$path  = "exp2/$dtype";
$trn_script  = "$path/run$runStr/train.scp";
$tstR_script = "$path/run$runStr/testR.scp";
$tstL_script = "$path/run$runStr/testL.scp";
$hmm0  = "$path/run$runStr/hmm0";
$hmm1  = "$path/run$runStr/hmm1";
$proto = "proto/template_$dtype"; # the HMM proto
$trnMLF  = "$path/run$runStr/trn.mlf";
$tstRMLF = "$path/run$runStr/tstR.mlf";
$tstLMLF = "$path/run$runStr/tstL.mlf";
$opt    = "-A -T 1";
$minVar = "-v 0.001";

unless ((-d $hmm0) and (-d $hmm1))
{
    make_path "$hmm0";
    make_path "$hmm1";
}


my $line = &extract("UI.idx", $run);
chomp($line);
@idx = split("\t", $line); # idx is in Matlab fashion (1st is 1)
my @trnIdx = @idx[0..4];
my @tstIdx = @idx[5..20];

open FILE_trn,  ">$trn_script"  or die $!;
open FILE_tstR, ">$tstR_script" or die $!;
open FILE_tstL, ">$tstL_script" or die $!;

foreach my $g (@gests)
{        
    foreach my $i (@trnIdx)  # Training set
    {
	my $R = $userR[$i-1];
	foreach my $j (1..10)
	{
	    my $trn_name = sprintf("%s_%s_t%02d.htk", $g, $R, $j);
	    print FILE_trn "$data_dir/$dtype/$trn_name\n";
	}
    }

    foreach my $i (@tstIdx)  # R-Testing set
    {
	my $R = $userR[$i-1];
	foreach my $j (1..10)
	{
	    my $tst_name = sprintf("%s_%s_t%02d.htk", $g, $R, $j);	
	    print FILE_tstR "$data_dir/$dtype/$tst_name\n";
	}
    }

    foreach my $L (@userL)   # L-Testing set
    {
	foreach my $j (1..10)
	{
	    my $tst_name = sprintf("%s_%s_t%02d.htk", $g, $L, $j);
	    print FILE_tstL "$data_dir/$dtype/$tst_name\n";
	}	
    }
}

close FILE_trn;
close FILE_tstR;
close FILE_tstL;

open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/log$runStr.txt") or die $!;
open (STDERR, ">$path/err$runStr.txt") or die $!;


#-------------------------------------------------------------------------
# Prepare the word model, dictionary, grammer, and word network
#-------------------------------------------------------------------------
$hmmlist = "$path/run$runStr/gestList";
$dic     = "$path/run$runStr/gestDic";
$gram    = "$path/run$runStr/gestGram";
$wnet    = "$path/run$runStr/gestNet";
open FILE_model, ">$hmmlist" or die $!; # gestList = hmmList (each gest has its own hmm)
open FILE_dic,   ">$dic"     or die $!;
open FILE_gram,  ">$gram"    or die $!;

foreach my $g (@gests)
{
    print FILE_model "$g\n";
    print FILE_dic   "$g\t$g\n";
}
print FILE_gram  "\$gest = ".join(' | ', @gests)." \;\n";
print FILE_gram  "( \$gest ) ";

close FILE_model or die $!;
close FILE_dic   or die $!;
close FILE_gram  or die $!;

&systemE("HParse $gram $wnet", "Error: HParse()");


#-------------------------------------------------------------------------
# Training
# HInit & HRest
# -A: print current prompt argument
# -T: trace
# -S: script for data files (.htk)
# -M: output HMM dir
# -o: output name of the HMM
#-------------------------------------------------------------------------
# change to foreach $gest (@gests)
foreach my $gest (@gests)
{
    &systemE("HInit $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm0 -o $gest $proto", "Error: HInit()");
    &systemE("HRest $opt -I $gMLF -l $gest -S $trn_script -M $hmm1 $hmm0/$gest", "Error: HRest()");
}

#-------------------------------------------------------------------------
# Recognition
# HVite & HResults
# Mingyu: HRestuls in upper layer after 50 trials
#-------------------------------------------------------------------------
# Test with the training set
&systemE("HVite $opt -d $hmm1 -S $trn_script -i $trnMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Test with the R-testing set
#&systemE("HVite $opt -n 5 5 -d $hmm1 -S $tstR_script -i $tstRMLF -w $wnet $dic $hmmlist", "Error: HVite()"); # N-best
&systemE("HVite $opt -d $hmm1 -S $tstR_script -i $tstRMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Test with the L-testing set
&systemE("HVite $opt -d $hmm1 -S $tstL_script -i $tstLMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Collect recognition results
&systemE("HResults $opt -I $gMLF $hmmlist $trnMLF",  "Error: HResults()");
&systemE("HResults $opt -I $gMLF $hmmlist $tstRMLF", "Error: HResults()");
&systemE("HResults $opt -I $gMLF $hmmlist $tstLMLF", "Error: HResults()");

#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/err$runStr.txt")->size == 0) # no stderr
{
    unlink("$path/err$runStr.txt");
}

#-------------------------------------------------------------------------
# systemE()-Execute perl's system() and then catch any error.
#-------------------------------------------------------------------------
sub systemE
{
    # Get arguments
    my ($commandString, $optionalString) = @_;
    system($commandString)==0  or die "Error: $optionalString:$?\n";
}

#-------------------------------------------------------------------------
# extract()-Return certain line of a given file
#-------------------------------------------------------------------------
sub extract
{
    my ($filename, $line_no)=@_;
    my $line;
    open (FILE, $filename) || die "$filename can't be opened $! ";
    if ($line_no =~ /\D/) {
        while ($line=<FILE>) {
            if ($line =~ /$line_no/) {
                return $line;
            }
        }
    }
    else {
	foreach (1..$line_no) {
	    $line = <FILE>;
        }
        return $line;
    }
}
