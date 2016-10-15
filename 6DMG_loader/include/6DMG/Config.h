#ifndef _6DMG_CONFIG_H_
#define _6DMG_CONFIG_H_

// TODO(mingyu): Add gflags
// TODO(mingyu): Replace compile time config with runtime command line flags

/* --------------------------------------------------
 * -----   Defines for export example options   -----
 * --------------------------------------------------
 */
// #define EXPORT_GEST_HTK   // export 6DMG (motion gest) to HTK
#define EXPORT_GEST_MAT   // export 6DMG (motion gest) to Matlab
// #define GEST_NORM_STAT    // print the stats on the normalization scales of 6DMG (motion gest)
// #define EXPORT_CHAR_HTK   // export 6DMG (motion char) to HTK
// #define EXPORT_CHAR_MAT   // export 6DMG (motion char) to Matlab
// #define EXPORT_WORD_HTK   // export 6DMG (motion word) to HTK
// #define EXPORT_WORD_MAT   // export 6DMG (motion word) to Matlab

/* --------------------------------------------------
 * -----     Defines for HTK export format      -----
 * --------------------------------------------------
 */
#define HTK_EXP         (HTK_P2D | HTK_V2D)  // flag to control what to export
#define HTK_ACC         0x0001
#define HTK_POS         0x0002  // relative pos
#define HTK_VEL         0x0004  // displacement between every sample
#define HTK_W           0x0008
#define HTK_ORI         0x0010  // relative orientation
#define HTK_P2D         0x0040  // only 2D (x & y) position
#define HTK_V2D         0x0080  // only 2D (x & y) velocity
#define HTK_POS_LR      0x0100  // the modified normalization for left-to-right writing
#define HTK_ORI_LR      0x0200  // the modified normalization for left-to-right writing
#define HTK_EA_PITCH    0x0400  // normalize euler angles (pitch only)
#define HTK_POS_UV      0x0800  // normalize pos with unit variance in y
#define HTK_P2D_UV      0x1000  // normalize p2d with unit variance in y

#endif  // _6DMG_CONFIG_H_
