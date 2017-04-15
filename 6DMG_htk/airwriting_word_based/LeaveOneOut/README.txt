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
  This script prepares all the essential MLF (.mlf), training script (scp), and
  word network (wdnet) for the following steps.
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

