# Mingyu @ Sep 03 2011
# The toppest scripts to control every exp with different datatypes
#
#             (dtype)          (dtype usr run)
# exp1_top.pl -----> exp1.pl -------------------> exp1_single.pl
#             |----> exp1_err_rep.pl
#             |----> exp1_res.pl
#             |----> exp1_avg_res.pl
#
#
#             (dtype)             (dtype run)
# exp2_top.pl |----> exp2.pl -------------------> exp2_single.pl
#             |----> exp2_err_rep.pl
#             |----> exp2_res.pl
#             |----> exp2_all_res.pl
#
#
#             (dtype)             (dtype run)
# exp3_top.pl ----> exp3.pl -------------------> exp3_single.pl
#             |---> exp3_err_rep.pl
#             |---> exp3_res.pl
#             |---> exp3_all_res.pl
#             |---> exp3_stats.pl
#
#

***** Generate the HTK data *****
The HTK requires certain format of data for training/testing, which can be exported
from 6DMG_loader. Currently, we need to manually move the exported HTK data (.htk)
to a desired location with a unique/meaningful folder name ($dtype).
Here's my naming convention for example:
- NPNVNOs2: normalized position, normalized velocity, and normalized orientation (scaled ver2)
- NGANW: normalized gravity-removal acceleration, normalized angular velocity

$data_dir refers to the base path of those $dtype folders.
For example:
 ~/Development/6DMG/data_htk/gestures/     <-- data_dir
                                       NPNVNOs2/    <-- datatype1
                                                gXX_YY_tZZ.htk
                                                ...
                                       NGANW/       <-- datatype2
                                                gXX_YY_tZZ.htk
                                                ...


***** Exp 1 (User depedent case): *****
Train with random 5 trials of a SINGLE right-handed user and test with the rest trials

1.0. exp1_single.pl [user] [datatype] [run#] [data_dir]
  Single run of one random instance of UD traning/testing
  Example:
  > perl exp1_single.pl B1 NPNVNOs2 1 ~/Development/6DMG/data_htk/gestures
  Example output:
   - results at exp1/B1/NPNVNOs2/run001
   - exp1/B1/NPNVNOs2/log001.txt
   - exp1/B1/NPNVNOs2/err001.txt (if something goes WRONG!)

1.1. exp1.pl [data_dir] [datatype_1] .. [datatype_n]
  Top level launcher for training/testing of given datatype(s).  Will go through
  all right-handed users and generate $totalRuns of random trials per user per datatype.
  Example:
  > perl exp1.pl ~/Development/6DMG/data_htk NPNVNOs2

1.2. exp1_err_rep.pl [data_dir] [datatype_1] .. [datatype_n]
  This script reports the runs that fails to complete (errXXX.txt exists).
  It also attempts to fix the "abnormal early termination problem".
  Run exp1_err_rep before collecting the results (exp1_res & exp1_avg_res).
  Example:
  > perl exp1_err_rep.pl ~/Development/6DMG/data_htk NPNVNOs2
  Example output:
   - exp1/err_rep.txt (Contain the total number of errors after redo)

1.3. exp1_res.pl [datatype_1] .. [datatype_n]
  This script collects the results from exp1.pl and computes the recognition
  accuracy and confusion matrices for the training/testing sets of specified
  datatype(s)
  Example:
  > perl exp1_res.pl NPNVNOs2
  Example output:
   - exp1/B1/NPNVNOs2_trn.txt
   - exp1/B1/NPNVNOs2_tst.txt

1.4 exp1_avg_res.pl [datatype_1] .. [datatype_n]
  This script collects the results of each user and do the average
  Example:
  > perl exp1_avg_res.pl NPNVNOs2
  Example output:
   - exp1/trn_res.txt
   - exp1/tst_res.txt


***** Exp 2 ( User independent case): *****
Train with random 5 right-handed users and test with 1) the rest 16 right-handers,
and 2) all 7 left-handers

