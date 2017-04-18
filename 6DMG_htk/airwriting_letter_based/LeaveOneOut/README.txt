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






1.0. 1_0_prep_trn_scp_mlf_hmmdefs.pl [data_dir] [datatype] [test usr]
  This script prepares the training/testing scripts for leave-one-out cross validation,
  generates the HMM definitions for tri-ligs and chars, and performs embedded re-estimation.
  See the script for more details.
  Extra requirement:
  ../words_word_based/char_lig/$dtype/Extension/iso/hmm3/hmmdefs_iso
  This file has to be generated first by running words_word_based experiment.
  Example:
  > perl 1_0_prep_trn_scp_mlf_hmmdefs.pl ~/Development/6DMG/data_htk/words NPNV C1
  Output:
   - products/NPNV/C1/fulllist
   - products/NPNV/C1/mono_char_tri_lig.mlf
   - products/NPNV/C1/test.scp
   - products/NPNV/C1/train.scp
   - products/NPNV/C1/trihmm0/
   - products/NPNV/C1/trihmm1/
   - products/NPNV/C1/trihmm2/  (the tri-state HMMs will be used in the following training/testing)
   - products/NPNV/C1/triligHmmlist
   - products/NPNV/C1/trilig_stats.txt

1.1. 1_1_batch.pl [data_dir]
  This script automates the Step 1.0 for all leave-one-out combinations for each specified
  datatype and test users.
  Example:
  > perl 1_1_batch.pl ~/Development/6DMG/data_htk/words

2.0. 2_0_make_tree.pl [datatype] [test usr]
  This script generates the hed file for HHed for the decision tree to tie the ligature models
  and leave the char model untouched. Will output "qniqueDict": all the unique ligatures + 26 char HMM
  Example:
  > perl 2_0_make_tree.pl NPNV C1
  Output:
   - products/NPNV/C1/tree0/fullDict       (covers 26x26 ligs + 26 chars for HVite)
   - products/NPNV/C1/tree0/uniqueDict     (all the unique ligs from decision tree + 26 chars)
   - products/NPNV/C1/tree0/trees          (the generated decision tree)
   - products/NPNV/C1/tree0/trihmm3/
   - products/NPNV/C1/tree0/trihmm4/
   - products/NPNV/C1/tree0/trihmm5/       (final HERest HMMs)
   - products/NPNV/C1/tree0/log_tree.log
   - products/NPNV/C1/tree0/err_tree.log   (only exists when something goes wrong)

2.1. 2_1_make_subtree.pl [datatype] [test usr]
  This script is very similar to 2_0_make_tree.pl, except that the decision tree is
  constructed from tying the 1st, 2nd, and 3rd states of lig models separately.
  Example:
  > perl 2_1_make_subtree.pl NPNV C1
  Output:
   - products/NPNV/C1/tree1/fullDict       (covers 26x26 ligs + 26 chars for HVite)
   - products/NPNV/C1/tree1/uniqueDict     (all the unique ligs from decision tree + 26 chars)
   - products/NPNV/C1/tree1/trees          (the generated decision tree)
   - products/NPNV/C1/tree1/subtrees1/
   - products/NPNV/C1/tree1/subtrees2/
   - products/NPNV/C1/tree1/subtrees3/
   - products/NPNV/C1/tree1/trihmm3/
   - products/NPNV/C1/tree1/trihmm4/
   - products/NPNV/C1/tree1/trihmm5/       (final HERest HMMs)
   - products/NPNV/C1/tree1/log_tree.log
   - products/NPNV/C1/tree1/err_tree.log   (only exists when something goes wrong)

2.2. 2_2_batch.pl
  This script lauches Step 2.0 and Step 2.1 for all leave-one-out combinations for each
  specified datatype and test users.
  Example:
  > perl 2_2_batch.pl

3.0. 3_0_viterbi_bigram_nbest.pl [datatype] [tree#] [tst usr] [voc]
  This script performs viterbi decoding with specified datatype, decision tree, test user,
  and vocabulary for bigram.  See the script for details of input arguments.
  The viberbi decoding will do nbest decoding where nbest is hardcoded to 5. To speed up,
  feel free to lower he nbest number (smallest is 1).
  Example:
  > perl 3_0_viterbi_bigram_nbest.pl NPNV 0 C1 na
  Output:
   - products/NPNV/C1/tree0/log_dec_bigram_na_nbest.log
   - products/NPNV/C1/tree0/err_dec_bigram_na_nbest.log (exists when something goes wrong)
   - products/NPNV/C1/tree0/dec_bigram_na_nbest.mlf

3.1. 3_1_batch.pl
  This script lauches Step 3.0 for all leave-one-out combinations for each
  specified datatype and test users, both decision tree 0 and tree 1, and
  three different language models: no bigram, 40-word voc w/ backoff, 40-word voc w/o backoff
  Example:
  > perl 3_1_batch.pl

4. 4_stats_bigram_nbest.pl
  This script collects the results from Step 3.1. and generates the stats of
  character error rate (CER) and word error rate (WER) for each leave-one-out test user
  and the overall average / standard deviations.
  Example:
  > perl 4_stats_bigram_nbest.pl
  Output:
   - results/results_bigram_[voc]_[n]best.txt

5.0. 5_0_ext_bigram_nbest.pl [data_dir] [datatype] [tree#] [voc]
  This script is similar to Step 3.0 except that the viterbi decoding is done with
  the extension voc-1k of M1's data.  See the script for details of input arguments.
  Example:
  > perl 5_0_ext_bigram_nbest.pl ~/Development/6DMG/data_htk/words NPNV 0 1k
  Output:
   - products/NPNV/M1/tree0/log_dec_ext_bigram_1k_nbest.log
   - products/NPNV/M1/tree0/err_dec_ext_bigram_1k_nbest.log (exists when something goes wrong)
   - products/NPNV/M1/tree0/dec_bigram_1k_nbest.mlf

5.1. 5_1_batch.pl [data_dir]
  This script launches Step 5.0 for test user M1, each speicified datatype, both decision tree 0
  and decision tree 1, and three different language models: 1k-word voc w/ backoff,
  1k-word voc w/o backoff, 100k-word voc.
  Example:
  > perl 5_1_batch.pl ~/Development/6DMG/data_htk/words

5.2. 5_2_stats_ext_bigram_nbest.pl
  This script is similar to Step 4.  It collects the results from Step 5.1 and generates the stats
  of character error rate (CER) and word error rate (WER) for test user M1 of 1k-word dataset
  Example:
  > perl 5_2_stats_ext_bigram_nbest.pl
  Output:
   - results/results_bigram_[voc]_[n]best.txt
