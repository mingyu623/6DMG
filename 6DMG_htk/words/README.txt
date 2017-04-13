# Mingyu @ Apr 12 2017
# 
# Here, we perform the training/testing of motion words
#

0. 0_gen_single_proto.pl [datatype] [# states]
  This script generates one proto file for HTK with specified data type and states number.
  [Note] the user needs the proto templates for state numbers of 3, 10, 12, 14, 16, 18 to
  run the following step.
  Example:
  > perl 0_gen_single_proto.pl NPNV 10
  Output:
   - proto/NPNV/template_10














1.1. 1_build_iso_char_hmm_single.pl [tstUsr] [data_dir] [datatype]
  This script will train/test the char HMM with speicified test user and datatype.
  The training set contains all users excluding the test user.  If tstUsr is "all",
  we will use all users for training.
  Example:
  > perl 1_build_iso_char_hmm_single.pl M1 ~/Development/6DMG/data_htk/chars NPNV
  Output:
   - iso_char/NPNV/M1/hmm0
   - iso_char/NPNV/M1/hmm1
   - iso_char/NPNV/M1/hmm2     (final HMM models)
   - iso_char/NPNV/M1/train.scp
   - iso_char/NPNV/M1/test.scp
   - iso_char/NPNV/M1/log.txt
   - iso_char/NPNV/M1/err.txt  (only exists when something goes wrong)

1.2. 1_batch.pl [data_dir]
  This script runs a top level leave-one-out validation using 1_build_iso_char_hmm_single.pl
  Example:
  > perl 1_batch.pl ~/Development/6DMG/data_htk/chars

2. 2_stats.pl
  This script collects the results from Step 1.2 and generates the stats of
  character error rate (CER) for each datatype, each leave-one-out case, and
  overall results.
  Example:
  > perl 2_stats.pl
  Ouput:
   - res.txt
