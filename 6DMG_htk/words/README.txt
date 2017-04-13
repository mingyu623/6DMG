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

3.2.








2. 2_stats.pl
  This script collects the results from Step 1.2 and generates the stats of
  character error rate (CER) for each datatype, each leave-one-out case, and
  overall results.
  Example:
  > perl 2_stats.pl
  Ouput:
   - res.txt
