/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com) 
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/
#ifndef _GESTURE_DEF_H_
#define _GESTURE_DEF_H_

#include <string>
#include <vector>

namespace GestureDef {
// The structs defined here should contain ONLY standard datatype to
// make it independent to Ogre (Thus, no constructor involving Ogre variables)
struct XYZ {
  float x;
  float y;
  float z;
};

struct ORI {
  float w;
  float x;
  float y;
  float z;
};

struct YPR {
  float yaw;
  float pitch;
  float roll;
};

struct Euler {
  float psi;
  float theta;
  float phi;
};

struct Sample {
  // follow the same order in memory array!
  // sizeof(Sample)= 14*sizeof(float)=56
  float timestamp;  // in ms
  XYZ pos;  // position from PPT (real world position in meter)
  ORI ori;  // orientation from wiimote in quaternion
  XYZ acc;  // acceleration in local x, y, z (g)
  YPR w;    // angular speed in yaw, pitch, roll (rad/s), RHS y-up
};

struct Gesture {
  std::string name;    // name of this gesture
  std::string tester;  // the tester who performs this gesture
  size_t trial;        // the ith trial performed by this tester
  size_t length;       // the number of samples in this recorded gesture
  size_t rightHand;    // 0: leftHand,  1: rightHand
  std::vector<Sample> data;  // the streams of samples
  // extra information for the gyro calibration
  // We DO NOT do HARD calibration while recording one gesture
  YPR noise;
  YPR bias;
};

// Struct for tester name/rightHand
struct TesterInfo {
  std::string name;
  int rightHand;
};

// Utility functions for quaternion
ORI quatMul(const ORI& q1, const ORI& q2);
ORI quatConj(const ORI& q);
ORI quatNorm(const ORI& q);

// Utility function to get the gesture/char/word name
// [Mingyu]: a stupid implementation
std::string getGestureName(int gestureIdx);
std::string getCharName(int charIdx);
std::string getWordName(int wordIdx);

// [Mingyu]:
// The enum and utility function to get the corresponding "gesture name"
enum GestureName {
  // swipe eight directions
  SWIPE_RIGHT,
  SWIPE_LEFT,
  SWIPE_UP,
  SWIPE_DOWN,
  SWIPE_UPRIGHT,
  SWIPE_UPLEFT,
  SWIPE_DOWNRIGHT,
  SWIPE_DOWNLEFT,

  // back & forth
  POKE_RIGHT,
  POKE_LEFT,
  POKE_UP,
  POKE_DOWN,

  // others
  V_SHAPE,
  X_SHAPE,
  CIR_HOR_CLK,
  CIR_HOR_CCLK,
  CIR_VER_CLK,
  CIR_VER_CCLK,
  TWIST_CLK,
  TWITS_CCLK,

  TOTAL_GESTURES
};

// The enum and utility function to get the corresponding "character name"
enum CharName{
  NUM_0,
  NUM_1,
  NUM_2,
  NUM_3,
  NUM_4,
  NUM_5,
  NUM_6,
  NUM_7,
  NUM_8,
  NUM_9,
  UPPER_A,
  UPPER_B,
  UPPER_C,
  UPPER_D,
  UPPER_E,
  UPPER_F,
  UPPER_G,
  UPPER_H,
  UPPER_I,
  UPPER_J,
  UPPER_K,
  UPPER_L,
  UPPER_M,
  UPPER_N,
  UPPER_O,
  UPPER_P,
  UPPER_Q,
  UPPER_R,
  UPPER_S,
  UPPER_T,
  UPPER_U,
  UPPER_V,
  UPPER_W,
  UPPER_X,
  UPPER_Y,
  UPPER_Z,
  LOWER_A,
  LOWER_B,
  LOWER_C,
  LOWER_D,
  LOWER_E,
  LOWER_F,
  LOWER_G,
  LOWER_H,
  LOWER_I,
  LOWER_J,
  LOWER_K,
  LOWER_L,
  LOWER_M,
  LOWER_N,
  LOWER_O,
  LOWER_P,
  LOWER_Q,
  LOWER_R,
  LOWER_S,
  LOWER_T,
  LOWER_U,
  LOWER_V,
  LOWER_W,
  LOWER_X,
  LOWER_Y,
  LOWER_Z,
  TOTAL_CHARS
};

// The enum and utility function to get the corresponding "word name"
enum WordName{
  // set 1
  ABC,
  CBS,
  CNN,
  DISCOVERY,
  DISNEY,
  ESPN,
  FOX,
  HBO,
  NBC,
  TBS,

