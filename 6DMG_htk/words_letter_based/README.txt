# Mingyu @ Apr 13 2017
#
# Here, we perform the training/testing of letter-based motion words recognition
#

# TODO(mingyu):
# Provide the script to generate the n-gram language model .arpa files

0.0. 0_0_generate_share.pl [data_dir]
  This script generates the datatype invariant shared files for all following experiments.
  Extra requirement:
  Need the 2-gram language model (share/voc_chars_100k.arpa) produced by the CMU-Cambridge
  Statistical Language Modeling Toolkit.
  [NOTE] We hardcoded in the script to use datatype NPNV to generates word_ref.mlf
         However, any datatype will work.
  Example:
  > perl 0_0_generate_share.pl ~/Development/6DMG/data_htk/words
  Output:
   - share/wdnet
   - share/wdnet_bigram
   - share/word_ref.mlf

0.1. 0_1_generate_wdnet_bigram.pl [voc] [backoff]
  This script generates the wdnet with bigram estimated from the given vocabulary with or
  without backoff.
  [NOTE] If choose 100k voc without backoff, the generated wdnet_bigram_100k will be identical
         to the wdnet_bigram generated in Step 0.0
  Extra requirement:
  Need the 2-gram language model estimated from the specified vocabulary (40, 1k, or 100k,
  share/voc_chars_40.arpa, share/voc_chars_1k, share/voc_chars_100k) produced by the
  CMU-Cambridge Statistical Language Modeling Toolkit.
  Example:
  > perl 0_1_generate_wdnet_bigram.pl 100k 0
  Output:
   - share/wdnet_bigram_100k

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

3.0  3_0_viterbi_bigram_nbest.pl [datatype] [tree#] [tst usr] [voc]
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








0. 0_gen_single_proto.pl [datatype] [# states]
  This script generates one proto file for HTK with specified data type and states number.
  [Note] the user needs the proto templates for state numbers of 3, 10, 12, 14, 16, 18 to
  run the following step.
  Example:
  > perl 0_gen_single_proto.pl NPNV 10
  Output:
   - proto/NPNV/template_10

1.1. 1_build_iso_char_hmm.pl [data_dir] [datatype]
  This script trains the isolated character HMMs with all right-handed users for
  preparation of word HMMs.
  Example:
  > perl 1_build_iso_char_hmm.pl ~/Development/6DMG/data_htk/chars NPNV
  Output:
   - iso_char/NPNV/all/gestDic
   - iso_char/NPNV/all/gestGram
   - iso_char/NPNV/all/gestList
   - iso_char/NPNV/all/gestNet
   - iso_char/NPNV/all/hmm0/
   - iso_char/NPNV/all/hmm1/
   - iso_char/NPNV/all/hmm2/ (final iso char HMMs)
   - iso_char/NPNV/all/train.scp
   - iso_char/NPNV/all/test.scp
   - iso_char/NPNV/all/trn.mlf
   - iso_char/NPNV/all/tst.mlf
   - iso_char/NPNV/all/log.txt
   - iso_char/NPNV/all/err.txt  (only exists when something goes wrong)

1.2. 1_build_iso_lig_hmm.pl [data_dir] [datatype]
  This script trains the isolated ligature HMMs with all trials of M1 with
  manually segmented ligature labels.  There are 21 types of ligatures, but
  some of them *DO NOT* have labels in the samples.  For details, please see
  “Air-writing Recognition, Part1: Modeling and Recognition of Characters,
  Words and Connecting Motions.”
  Example:
  > perl 1_build_iso_lig_hmm.pl ~/Development/6DMG/data_htk/words NPNV
  Output:
   - iso_lig/NPNV/gestDic
   - iso_lig/NPNV/gestGram
   - iso_lig/NPNV/gestList
   - iso_lig/NPNV/gestNet
   - iso_lig/NPNV/hmm0/
   - iso_lig/NPNV/hmm1/
   - iso_lig/NPNV/hmm2/  (final iso lig HMMs)
   - iso_lig/NPNV/train.scp
   - iso_lig/NPNV/test.scp
   - iso_lig/NPNV/log.txt
   - iso_lig/NPNV/err.txt  (only exists when something goes wrong)

2. 2_dict_wdnet_prepare.pl
  Using the iso char and lig HMMs generated from Step 1, this script will generate
  the required wdnet and dict for motion word recognition tasks and convert the word
  level mlf (word.mlf) to char level mlf (char_lig.mlf)
  Example:
  > perl 2_dict_wdnet_prepare.pl
  Output:
   - mlf/char_lig.mlf
   - char_lig/dict
   - char_lig/dict_exp  (exp means expansion, the 1k word set)
   - char_lig/dict_trn
   - char_lig/gram
   - char_lig/gram_exp
   - char_lig/gram_trn
   - char_lig/hmmList
   - char_lig/wdnet
   - char_lig/wdnet_rn
   - char_lig/wdnet_exp

3.0. 3_0_train_lig_single.pl [data_dir] [datatype] [test usr] [lig model]
  This script requires the results from Step 1 & 2, and performs embedded
  re-estimation of A-Z + multi-lig HMMs.  This script is performed in a
  leave-one-out manner with specified testing user (test with 40-word vocab)
  Example:
  > perl 3_0_train_lig_single.pl ~/Developement/6DMG/data_htk/words NPNV C1 iso
  Output:
   - char_lig/NPNV/LeaveOneOut/C1/
   - char_lig/NPNV/LeaveOneOut/log_C1.txt
   - char_lig/NPNV/LeaveOneOut/err_C1.txt  (only exists when something goes wrong)

3.1. 3_1_batch.pl [data_dir]
  This script launches all single runs of leave-one-out training/testing. The user
  can modify the datatype(s) and ligature model(s) in use in the script.
  Example:
  > perl 3_1_batch.pl ~/Development/6DMG/data_htk/words

3.2. 3_2_stats.pl
  This script collects the results from Step 3.1 and generates the stats of
  word error rate (WER) for each datatype, each leave-one-out case, and the
  overall results.
  Example:
  > perl 3_2_stats.pl
  Output:
   - res_leaveOneOut_iso.txt

4.0. 4_0_train_lig_single.pl [data_dir] [datatype] [lig model]
  This script requries the results from Step 1 & 2, and performs embedded
  re-estimation of A-Z + multi-lig HMMs.  The training set consists of the
  40-word dictionary by 22 users.  The testing data is the extension 1k-word
  set by M1.
  Example:
  > perl 4_0_train_lig_single.pl ~/Development/6DMG/data_htk/words NPNV iso
  Output:
   - char_lig/NPNV/Extension/iso/
   - char_lig/NPNV/Extension/log_iso.txt
   - char_lig/NPNV/Extension/err_iso.txt  (only exists when something goes wrong)

4.1. 4_1_batch.pl [data_dir]
  This script launches all single runs of Step 4.0. with different datatype(s) and
  ligature model(s) specified in it.
  Example:
  > perl 4_1_batch.pl ~/Development/6DMG/data_htk/words

4.2. 4_2_stats.pl
  This script collects the results from Step 4.1 and generates the stats of
  word error rate (WER) for each datatype, each ligature model, and the
  overall results.
  Example:
  > perl 4_2_stats.pl
  Ouput:
   - res_extension.txt