2.1. exp2_single.pl [datatype] [run#] [data_dir]
  Single run of one random instance of UI training/testing
  Example:
  > perl exp2_single.pl NPNVNOs2 1 ~/Development/6DMG/data_htk/gestures
  Example output:
  - results at exp2/NPNVNOs2/run001
  - exp2/NPNVNOs2/log001.txt
  - exp2/NPNVNOs2/err001.txt (if something goes WRONG!)

2.2. exp2.pl [data_dir] [datatype_1] .. [datatype_n]
  Top level launcher for training/testing of given datatype(s).  Will generate
  $totalRuns of exp2_single instances with parallel processing.
  Example:
  > perl exp2.pl ~/Development/6DMG/data_htk/gestures NPNVNOs2

2.3. exp2_err_rep.pl [data_dir] [datatype_1] .. [datatype_n]
  This script reports the runs that fails to complete (errXXX.txt exists).
  It also attempts to fix the "abnormal early termination problem".
  Run exp2_err_rep before collecting the results (exp2_res & exp2_all_res).
  Example:
  > perl exp2_err_rep.pl ~/Development/6DMG/data_htk NPNVNOs2
  Example output:
   - exp2/err_rep.txt (Contain the total number of errors after redo)

2.4. exp2_res.pl [datatype_1] .. [datatype_n]
  This script collects the results from exp2.pl and computes the recognition
  accuracy and confusion matrices for the trainging/testing-R/testing-L sets
  of specified datatype(s).
  Example:
  > perl exp2_res.pl NPNVNOs2
  Example output:
  - exp2/NPNVNOs2_trn.txt
  - exp2/NPNVNOs2_tstR.txt
  - exp2/NPNVNOs2_tstL.txt

2.5. exp2_all_res.pl
  This script collects the results for all datatypes and generates a summary.
  Example:
  > perl exp2_all_res.pl
  Example output:
  - exp2/trn_res.txt
  - exp2/tstR_res.txt
  - exp2/tstL_res.txt


***** Exp 3 ( User independent case, Leave-one-out): *****
3.1. exp3_single.pl [datatype] [run#] [data_dir]
  Single run of leave-one-out training/testing process.  The run# specifies
  which user is left out.
  Example:
  > perl exp3_single.pl NPNVNOs2 1 ~/Development/6DMG/data_htk/gestures
  Example output:
  - results at exp3/NPNVNOs2/run001
  - exp3/NPNVNOs2/log001.txt
  - exp3/NPNVNOs2/err001.txt (if something goes WRONG!)

3.2. exp3.pl [data_dir] [datatype_1] .. [datatype_n]
  Top level launcher for training/testing of given datatype(s).  Will generate
  $totalRuns of exp3_single instance with parallel processing. $totalRuns should
  be equal to the total number of users for a complete leave-one-out evaluation.
  Example:
  > perl exp3.pl NPNVNOs2

3.3. exp3_err_rep.pl [data_dir] [datatype_1] .. [datatype_n]
  This script reports the runs that fails to complete (errXXX.txt exists).
  It also attempts to fix the "abnormal early termination problem".
  Run exp3_err_rep before collecting the results (exp2_res & exp2_all_res, etc).
  Example:
  > perl exp3_err_rep.pl ~/Development/6DMG/data_htk NPNVNOs2
  Example output:
   - exp3/err_rep.txt (Contain the total number of errors after redo)

3.4. exp3_res.pl [datatype_1] .. [datatype_n]
  This script collects the results from exp3.pl and computes the recognition
  accuracy and confusion matrices for the trainging/testing sets of specified
  datatype(s)
  Example:
  > perl exp3_res.pl NPNVNOs2
  Example output:
  - exp3/NPNVNOs2_trn.txt
  - exp3/NPNVNOs2_tst.txt

3.5. exp3_all_res.pl
  This script collects the results for all datatypes and generates a summary.
  Example:
  > perl exp3_all_res.pl
  Example output:
  - exp3/trn_res.txt
  - exp3/tst_res.txt

3.6. exp3_stats.pl
  This script compute the mean and standard deviation of leave-one-out testing results
  for each datatype done in exp3.
  Example:
  > perl exp3_stats.pl
  Example output:
  - exp3/tst_stats.txt
