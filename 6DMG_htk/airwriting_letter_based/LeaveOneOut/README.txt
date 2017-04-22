# Mingyu @ Apr 13 2017
# Perform letter-level word recognition of airwriting on spotted writing
# segments with leave-one-out cross validation.

0.0. 0_0_generate_wdnet_bigram.pl [voc]
  This script generates the wdnet with bigram estimated from the given vocabulary with 
  or without backoff.
  Extra requirement:
  Need the 2-gram language model estimated from the specified vocabulary:
    100, 100f, (share/voc2_chars_100_linear.arpa) 
    1k,  1kf   (share/voc2_chars_1k_linear.arpa)
  produced by the CMU-Cambridge Statistical Language Modeling Toolkit.
  Example:
  > perl 0_0_generate_wdnet_bigram.pl 1k
  Output:
   - share/wdnet_bigram_1k

0.1. 0_1_generate_share.pl
  This script generates the datatype invariant shared files for all following steps.
  This script will perform Step 0.0 for the following voc: 100, 100f, 1k, 1kf
  [NOTE] We hardcoded in the script for the location of all the airwriting data.
  Example:
  > perl 0_1_generate_share.pl
  Output:
   - share/wdnet_bigram_100
   - share/wdnet_bigram_100f
   - share/wdnet_bigram_1k
   - share/wdnet_bigram_1kf
   - share/word_ref.mlf

1.0. 1_0_init_fil.pl [datatype]
  This script initialized the "fil" HMM with HCompV
  Example:
  > perl 1_0_init_fil.pl NP2DuvNV2D
  Output:
   - products/NP2DuvNV2D/all_det.scp
   - products/NP2DuvNV2D/fil  (the filler HMM)

1.1. 1_1_prep_trn_scp_hmmdef_single.pl [datatype] [tst usr]
  This script prepares the training scripts for leave-one-out cross validation,
  generates the HMM definitions for tri-ligs and chars, and performs embedded
  re-estimation. See the script for more details.
  Extra requirement:
  ../words_word_based/char_lig/$dtype/Extension/iso/hmm3/hmmdefs_iso
  This file has to be generated first by running words_word_based experiment.
  Example:
  > perl 1_1_prep_trn_scp_mlf_hmmdefs.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/fulllist
   - products/NP2DuvNV2D/C1/mono_char_tri_lig.mlf
   - products/NP2DuvNV2D/C1/train.scp
   - products/NP2DuvNV2D/C1/trihmm0/
   - products/NP2DuvNV2D/C1/trihmm1/
   - products/NP2DuvNV2D/C1/trihmm2/  (the tri-state HMMs will be for training/testing)
   - products/NP2DuvNV2D/C1/triligHmmlist
   - products/NP2DuvNV2D/C1/trilig_stats.txt

1.2. 1_2_prep_merge_tst_scp_single.pl [datatype] [tst usr]
  This script generates the testing scps from data_htk/airwriting_spot_merge
  for the test user.  Also generates the corresponding merge_ref.mlf for HResult.
  [NOTE] OOV: Out of Vocabulary
  Example:
  > perl 1_2_prep_merge_tst_scp_single.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/merge_tst.scp
   - products/NP2DuvNV2D/C1/merge_tstOOV.scp
   - products/NP2DuvNV2D/C1/merge_imprecise.scp
   - products/NP2DuvNV2D/C1/merge_impreciseOOV.scp
   - products/NP2DuvNV2D/C1/merge_FA.scp
   - products/NP2DuvNV2D/C1/merge_ref.mlf (for HResults)

1.3. 1_3_prep_det_tst_scp_single.pl [datatype] [tst usr]
  This script generates the testing scps from data_htk/airwriting_spot for the
  test user. Also generates the corresponding det_ref.mlf for HResult.
  Example:
  > perl 1_3_prep_det_tst_scp_single.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/test.scp
   - products/NP2DuvNV2D/C1/testOOV.scp
   - products/NP2DuvNV2D/C1/imprecise.scp
   - products/NP2DuvNV2D/C1/impreciseOOV.scp
   - products/NP2DuvNV2D/C1/FA.scp
   - products/NP2DuvNV2D/C1/det_ref.mlf (for HResults)

1.4. 1_4_prep_groundtruth_tst_scp_single.pl [datatype] [tst usr]
  This script generates the testing scps from data_htk/airwriting_spot for the
  test user using the groundtruth segments.
  Also generates the corresponding gt_ref.mlf for HResult.
  Example:
  > perl 1_4_prep_groundtruth_tst_scp_single.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/gt_test.scp
   - products/NP2DuvNV2D/C1/gt_testOOV.scp
   - products/NP2DuvNV2D/C1/gt_ref.mlf (for HResults)

1.5. 1_5_batch.pl
  This script launches Step 1.0 to Step 1.4 for each test users with leave-one-out
  cross validation and each specified datatype.
  Example:
  > perl 1_5_batch.pl

2.0. 2_0_make_tree.pl [datatype] [test usr]
  This script generates the hed file for HHed for the decision tree to tie the ligature models
  and leave the char model untouched. Will output "qniqueDict": all the unique ligatures + 26 char HMM
  Example:
  > perl 2_0_make_tree.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/tree0/fullDict       (covers 26x26 ligs + 26 chars for HVite)
   - products/NP2DuvNV2D/C1/tree0/uniqueDict     (all the unique ligs from decision tree + 26 chars)
   - products/NP2DuvNV2D/C1/tree0/trees          (the generated decision tree)
   - products/NP2DuvNV2D/C1/tree0/trihmm3/
   - products/NP2DuvNV2D/C1/tree0/trihmm4/
   - products/NP2DuvNV2D/C1/tree0/trihmm5/       (final HERest HMMs)
   - products/NP2DuvNV2D/C1/tree0/log_tree.log
   - products/NP2DuvNV2D/C1/tree0/err_tree.log   (only exists when something goes wrong)

2.1. 2_1_make_subtree.pl [datatype] [test usr]
  This script is very similar to 2_0_make_tree.pl, except that the decision tree is
  constructed from tying the 1st, 2nd, and 3rd states of lig models separately.
  Example:
  > perl 2_1_make_subtree.pl NP2DuvNV2D C1
  Output:
   - products/NP2DuvNV2D/C1/tree1/fullDict       (covers 26x26 ligs + 26 chars for HVite)
   - products/NP2DuvNV2D/C1/tree1/uniqueDict     (all the unique ligs from decision tree + 26 chars)
   - products/NP2DuvNV2D/C1/tree1/trees          (the generated decision tree)
   - products/NP2DuvNV2D/C1/tree1/subtrees1/
   - products/NP2DuvNV2D/C1/tree1/subtrees2/
   - products/NP2DuvNV2D/C1/tree1/subtrees3/
   - products/NP2DuvNV2D/C1/tree1/trihmm3/
   - products/NP2DuvNV2D/C1/tree1/trihmm4/
   - products/NP2DuvNV2D/C1/tree1/trihmm5/       (final HERest HMMs)
   - products/NP2DuvNV2D/C1/tree1/log_tree.log
   - products/NP2DuvNV2D/C1/tree1/err_tree.log   (only exists when something goes wrong)

2.2. 2_2_batch.pl
  This script lauches Step 2.0 and Step 2.1 for all leave-one-out combinations for each
  specified datatype and test users.
  Example:
  > perl 2_2_batch.pl

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
