# Mingyu @ Apr 13 2017
# Perform letter-level word recognition of airwriting on spotted writing
# segments with leave-one-out cross validation.

0. 0_generate_share.pl
  This script is identical to LeaveOneOut/0_1_generate_share.pl (internally
  uses LeaveOneOut/0_0_generate_wdnet_bigram.pl
  Example:
  > perl 0_1_generate_share.pl
  Output:
   - share/wdnet_bigram_100
   - share/wdnet_bigram_100f
   - share/wdnet_bigram_1k
   - share/wdnet_bigram_1kf
   - share/word_ref.mlf

1.2. 1_2_prep_tst_scp_single.pl [datatype] [tst usr]
  This script is similar to LeaveOneOut/1_3_prep_det_tst_scp_single.pl
  except that we now generate the test .scp from ground-truth segments.
  Example:
  perl 1_2_prep_tst_scp_single.pl NP2DuvNV2D M1
  Output:
   - products/NP2DuvNV2D/C1/test.scp
   - products/NP2DuvNV2D/C1/testOOV.scp
   - products/NP2DuvNV2D/C1/det_ref.mlf (for HResults)
  
1.3. 1_3_batch.pl
  This script launches Step 1.0 to Step 1.3 for each test users with leave-one-out
  cross validation and each specified datatype.
  [NOTE] We re-use the LeaveOneOut/1_0 & 1_1 scripts.
  Example:
  > perl 1_4_batch.pl

2. 2_batch.pl
  This script lauches Step 2.0 and Step 2.1 for all leave-one-out combinations
  for each specified datatype and test users.
  [NOTE] We re-use the LeaveOneOut/2_0 & 2_1 scripts.
  Example:
  > perl 2_batch.pl










3.0. 3_0_viterbi_bigram_nbest.pl [datatype] [tree#] [tst usr] [voc] [detOption]
  This script uses the testing script generated from Step 1.3.
  This script performs viterbi decoding with specified datatype, decision tree,
  test user, vocabulary for bigram, and detection option ("det" or "merge").
  See the script for details of input arguments.
  The viberbi decoding will do nbest decoding where nbest is hardcoded to 5.
  To speed up, feel free to lower he nbest number (smallest is 1).
  Example:
  > perl 3_0_viterbi_bigram_nbest.pl NP2DuvNV2D 0 C1 1k det
  Output:
   - products/NP2DuvNV2D/C1/tree0/log_dec_bigram_1k_nbest.log
   - products/NP2DuvNV2D/C1/tree0/err_dec_bigram_1k_nbest.log (exists when something goes wrong)
   - products/NP2DuvNV2D/C1/tree0/dec_bigram_nbest_1k.mlf
   - products/NP2DuvNV2D/C1/tree0/dec_bigram_nbest_OOV_1k.mlf
   - products/NP2DuvNV2D/C1/tree0/dec_imprecise_nbest_1k.mlf (depends on detection)
   - products/NP2DuvNV2D/C1/tree0/dec_imprecise_nbest_OOV_1k.mlf (depends on detection)
   - products/NP2DuvNV2D/C1/tree0/dec_FA_nbest_1k.mlf (depends on detection)

3.1. 3_1_batch.pl
  This script lauches Step 3.0 for all leave-one-out combinations for each
  specified datatype and test users, both decision tree 0 and tree 1,
  four different language models:
    1) 100:  100-word voc w/  backoff
    2) 100f: 100-word voc w/o backoff
    3) 1k:   1k-word voc w/  backoff
    4) 1kf:  1k-word voc w/o backoff
  two detection options:
    1) det: the direct detected airwriting segments
    2) merge: the merged detected airwriting segments
  Example:
  > perl 3_1_batch.pl

4. 4_stats_bigram_nbest.pl
  This script collects the results from Step 3.1. and generates the stats of
  character error rate (CER) and word error rate (WER) for each leave-one-out test user
  and the overall average / standard deviations.
  Example:
  > perl 4_stats_bigram_nbest.pl
  Output:
   - results/res_[bigram/merge]_[voc]_[n]best.txt

5.0. 5_0_word_err_adjust.pl [datatype] [tree#] [voc] [verbose]
  This script adjusts the detected event error rate to word error rate properly.
  This script only applies to the testing scp of Step 1.3. (direct detected airwriting segments)
  [verbose] can be 0, 1, 2 to specify the verbose level for output.
  For instance, C1_MUCH is detected as C1_MUCH1 (label MU, decoded as MU) and
  C1_MUCH2 (label CH, decoded as CH).  Thus, we adjust two segments into one word with both
  zero event error and zero word error.  Another example, C1_EMPL is detected as C1_EMPL1
  (label EMP, decoded as EMP).  The event is decoded correctly.  However, the word is NOT
  detected completely (the L event is NOT detected), so it counts as one word error.
  Example:
  > perl 5_word_err_adjust.pl NP2DuvNV2D 0 1k 2
  Output:
   - Information printed on terminal (stdout)

5.1. 5_1_batch.pl
  This script runs Step 5.0 for all combinations of datatypes and vocs, and pipe the stdout
  to one result file per vocabulary.
  Example:
  > perl 5_1_batch.pl
  Output:
   - results/adj_bigram_[voc].txt
