# Mingyu @ Apr 22 2013
# Perform word-level word recognition of airwriting.
# [NOTE] The default datatype for airwriting is NP2DuvNV2D.
# Please refer to 6DMG_loader/include/Config.h for the *meaning* of NP2DuvNV2d
#  - NP2Duv is HTK_P2D_UV: normalize p2d (x & y position) with unit variance in y
#  - NV2D is HTK_V2D: only the 2D (x & y) velocity

1. LeaveOneOut/
 - Train and test with the *spotted* airwriting segments.
 - The training MLF is forced to pad with "fil" at the begin and end of each word
 - The decoding network also has forced "fil"

2. GroundTruth/
 - Use the ground truth of word segmentations for training and testing
 - The decoding network also has forced "fil"
