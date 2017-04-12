#!/usr/bin/perl
# Mingyu @ Aug 29 2011
# User Dependent case
# Train with random 5 trials of a SINGLE right-handed user and test with the rest 5 trials
# Should use the exp1.pl to call exp1_single.pl
use File::Path qw(make_path remove_tree);
use File::stat;

if ($#ARGV !=3)
{
    print "usage: exp1_single [user] [datatype] [run#] [data_dir]\n";
    print " [data_dir]: the base path to the \$datatype folder\n";
    exit;
}
else
{
    $usr   = $ARGV[0]; # "B1", "C1", etc. 
    $dtype = $ARGV[1]; # "AW", "PO", etc.
    $run   = $ARGV[2]; # specify the combination of trials for training
    $runStr= sprintf("%03d", $run);
    $data_dir = $ARGV[3]; # base path to the data folder of .htk files
}

#-------------------------------------------------------------------------
# Define the gestures in use
#-------------------------------------------------------------------------
@gests = ();
for (my $i=0; $i<20; $i++)
{
    $gests[$i] = sprintf("g%02d", $i);
}


#-------------------------------------------------------------------------
# Set some common parameters
# Check directories and setup paths
# Prepare the log and err files (Redirect STDOUT & STDERR)
#-------------------------------------------------------------------------
$gMLF  = "mlf/gest.mlf";  # global def of gest MLF
$path  = "exp1/$usr/$dtype";
$trn_script = "$path/run$runStr/train.scp";
$tst_script = "$path/run$runStr/test.scp";
$hmm0  = "$path/run$runStr/hmm0";
$hmm1  = "$path/run$runStr/hmm1";
$hmm2  = "$path/run$runStr/hmm2";
$proto = "proto/template_$dtype"; # the HMM proto
$trnMLF= "$path/run$runStr/trn.mlf";
$tstMLF= "$path/run$runStr/tst.mlf";
$opt    = "-A -T 1";
$minVar = "-v 0.001";

unless ((-d $hmm0) and (-d $hmm1) and (-d $hmm2))
{
    make_path "$hmm0";
    make_path "$hmm1";
    make_path "$hmm2";
}

#unless ((-e $trn_script) and (-e $tst_script))
{
    my $line = &extract("UD.idx", $run);
    chomp($line);
    @idx = split("\t", $line);

    open FILE_trn, ">$trn_script" or die $!;
    open FILE_tst, ">$tst_script" or die $!;
    
    foreach my $g (@gests)
    {
	foreach my $j (0..4)
	{
	    my $trn_name = sprintf("%s_%s_t%02d.htk", $g, $usr, $idx[$j]);
	    my $tst_name = sprintf("%s_%s_t%02d.htk", $g, $usr, $idx[$j+5]);
	    print FILE_trn "$data_dir/$dtype/$trn_name\n";
	    print FILE_tst "$data_dir/$dtype/$tst_name\n";
	}
    }

    close FILE_trn;
    close FILE_tst;
}

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
    ## Mingyu: after proper linear scaling, HCompV seems to work worse than HInit directly.
    #&systemE("HCompV $opt -I $gMLF -l $gest -S $trn_script -M $hmm0 -o $gest $proto",
    #         "Error: HCompV()");
    #&systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -n $hmm0/$gest",
    #         "Error: HInit()"); # -n use the var from
    &systemE("HInit  $opt $minVar -I $gMLF -l $gest -S $trn_script -M $hmm1 -o $gest $proto",
             "Error: HInit()");
    &systemE("HRest  $opt -I $gMLF -l $gest -S $trn_script -M $hmm2 $hmm1/$gest",
             "Error: HRest()");
}

#-------------------------------------------------------------------------
# Recognition
# HVite & HResults
# Mingyu: HRestuls in upper layer after 50 trials
#-------------------------------------------------------------------------
# Test with the training set
&systemE("HVite $opt -d $hmm1 -S $trn_script -i $trnMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Test with the testing set
&systemE("HVite $opt -d $hmm1 -S $tst_script -i $tstMLF -w $wnet $dic $hmmlist", "Error: HVite()");

# Collect recognition results
&systemE("HResults $opt -I $gMLF $hmmlist $trnMLF", "Error: HResults()");
&systemE("HResults $opt -I $gMLF $hmmlist $tstMLF", "Error: HResults()");


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
