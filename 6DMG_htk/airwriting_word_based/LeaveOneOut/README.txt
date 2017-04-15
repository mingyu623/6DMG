# Mingyu @ Apr 14 2017
# Perform word-level word recognition of airwriting on spotted writing segments
# with leave-one-out cross validation.

0. 0_gen_single_proto.pl
  This script generates the template of HMM for the specified datatype and state #.
  We simply generate the extra *fil* HMM for the filler.  For the remaining HMM templates,
  we can re-use those generated from words_word_based/
  Example:
  > perl 0_gen_single_proto.pl NP2DuvNV2D 1
  Output:
   - proto/NP2DuvNV2D/template_1

1.0. 1_0_prepare_dict_wdnet_fil.pl 
  This script prepares all the essential MLF (.mlf) and word network (wdnet)
  for the following steps.
  Example:
  > perl 1_0_prepare_dict_wdnet_fil.pl
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

1.1. 1_1_prep_merge_tst_scp_single.pl [datatype] [tst usr]
  This script generates the merge_test.scp and merge_testOOV.scp from
  data_htk/airwriting_spot_merge for each user. Also generates the corresponding
  merge_ref.mlf for HResult.
  [NOTE] OOV: Out of Vocabulary
  Example:
  > perl 1_1_prep_merge_tst_scp_single.pl NP2DuvNV2D C1
  Output:
   - char_lig/NP2DuvNV2D/M1/merge_tst.scp
   - char_lig/NP2DuvNV2D/M1/merge_tstOOV.scp
   - char_lig/NP2DuvNV2D/M1/merge_imprecise.scp
   - char_lig/NP2DuvNV2D/M1/merge_impreciseOOV.scp
   - char_lig/NP2DuvNV2D/M1/merge_FA.scp
   - char_lig/NP2DuvNV2D/M1/merge_ref.mlf (for HLEd)
   - char_lig/NP2DuvNV2D/M1/merge_char_lig_ref.mlf (for HResults)

1.2. 1_2_batch.pl
