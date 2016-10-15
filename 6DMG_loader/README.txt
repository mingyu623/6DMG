# 6DMG_loader_2.2
# Mingyu Chen (mingyu623@gmail.com) @ Oct. 14. 2016


1. If there's no Matlab installed on the machine, you can install only
   the MCR (Matlab Compiler) to compile and run 6DMG_loader.
   http://www.mathworks.com/products/compiler/mcr/

2. Install SQLite
   > sudo apt-get install libsqlite3-dev

# TODO(mingyu): Update the README...





---------------------------------------------------
change log:
The normalization scheme is modified for left-to-right writing

---------------------------------------------------

1. The compiled executable is in bin\

2. !!!IMPORTANT!!!
   The working directory has to be set to bin\ to run properly in VS2008
   right click on project -> Properties -> Debugging -> Working Directory -> bin

3. In Config.h,
   Use #define EXPORT_GEST_HTK to export motion gest to HTK
   or
   Use #define EXPORT_GEST_MAT to export motion gest to Matlab
   or
   Use #define EXPORT_CHAR_HTK to export motion char to HTK
   or
   Use #define EXPORT_CHAR_MAT to export motion char to Matlab
   or 
   Use #define EXPORT_WORD_HTK to export motion word to HTK
   or
   Use #define EXPORT_WORD_MAT to export motion word to Matlab

4. In Config.h
   Edit HTK_EXP to control the features to export (e.g., HTK_POS, HTK_VEL...)

5. HTK will be exported to htk\
   MAT will be exported to matR\ and matL\

=================================================
# 6DMG MATLAB exporter

1. Each .mat file is named as g[XX]_[YY]_t[ZZ].mat:
[XX]: gesture index
[YY]: tester ID
[ZZ]: trial index

2. Each .mat file contains 3 matrices:
 - gest: (14 x n, n samples), the order as defined in GestureDef.h
    | timestamp1  ...    timestampn |
    | pos1.x      ...    posn.x     |
    | pos1.y      ...    posn.y     |
    | pos1.z      ...    posn.z     |
    | ori1.w      ...    orin.w     |
    | ori1.x      ...    orin.x     |
    | ori1.y      ...    orin.y     |
    | ori1.z      ...    orin.z     |
    | acc1.x      ...    accn.x     |
    | acc1.y      ...    accn.y     |
    | acc1.z      ...    accn.z     |
    | w1.yaw      ...    wn.yaw     |
    | w1.pitch    ...    wn.pitch   |
    | w1.roll     ...    wn.roll    |
      
 - bias:  (3 x 1), the bias of the angular speeds (from the gyro)
    | yaw   |
    | pitch |
    | roll  |

 - noise: (3 x 1), the std of bias of the angular speeds (from the gyro)
    | yaw   |
    | pitch |
    | roll  |

3. The gesuter index <==> gesture name (as in GestureDef.h)
   // swipe
   00	SWIPE_RIGHT,
   01	SWIPE_LEFT,
   02	SWIPE_UP,
   03	SWIPE_DOWN,
   04	SWIPE_UPRIGHT,
   05	SWIPE_UPLEFT,
   06	SWIPE_DOWNRIGHT,
   07	SWIPE_DOWNLEFT,

   // back & forth
   08	POKE_RIGHT,
   09	POKE_LEFT,
   10	POKE_UP,
   11	POKE_DOWN,

   // others
   12   V_SHAPE,
   13	X_SHAPE,
   14	CIR_HOR_CLK,
   15	CIR_HOR_CCLK,
   16	CIR_VER_CLK,
   17	CIR_VER_CCLK,
   18	TWIST_CLK,
   19	TWITS_CCLK,

=================================================
# 6DMG HTK exporter
# Motion Gestures
1. Each .htk file is named as g[XX]_[YY]_t[ZZ].htk:
[XX]: gesture index
[YY]: tester ID
[ZZ]: trial index

2. Use "HList -h g[xx]_[YY]_t[ZZ].htk to view the content
3. Use #define HTK_EXP  to select the datatype(s) to export
4. Use #define HTK_NORM to select the datatype(s) to normalize

=================================================
# 6DMG HTK exporter for motion char and motion word
# Motion Char/Word
1. Each .htk file is named as [xx]_[yy]_t[zz].htk:
[xx]: motion word or char name
[yy]: tester ID
[zz]: trial index
