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

