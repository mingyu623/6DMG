#!/usr/bin/perl
# Mingyu @ Jul 02 2012
# The toppest script to control every exp with different datatypes
#
#                (dtype)               (dtype run)
# exp3_top.pl ----------> exp3.pl -------------------> exp3_single.pl
#                  |----> exp3_err_rep.pl
#                  |----> exp3_res.pl
#                  |----> exp3_all_res.pl
#                  |----> exp3_stats.pl
#
# 
# Here're a few example datatype names, which should be manually moved
# from 6DMG_loader and refer to a specific folder of the exported .htk files:
# $dtypes_str = "A AW P PO V W O NP NV NO NGA NW".
#               "NPNVNOs2 NGANW NPNVNOs2NGANW";
$dtypes_str = "NPNVNOs2 NOs2NWNGA";
$data_dir = "../../data_htk/gestures";

#-------------------------------------------------------------------------
# Sanity check for HTK data
#-------------------------------------------------------------------------
my @myDataTypes = split(' ', $dtypes_str);
foreach my $dtype (@myDataTypes)
{
    my $dtype_dir = $data_dir.'/'.$dtype;
    opendir($dh, $dtype_dir) or die "Cannot open $dtype_dir";
    my $num_htks = grep(/\.htk$/, readdir($dh));
    if ($num_htks == 0)
    {
        die "$dtype_dir has no .htk files!";
    }
}

#-------------------------------------------------------------------------
# Configuration
#-------------------------------------------------------------------------

if ($#ARGV <0)
{
    print "usage: exp3 [options] ... [options]\n";
    print "[option] 1: run exp3.pl         (training & testing)\n";
    print "         2: run exp3_err_rep.pl (check failed run)\n";
    print "         3: run exp3_res.pl, exp3_all_res.pl  (collect the results)\n";
    print "         4: run exp3_stats.pl (calculate avg, std)\n";
    exit;
}

@options = @ARGV;

my $opt1 = 0;
my $opt2 = 0;
my $opt3 = 0;
my $opt4 = 0;
foreach my $opt (@options)
{
    if ($opt == 1)
    {
	print "run exp3.pl\n";
	$opt1 = 1;
    }
    elsif ($opt == 2)
    {
	print "run exp3_err_rep.pl\n";
	$opt2 = 1;
    }
    elsif ($opt == 3)
    {
	print "run exp3_res.pl & exp3_all_res.pl\n";
	$opt3 = 1;
    }
    elsif ($opt == 4)
    {
	print "run exp3_stats.pl\n";
	$opt4 = 1;
    }
}

#-------------------------------------------------------------------------
# Exp 3
#-------------------------------------------------------------------------
# Training & Testing
if ($opt1)
{
    system("perl exp3.pl $data_dir $dtypes_str");
}


# Check the failed runs of exp3_single
if ($opt2)
{
    system("perl exp3_err_rep.pl $data_dir $dtypes_str");
}

# Collect the results of each leave-one-out test and the overall results
if ($opt3)
{
    system("perl exp3_res.pl $dtypes_str");  # generate the confusion matrix for each data type
    system("perl exp3_all_res.pl");          # generate a summary report for all data types
}

# Calculate the avg and std of each datatype
if ($opt4)
{
    system("perl exp3_stats.pl");
}
