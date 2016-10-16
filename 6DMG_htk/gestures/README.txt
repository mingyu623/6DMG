# Mingyu @ Sep 03 2011
# The toppest script to control every exp with different datatypes
#
#          (dtype)             (dtype usr run)
# exp.pl ----------> exp1.pl -------------------> exp1_single.pl#             
#             |----> exp1_err_rep.pl
#             |----> exp1_res.pl
#             |----> exp1_avg_res.pl
#             |             
#             |                   (dtype run)
#             |----> exp2.pl -------------------> exp2_single.pl
#             |----> exp2_err_rep.pl
#             |----> exp2_res.pl
#             |----> exp2_all_res.pl
#

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

1.2. exp1_err_rep.pl [datatype_1] .. [datatype_n]
  This script reports the runs that fails to complete (errXXX.txt exists).
  It also attempts to fix the "abnormal early termination problem".
  Run exp1_err_rep before collecting the results (exp1_res & exp1_avg_res).
  Example:
  > perl exp1_err_rep.pl NPNVNOs2
  Example output:
   - exp1/err_rep.txt (Contain the total number of errors after redo)

1.3. exp1_res.pl [datatype_1] .. [datatype_n]
  This script collects the results rom exp1.pl and computes the recognition
  accuracy and confusion matrix for the training/testing sets.
  Example:
  > perl exp1_res.pl NPNVNOs2
  Example output:
   - exp1/B1/NPNVNOs2_trn.txt
   - exp1/B1/NPNVNOs2_tst.txt
***** Exp 2 ( User independent case): *****
