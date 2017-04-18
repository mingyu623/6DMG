# Mingyu @ Apr 14 2017
# Perform word-level word recognition of airwriting on spotted writing segments
# with leave-one-out cross validation.
# The training/testing are carried out with the ground-truth airwriting segments to
# study the recognition performance as if the *detection* is perfect.

1. 1_prepare_dict_wdnet_fil.pl [datatype] [tst usr]
  This script is identical to LeaveOneOut/1_0_prepare_dit_wdnet_fil.pl except
  the mlf is generated from the *groudn truth* airwriting segents.  This script
  prepares all the essential MLF (.mlf) and word network (wdnet) for the following
  steps.
  Example:
  > perl 1_prepare_dict_wdnet_fil.pl
  Output:
   - char_lig/dict    (for common 100-word voc)
   - char_lig/gram
   - char_lig/wdnet
   - char_lig/dict1k  (for common 100-word + 900-unique-word = 1k-word voc)
   - char_lig/gram1k
   - char_lig/wdnet1k 
   - char_lig/hmmList
   - mlf/word.mlf
   - mlf/char_lig.mlf

2. 2_init_fil.pl [datatype]
  This script is identical to LeaveOneOut/2_init_fil.pl except that
  the detected segments are from the ground-truth labels.
  This script initialized the "fil" HMM with HCompV.
  Example:
  > perl 2_init_fil.pl NP2DuvNV2D
  Output:
   - char_lig/NP2DuvNV2D/all_det.scp
   - char_lig/NP2DuvNV2D/fil  (the filler HMM)

3.0. 3_0_train_HMM_single.pl [datatype] [tst usr]
  This script is identical to LeaveOneOut/3_0_train_HMM_single.pl except
  1) the source MLF comes from the ground-truth airwriting segments.
  2) the evaluation is also done for the testing set (leave-one-out)
  This script performs emedded restimation of A-Z + multi-lig + fil HMMs
  using the detected motion words.
  The initial HMMs are copied from previous experiments:
  [NOTE] This step can be very time consuming!
  1) A-Z and "multi-lig": the HMMs from words_word_based with extension set.
    e.g., words_word_based/char_lig/[datatype]/Extension/iso/hmm3/hmmdefs_iso
  2) "fil": from Step 2.
  Example:
  > perl 3_0_train_HMM_single.pl NP2DuvNV2D C1
  Output:
   - char_lig/NP2DuvNV2D/C1/hmm0/
   - char_lig/NP2DuvNV2D/C1/hmm1/
   - char_lig/NP2DuvNV2D/C1/hmm2/
   - char_lig/NP2DuvNV2D/C1/hmm3/
   - char_lig/NP2DuvNV2D/C1/log.txt
   - char_lig/NP2DuvNV2D/C1/err.txt  (only exists when something goes wrong)
   - char_lig/NP2DuvNV2D/C1/recog_trn.mlf
   - char_lig/NP2DuvNV2D/C1/trn.scp
   - char_lig/NP2DuvNV2D/C1/trn_align.scp

3_1. 3_1_batch.pl
  This script performs the complete leave-one-out cross validation by using
  Step 3.0 for each specified datatype and test users.
  Example:
  > perl 3_1_batch.pl

4. 4_stats.pl
  Example
  > perl 4_stats.pl
  Output:
   - res_truth.txt  (the recognition results of the testing set of ground-truth
                     airwriting segments)
