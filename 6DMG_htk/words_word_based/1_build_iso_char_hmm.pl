#!/usr/bin/perl
# Mingyu @ Feb 21 2013
# Train the char HMM with all trials of all SINGLE right-handed users

use strict;
use File::Path qw(make_path remove_tree);
use File::stat;

my $usr = "all";
my $data_dir;
my $dtype;
if ($#ARGV !=1)
{
    print "usage: build_iso_char_hmm [data_dir] [datatype]\n";
    print " [data_dir]: the base path to the \$datatype folder(s)\n";
    exit;
}
else
{
    $data_dir = $ARGV[0];  # the base path to the \$datatype folder
    $dtype    = $ARGV[1];  # "AW", "PO", etc.
}

#-------------------------------------------------------------------------
# Define the chars in use
#-------------------------------------------------------------------------
my @gests = (
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


# hash to store the state # for each character
my %stateHash = (
     "upp_A" => 14,
     "upp_B" => 16,
     "upp_C" => 10,
     "upp_D" => 14,
     "upp_E" => 18,
     "upp_F" => 14,
     "upp_G" => 12,
     "upp_H" => 12,
     "upp_I" => 10,
     "upp_J" => 10,
     "upp_K" => 12,
     "upp_L" => 10,
     "upp_M" => 12,
     "upp_N" => 12,
     "upp_O" => 10,
     "upp_P" => 12,
     "upp_Q" => 12,
     "upp_R" => 16,
     "upp_S" => 10,
     "upp_T" => 10,
     "upp_U" => 10,
     "upp_V" => 10,
     "upp_W" => 14,
     "upp_X" => 10,
     "upp_Y" => 10,
     "upp_Z" => 10
);

# @gest4files: the gest file name (different from the class label name)
my @gest4files = ();
foreach my $g (@gests)
{
    if ($g =~ m/num_(\d)/)
    {
	push(@gest4files,$g);
    }
    elsif ($g =~ m/upp_([A-Z])/)
    {
	push(@gest4files,"upper_$1");
    }
    elsif ($g =~ m/low_([a-z])/)
    {
	push(@gest4files,"lower_$1");
    }
}

my @usrs = ();
push(@usrs, "A1", "C1", "C2", "C3", "C4");
push(@usrs, "E1", "G1", "G2", "G3", "I1");
push(@usrs, "I2", "I3", "J1", "J3", "L1");    
push(@usrs, "M1", "S1", "U1", "Y1", "Y3");
push(@usrs, "Z1", "Z2");

#-------------------------------------------------------------------------
# Set some common parameters
# Check directories and setup paths
# Prepare the log and err files (Redirect STDOUT & STDERR)
#-------------------------------------------------------------------------
my $gMLF  = "mlf/iso_char.mlf";  # global def of char MLF
my $path  = "iso_char/$dtype/$usr";
my $trn_script = "$path/train.scp";
my $tst_script = "$path/test.scp";
my $hmm0  = "$path/hmm0";
my $hmm1  = "$path/hmm1";
my $hmm2  = "$path/hmm2";
my $trnMLF= "$path/trn.mlf";
my $tstMLF= "$path/tst.mlf";
my $opt    = "-A -T 1";
my $minVar = "-v 0.001";

unless ((-d $hmm0) and (-d $hmm1) and (-d $hmm2))
{
    make_path "$hmm0";
    make_path "$hmm1";
    make_path "$hmm2";
}

open FILE_trn, ">$trn_script" or die $!;
open FILE_tst, ">$tst_script" or die $!;
    
foreach my $g (@gest4files)
{
    foreach my $u (@usrs)
    {
	foreach my $j (1..10) # use all data for char model training (for word recognition)
	{
	    my $trn_name = sprintf("%s_%s_t%02d.htk", $g, $u, $j);
	    print FILE_trn "$data_dir/data_$dtype/$trn_name\n";	    
	}
	my $tst_name = sprintf("%s_%s_t%02d.htk", $g, $u, 10);
	print FILE_tst "$data_dir/data_$dtype/$tst_name\n";
    }
}

close FILE_trn;
close FILE_tst;

open (REGOUT, ">&STDOUT")    or die "Can't open REGOUT: $!\n";
open (STDOUT, ">$path/log.txt") or die $!;
open (STDERR, ">$path/err.txt") or die $!;


#-------------------------------------------------------------------------
# Prepare the word model, dictionary, grammer, and word network
#-------------------------------------------------------------------------
my $hmmlist = "$path/gestList";
my $dic     = "$path/gestDic";
my $gram    = "$path/gestGram";
my $wnet    = "$path/gestNet";
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
# HCompV & HInit & HRest
# -A: print current prompt argument
# -T: trace
# -S: script for data files (.htk)
# -M: output HMM dir
# -o: output name of the HMM
# -n: use the Var from HCompV
#-------------------------------------------------------------------------
foreach my $gest (@gests)
{
    my $states= $stateHash{$gest};
    my $proto = "proto/$dtype/template_$states";
    unless(-e $proto){ system("perl 0_gen_single_proto.pl $dtype $states"); }

    # Mingyu: after proper linear scaling, HCompV seems to work worse than HInit directly.
    #&systemE("HCompV $opt -I $gMLF -l $gest -S $trn_script -M $hmm0 -o $gest $proto", "Error: HCompV()");
    #&systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -n $hmm0/$gest", "Error: HInit()"); # -n use the var from    
    &systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -o $gest $proto", "Error: HInit()");
    &systemE("HRest  $opt -I $gMLF -l $gest -S $trn_script -M $hmm2 $hmm1/$gest", "Error: HRest()");
}

#-------------------------------------------------------------------------
# Recognition
# HVite & HResults
# Mingyu: HRestuls in upper layer after 50 trials
#-------------------------------------------------------------------------
# Test with the training set
&systemE("HVite $opt -d $hmm2 -S $trn_script -i $trnMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Test with the testing set
&systemE("HVite $opt -d $hmm2 -S $tst_script -i $tstMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Collect recognition results
&systemE("HResults $opt -p -I $gMLF $hmmlist $trnMLF", "Error: HResults()");
&systemE("HResults $opt -p -I $gMLF $hmmlist $tstMLF", "Error: HResults()");


#-------------------------------------------------------------------------
# Finish: clean up
#-------------------------------------------------------------------------
close REGOUT;
close STDOUT;
close STDERR;

if (stat("$path/err.txt")->size == 0) # no stderr
{
    unlink("$path/err.txt");
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