  // set 2
  BBC,
  FX,
  HULU,
  TNT,
  MUSIC,
  JAZZ,
  ROCK,
  DRAMA,
  MOVIE,
  SPORT,

  // set 3
  WEATHER,
  NEWS,
  MLB,
  NFL,
  TRAVEL,
  POKER,
  FOOD,
  KID,
  MAP,
  TV,

  // set 4
  GAME,
  VOICE,
  CALL,
  MAIL,
  MSG,
  FB,
  YOU,
  GOOGLE,
  SKYPE,
  QUIZ,

  // expansion 1k words
  // [Mingyu]: IN, OUT, FAR, ORI are added with an underscroe (to avoid redefinition)
  THE, OF,  AND, TO,  IN_, FOR, IS,  THA, PRO, THI,
  ON,  WIT, BY,  COM, NOT, IT,  ARE, OR,  CON, NEW,
  BE,  FRO, AT,  AS,  ALL, STA, RES, USE, PRI, MOR,
  HAV, WAS, CAN, AN,  INT, SHO, WIL, SER, WOR, HOM,
  WE,  ABO, INF, COU, PAG, CAR, ONL, US,  SEA, WHI,
  PAR, POS, IF,  TIM, FRE, REA, OTH, WHE, SIT, PLA,
  PER, MAN, BUT, DAT, MY,  OFF, HAS, ONE, HER, EVE,
  STO, OUR, ADD, PRE, FIN, LIN, NO,  LIS, DO,  ACC,
  TRA, INC, OUT_, SEE, CHA, WEB, HIS, UNI, MAY, IND,
  HE,  UP,  ANY, WHA, MAR, SEC, HEA, REP, YEA, THR,
  SOM, WHO, PHO, HEL, BUS, MUS, DAY, APP, ART, RAT,
  HOW, TOP, HOT, STU, REC, SEL, GET, MEM, VIE, ACT,
  DIS, FIR, BOO, JAN, LEA, CLI, SO,  REL, SUP, POL,
  DES, REV, PUB, MAI, REG, MON, RIG, ALS, ITE, SOU,
  SYS, RE,  PM,  GRO, NOW, LOC, VER, MAK, SPE, OVE,
  DEV, CHI, ITS, LIK, BEE, ME,  HOU, WER, INS, AM,
  CAL, FIL, WOU, GAM, CEN, BAS, DOW, NAM, DIR, COL,
  THO, TEC, BAC, SCH, SUB, NEE, JUS, CRE, MOV, GOO,
  BUY, MES, HIG, KNO, REQ, PEO, HAD, FRI, WEL, NAT,
  PIC, SEN, GRE, NET, TAK, COP, ADV, MED, AVA, BEC,
  ASS, TOO, LAS, VID, FEE, CAS, DEC, SUC, TWO, CIT,
  ENT, EMA, NUM, AUT, GO,  STR, NEX, MOS, OPE, DET,
  LON, FOU, UND, SEX, WIN, GEN, FUN, SET, MOD, LOO,
  CAT, ORD, ENG, SOF, BET, SIN, CLA, AFT, PLE, FAC,
  TER, AME, SHE, BES, MIN, MAT, CHE, POW, WAY, SHA,
  JOB, EXP, SIG, SAI, AGE, FUL, SAM, SPO, PAY, EAC,
  RET, WAT, SAL, WAN, OWN, EST, EAS, NOR, TEX, VAL,
  IMP, FOL, SHI, TYP, EDU, LOG, DE,  MIL, GIV, DOE,
  CUS, CUR, QUE, IMA, LIV, ISS, LIF, CAM, GUI, DVD,
  WRI, WOM, SEP, EDI, LAT, OCT, FAM, HAR, ELE, NOV,
  TEA, EBA, PAS, WEE, BEF, DID, ROO, DIF, BLO, SAY,
  TEL, EFF, NON, MEN, POR, USI, MAD, AGA, BOT, END,
  LOW, LEV, UK,  MEA, DEA, FEA, LAR, SOC, JUN, HIM,
  REM, LAW, COS, FOO, COD, JUL, TIT, BOA, VIS, POI,
  EUR, LAN, QUA, BRO, APR, KIN, UPD, SIM, TEE, AUG,
  TOD, BLA, JOI, OLD, LIT, SPA, BUI, BEI, MUC, FEB,
  WES, SMA, SCI, GRA, STE, BEL, GIF, TES, JOH, MIC,
  MET, GIR, AWA, RED, ANO, SOL, MEE, DEP, DEL, GOL,
  BEA, POP, PAP, COR, BIG, OPT, SON, SIZ, LET, TOT,
  DUR, HAN, SUR, GOV, AUS, LES, AIR, USA, ARC, DIG,
  FRA, LOA, ANN, LOV, RUN, HOS, GAL, WHY, WED, EAR,
  SUN, DOC, CLO, CD,  REF, LOS, THU, PUR, KEY, SAV,
  ENV, AMO, FLO, CHR, PAC, AGR, QUI, RAN, VAR, ANA,
  SAN, TRU, LEF, EQU, YOR, TAX, EXA, STI, IDE, TRY,
  BRI, GAY, PAT, ASK, AVE, ARO, LEG, FIE, EXC, BOX,
  LIB, LA,  DAV, HUM, QUO, WAR, VE,  DRI, TAB, BAN,
  COV, MIS, FUR, EMP, DEF, TOW, CEL, YAH, REN, TRE,
  NEV, YES, LL,  MAJ, SAF, CLE, MAG, GOI, SAT, LIG,
  FAS, ECO, ISL, MOB, SID, CHO, SUM, GER, EXT, MAC,
  HOL, VIR, RUL, SCO, BRA, ALT, BOD, ST,  PC,  TRI,
  LIM, GOT, FEW, TUE, CAP, FAR_, POK, MUL, CLU, FAQ,
  SEV, ROA, NIG, AL,  TAL, AFF, BIL, INV, YET, LOT,
  SKI, TOU, MIG, ANI, OPP, FUT, SOR, TUR, KEE, BLU,
  AFR, ASI, CER, JAP, HAL, MAS, AUD, BEN, DIE, BEG,
  CO,  ALW, ENE, BAB, WAL, FAX, CA,  ORG, ALO, ONC,
  PRA, HAP, ORI_, DOM, RSS, RAD, BOY, ID,  II,  GEO,
  ABL, FIG, DRU, VOL, WIS, UNT, PUT, FAI, DAI, GOD,
  SCR, WRO, WEA, ERR, STY, URL, DON, GAR, NEA, ADU,
  AGO, FED, TIC, USU, VOI, CUL, EIT, MOT, BAD, TIP,
  FLA, RIS, UPO, ROC, MID, GLO, LYR, ATT, JOU, ALR,
  ITA, DUE, ANS, PLU, WEI, OFT, VIA, POO, SPR, AMA,
  WID, PET, ET,  CAU, CRI, TOG, NUD, LIC, WIR, CHU,
  JAM, FIV, DAN, ACA, PAI, ENO, OIL, KIT, EXI, ELS,
  PAU, EXE, MAX, ALB, ADM, DOI, DOG, PAN, DOU, BIT,
  FIT, BAR, IRA, RIC, OBJ, NY,  USR, CRO, ACR, RUS,
  NEC, FUC, BEH, LAK, GAS, BRE, TOY, OH,  EYE, DIV,
  HIT, ROB, BAY, WEN, CAB, DC,  FAT, CNE, EN,  MAL,
  GOA, FAL, FEM, AD,  HTM, MOU, GUY, BED, JAC, SOO,
  NAV, OBT, ROL, GUE, OPI, GLA, FAV, EG,  ROU, ANT,
  ALM, ONT, YEL, HAI, POT, HUG, LOU, TEN, HP,  INN,
  BUD, GMT, HOR, WAI, PDF, SMI, HEN, MEX, TX,  JEW,
  RIV, TOL, IP,  HOP, ENS, ESP, FIX, ORA, ALA, RAC,
  VAC, PA,  SIX, RD,  MD,  LTD, IRE, ZIP, EVI, VAN,
  HIL, FAN, RIN, BIN, NIC, MS,  BAL, PUS, AUC, NOK,
  ELI, DEG, WON, DAR, BAT, WOO, XML, SIL, CIV, ISB,
  IE,  ABI, PST, ETC, BOS, BID, III, OK,  USB, FL,
  LEN, MA,  FOC, MSN, MB,  PHE, LE,  OHI, AZ,  CUT,
  UNL, TOM, MIK, PHY, SAW, JER, HI,  ANG, INP, BIB,
  GOE, ILL, PHP, JAV, DOO, IL,  ZEA, LLC, WIF, LOR,
  NC,  LEE, VOT, IBM, MR,  ROY, OS,  ENJ, ISR, ARG,
  KAN, MM,  ND,  NAK, BOR, MYS, JIM, PP,  GAV, DEE,
  BOB, ARI, VEH, VA,  TAR, XXX, VEG, SC,  IMM, PEN,
  CUM, PIE, ENA, SCA, JON, BON, COA, COO, PO,  TH,
  ORE, KON, GA,  LED, ABS, SES, BEY, DEM, EL,  PAL,
  MOM, JOE, JES, RAP, INI, FIC, SUI, KM,  WWW, FEL,
  LCD, WA,  NJ,  EU,  DAK, XP,  JUM, ARM, XBO, KNE,
  HON, VHS, IOW, DAM, COC, BOU, AU,  FIS, CDS, IPO,
  HAW, TEM, ATL, USD, DEB, LAC, KOR, AVO, EVA, SLI,
  MI,  DOL, GON, KB,  DJ,  DAL, PHI, DR,  JOS, DI,
  BYT, GEA, BC,  DIA, TOR, AC,  DIC, OKL, ESS, KEP,
  TAS, EDG, DRO, PEA, ZON, MIA, NT,  AID, SUG, EIG,
  GAI, GB,  SD,  CUP, ACH, CT,  NEG, ZUM, PHA, HIV,
  VS,  APA, IV,  DNA, AR,  ASP, UTA, POC, SEQ, ADO,
  KEN, CIS, DED, CM,  SRC, UPG, MO,  UNK, ED,  OCC,
  SA,  SWI, PDA, DU,  MER, NA,  VIC, ERI, ICO, DSL,
  VIL, TAY, NE,  GUA, FUE, IRI, EM,  TN,  ROS, DAU,
  AOL, SWE, UTC, CIR, ORL, JEF, SYD, FES, UPP, KEV,
  UN,  SQL, ABU, ADS, RAI, VOY, MN,  GPS, EAT, LAB,
  PDT, EME, EDW, PR,  AVG, TON, HAM, BUR, NUR, AHE,
  PIN, OZ,  OBS, ATO, VIO, EPI, SQU, COF, NUC, ARK,
  TOTAL_WORDS
};

}  // namespace GestureDef
#endif  // _GESTURE_DEF_H_
