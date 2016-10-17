#!/usr/bin/perl
# Mingyu @ Sep 03 2011
# The toppest script to control every exp with different datatypes
#             (dtype)          (dtype usr run)
# exp1_top.pl -----> exp1.pl -------------------> exp1_single.pl
#             |----> exp1_err_rep.pl
#             |----> exp1_res.pl
#             |----> exp1_avg_res.pl
# 
# Here're a few example datatype names, which should be manually moved
# from 6DMG_loader and refer to a specific folder of the exported .htk files:
# $dtypes_str = "A AW P PO V W O NP NV NO NGA NW".
#               "NPNVNOs2 NGANW NPNVNOs2NGANW";
$dtypes_str = "NPNVNOs2 NOs2NWNGA NP";
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
# Exp 1. User dependent case
#-------------------------------------------------------------------------
# Training & Testing
system("perl exp1.pl $data_dir $dtypes_str");

# Check the failed runs of exp1_single
system("perl exp1_err_rep.pl $data_dir $dtypes_str");

# Collect the results of each user
system("perl exp1_res.pl $dtypes_str");

# Collect the overall avg results > exp1_res
system("perl exp1_avg_res.pl $dtypes_str");
