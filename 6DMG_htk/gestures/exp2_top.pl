#!/usr/bin/perl
# Mingyu @ Sep 03 2011
# The toppest script to control every exp with different datatypes
#
#             (dtype)             (dtype run)
# exp2_top.pl |----> exp2.pl -------------------> exp2_single.pl
#             |----> exp2_err_rep.pl
#             |----> exp2_res.pl
#             |----> exp2_all_res.pl
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
# Exp 2. User independent case
#-------------------------------------------------------------------------
# Training & Testing
system("perl exp2.pl $data_dir $dtypes_str");

# Check the failed runs of exp2_single
system("perl exp2_err_rep.pl $data_dir $dtypes_str");

# Collect results > exp2_res
system("perl exp2_res.pl $dtypes_str");
system("perl exp2_all_res.pl);
