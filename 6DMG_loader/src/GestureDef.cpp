/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com)
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/

#include <6DMG/GestureDef.h>
#include <math.h>
#include <string>
using namespace std;

namespace GestureDef {
// utility functions for quaternion
ORI quatMul(ORI q1, ORI q2) {
  ORI res;
  res.x =  q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x;
  res.y = -q1.x * q2.z + q1.y * q2.w + q1.z * q2.x + q1.w * q2.y;
  res.z =  q1.x * q2.y - q1.y * q2.x + q1.z * q2.w + q1.w * q2.z;
  res.w = -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z + q1.w * q2.w;
  return res;
}

ORI quatConj(ORI q) {
  ORI res;
  res.w =  q.w;
  res.x = -q.x;
  res.y = -q.y;
  res.z = -q.z;
  return res;
}

ORI quatNorm(ORI q) {
  float norm = sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);
  q.w /= norm;
  q.x /= norm;
  q.y /= norm;
  q.z /= norm;
  return q;
}

// Global function to get the gesture name
string getGestureName(int gestureIdx) {
  string str = "NOT_DEF";
  switch (gestureIdx) {
    // swipe eight directions
    case SWIPE_RIGHT:           str = "swipe_right"; break;
    case SWIPE_LEFT:            str = "swipe_left"; break;
    case SWIPE_UP:              str = "swipe_up"; break;
    case SWIPE_DOWN:            str = "swipe_down"; break;
    case SWIPE_UPRIGHT:         str = "swipe_upright"; break;
    case SWIPE_UPLEFT:          str = "swipe_upleft"; break;
    case SWIPE_DOWNRIGHT:       str = "swipe_downright"; break;
    case SWIPE_DOWNLEFT:        str = "swipe_downleft"; break;

      // back & forth
    case POKE_RIGHT:            str = "poke_right"; break;
    case POKE_LEFT:             str = "poke_left"; break;
    case POKE_UP:               str = "poke_up"; break;
    case POKE_DOWN:             str = "poke_down"; break;

      // others
    case V_SHAPE:               str = "v_shape"; break;
    case X_SHAPE:               str = "x_shape"; break;
    case CIR_HOR_CLK:           str = "cir_hor_clk"; break;
    case CIR_HOR_CCLK:          str = "cir_hor_cclk"; break;
    case CIR_VER_CLK:           str = "cir_ver_clk"; break;
    case CIR_VER_CCLK:          str = "cir_ver_cclk"; break;
    case TWIST_CLK:             str = "twist_clk"; break;
    case TWITS_CCLK:            str = "twist_cclk"; break;
  }
  return str;
}

// Global function to get the char name
string getCharName(int charIdx) {
  string str = "NOT_DEF";
  switch (charIdx) {
    case NUM_0:                 str = "num_0"; break;
    case NUM_1:                 str = "num_1"; break;
    case NUM_2:                 str = "num_2"; break;
    case NUM_3:                 str = "num_3"; break;
    case NUM_4:                 str = "num_4"; break;
    case NUM_5:                 str = "num_5"; break;
    case NUM_6:                 str = "num_6"; break;
    case NUM_7:                 str = "num_7"; break;
    case NUM_8:                 str = "num_8"; break;
    case NUM_9:                 str = "num_9"; break;

    case UPPER_A:               str = "upper_A"; break;
    case UPPER_B:               str = "upper_B"; break;
    case UPPER_C:               str = "upper_C"; break;
    case UPPER_D:               str = "upper_D"; break;
    case UPPER_E:               str = "upper_E"; break;
    case UPPER_F:               str = "upper_F"; break;
    case UPPER_G:               str = "upper_G"; break;
    case UPPER_H:               str = "upper_H"; break;
    case UPPER_I:               str = "upper_I"; break;
    case UPPER_J:               str = "upper_J"; break;
    case UPPER_K:               str = "upper_K"; break;
    case UPPER_L:               str = "upper_L"; break;
    case UPPER_M:               str = "upper_M"; break;
    case UPPER_N:               str = "upper_N"; break;
    case UPPER_O:               str = "upper_O"; break;
    case UPPER_P:               str = "upper_P"; break;
    case UPPER_Q:               str = "upper_Q"; break;
    case UPPER_R:               str = "upper_R"; break;
    case UPPER_S:               str = "upper_S"; break;
    case UPPER_T:               str = "upper_T"; break;
    case UPPER_U:               str = "upper_U"; break;
    case UPPER_V:               str = "upper_V"; break;
    case UPPER_W:               str = "upper_W"; break;
    case UPPER_X:               str = "upper_X"; break;
    case UPPER_Y:               str = "upper_Y"; break;
    case UPPER_Z:               str = "upper_Z"; break;

    case LOWER_A:               str = "lower_a"; break;
    case LOWER_B:               str = "lower_b"; break;
    case LOWER_C:               str = "lower_c"; break;
    case LOWER_D:               str = "lower_d"; break;
    case LOWER_E:               str = "lower_e"; break;
    case LOWER_F:               str = "lower_f"; break;
    case LOWER_G:               str = "lower_g"; break;
    case LOWER_H:               str = "lower_h"; break;
    case LOWER_I:               str = "lower_i"; break;
    case LOWER_J:               str = "lower_j"; break;
    case LOWER_K:               str = "lower_k"; break;
    case LOWER_L:               str = "lower_l"; break;
    case LOWER_M:               str = "lower_m"; break;
    case LOWER_N:               str = "lower_n"; break;
    case LOWER_O:               str = "lower_o"; break;
    case LOWER_P:               str = "lower_p"; break;
    case LOWER_Q:               str = "lower_q"; break;
    case LOWER_R:               str = "lower_r"; break;
    case LOWER_S:               str = "lower_s"; break;
    case LOWER_T:               str = "lower_t"; break;
    case LOWER_U:               str = "lower_u"; break;
    case LOWER_V:               str = "lower_v"; break;
    case LOWER_W:               str = "lower_w"; break;
    case LOWER_X:               str = "lower_x"; break;
    case LOWER_Y:               str = "lower_y"; break;
    case LOWER_Z:               str = "lower_z"; break;
  }
  return str;
}

// Global function to get the char name
string getWordName(int wordIdx) {
  string str = "NOT_DEF";
  switch (wordIdx) {
    // set 1
    case ABC:           str = "ABC"; break;
    case CBS:           str = "CBS"; break;
    case CNN:           str = "CNN"; break;
    case DISCOVERY:     str = "DISCOVERY"; break;
    case DISNEY:        str = "DISNEY"; break;
    case ESPN:          str = "ESPN"; break;
    case FOX:           str = "FOX"; break;
    case HBO:           str = "HBO"; break;
    case NBC:           str = "NBC"; break;
    case TBS:           str = "TBS"; break;

      // set 2
    case BBC:           str = "BBC"; break;
    case FX:            str = "FX"; break;
    case HULU:          str = "HULU"; break;
    case TNT:           str = "TNT"; break;
    case MUSIC:         str = "MUSIC"; break;
    case JAZZ:          str = "JAZZ"; break;
    case ROCK:          str = "ROCK"; break;
    case DRAMA:         str = "DRAMA"; break;
    case MOVIE:         str = "MOVIE"; break;
    case SPORT:         str = "SPORT"; break;

      // set 3
    case WEATHER:       str = "WEATHER"; break;
    case NEWS:          str = "NEWS"; break;
    case MLB:           str = "MLB"; break;
    case NFL:           str = "NFL"; break;
    case TRAVEL:        str = "TRAVEL"; break;
    case POKER:         str = "POKER"; break;
    case FOOD:          str = "FOOD"; break;
    case KID:           str = "KID"; break;
    case MAP:           str = "MAP"; break;
    case TV:            str = "TV"; break;

      // set 4
    case GAME:          str = "GAME"; break;
    case VOICE:         str = "VOICE"; break;
    case CALL:          str = "CALL"; break;
    case MAIL:          str = "MAIL"; break;
    case MSG:           str = "MSG"; break;
    case FB:            str = "FB"; break;
    case YOU:           str = "YOU"; break;
    case GOOGLE:        str = "GOOGLE"; break;
    case SKYPE:         str = "SKYPE"; break;
    case QUIZ:          str = "QUIZ"; break;

      // expansion 1k set
    case THE: str="THE"; break; case OF : str="OF" ; break; case AND: str="AND"; break; case TO : str="TO" ; break; case IN_: str="IN" ; break;
    case FOR: str="FOR"; break; case IS : str="IS" ; break; case THA: str="THA"; break; case PRO: str="PRO"; break; case THI: str="THI"; break;
    case ON : str="ON" ; break; case WIT: str="WIT"; break; case BY : str="BY" ; break; case COM: str="COM"; break; case NOT: str="NOT"; break;
    case IT : str="IT" ; break; case ARE: str="ARE"; break; case OR : str="OR" ; break; case CON: str="CON"; break; case NEW: str="NEW"; break;
    case BE : str="BE" ; break; case FRO: str="FRO"; break; case AT : str="AT" ; break; case AS : str="AS" ; break; case ALL: str="ALL"; break;
    case STA: str="STA"; break; case RES: str="RES"; break; case USE: str="USE"; break; case PRI: str="PRI"; break; case MOR: str="MOR"; break;
    case HAV: str="HAV"; break; case WAS: str="WAS"; break; case CAN: str="CAN"; break; case AN : str="AN" ; break; case INT: str="INT"; break;
    case SHO: str="SHO"; break; case WIL: str="WIL"; break; case SER: str="SER"; break; case WOR: str="WOR"; break; case HOM: str="HOM"; break;
    case WE : str="WE" ; break; case ABO: str="ABO"; break; case INF: str="INF"; break; case COU: str="COU"; break; case PAG: str="PAG"; break;
    case CAR: str="CAR"; break; case ONL: str="ONL"; break; case US : str="US" ; break; case SEA: str="SEA"; break; case WHI: str="WHI"; break;
    case PAR: str="PAR"; break; case POS: str="POS"; break; case IF : str="IF" ; break; case TIM: str="TIM"; break; case FRE: str="FRE"; break;
    case REA: str="REA"; break; case OTH: str="OTH"; break; case WHE: str="WHE"; break; case SIT: str="SIT"; break; case PLA: str="PLA"; break;
    case PER: str="PER"; break; case MAN: str="MAN"; break; case BUT: str="BUT"; break; case DAT: str="DAT"; break; case MY : str="MY" ; break;
    case OFF: str="OFF"; break; case HAS: str="HAS"; break; case ONE: str="ONE"; break; case HER: str="HER"; break; case EVE: str="EVE"; break;
    case STO: str="STO"; break; case OUR: str="OUR"; break; case ADD: str="ADD"; break; case PRE: str="PRE"; break; case FIN: str="FIN"; break;
    case LIN: str="LIN"; break; case NO : str="NO" ; break; case LIS: str="LIS"; break; case DO : str="DO" ; break; case ACC: str="ACC"; break;
    case TRA: str="TRA"; break; case INC: str="INC"; break; case OUT_:str="OUT"; break; case SEE: str="SEE"; break; case CHA: str="CHA"; break;
    case WEB: str="WEB"; break; case HIS: str="HIS"; break; case UNI: str="UNI"; break; case MAY: str="MAY"; break; case IND: str="IND"; break;
    case HE : str="HE" ; break; case UP : str="UP" ; break; case ANY: str="ANY"; break; case WHA: str="WHA"; break; case MAR: str="MAR"; break;
    case SEC: str="SEC"; break; case HEA: str="HEA"; break; case REP: str="REP"; break; case YEA: str="YEA"; break; case THR: str="THR"; break;
    case SOM: str="SOM"; break; case WHO: str="WHO"; break; case PHO: str="PHO"; break; case HEL: str="HEL"; break; case BUS: str="BUS"; break;
    case MUS: str="MUS"; break; case DAY: str="DAY"; break; case APP: str="APP"; break; case ART: str="ART"; break; case RAT: str="RAT"; break;
    case HOW: str="HOW"; break; case TOP: str="TOP"; break; case HOT: str="HOT"; break; case STU: str="STU"; break; case REC: str="REC"; break;
    case SEL: str="SEL"; break; case GET: str="GET"; break; case MEM: str="MEM"; break; case VIE: str="VIE"; break; case ACT: str="ACT"; break;
    case DIS: str="DIS"; break; case FIR: str="FIR"; break; case BOO: str="BOO"; break; case JAN: str="JAN"; break; case LEA: str="LEA"; break;
    case CLI: str="CLI"; break; case SO : str="SO" ; break; case REL: str="REL"; break; case SUP: str="SUP"; break; case POL: str="POL"; break;
    case DES: str="DES"; break; case REV: str="REV"; break; case PUB: str="PUB"; break; case MAI: str="MAI"; break; case REG: str="REG"; break;
    case MON: str="MON"; break; case RIG: str="RIG"; break; case ALS: str="ALS"; break; case ITE: str="ITE"; break; case SOU: str="SOU"; break;
    case SYS: str="SYS"; break; case RE : str="RE" ; break; case PM : str="PM" ; break; case GRO: str="GRO"; break; case NOW: str="NOW"; break;
    case LOC: str="LOC"; break; case VER: str="VER"; break; case MAK: str="MAK"; break; case SPE: str="SPE"; break; case OVE: str="OVE"; break;
    case DEV: str="DEV"; break; case CHI: str="CHI"; break; case ITS: str="ITS"; break; case LIK: str="LIK"; break; case BEE: str="BEE"; break;
    case ME : str="ME" ; break; case HOU: str="HOU"; break; case WER: str="WER"; break; case INS: str="INS"; break; case AM : str="AM" ; break;
    case CAL: str="CAL"; break; case FIL: str="FIL"; break; case WOU: str="WOU"; break; case GAM: str="GAM"; break; case CEN: str="CEN"; break;
    case BAS: str="BAS"; break; case DOW: str="DOW"; break; case NAM: str="NAM"; break; case DIR: str="DIR"; break; case COL: str="COL"; break;
    case THO: str="THO"; break; case TEC: str="TEC"; break; case BAC: str="BAC"; break; case SCH: str="SCH"; break; case SUB: str="SUB"; break;
    case NEE: str="NEE"; break; case JUS: str="JUS"; break; case CRE: str="CRE"; break; case MOV: str="MOV"; break; case GOO: str="GOO"; break;
    case BUY: str="BUY"; break; case MES: str="MES"; break; case HIG: str="HIG"; break; case KNO: str="KNO"; break; case REQ: str="REQ"; break;
    case PEO: str="PEO"; break; case HAD: str="HAD"; break; case FRI: str="FRI"; break; case WEL: str="WEL"; break; case NAT: str="NAT"; break;
    case PIC: str="PIC"; break; case SEN: str="SEN"; break; case GRE: str="GRE"; break; case NET: str="NET"; break; case TAK: str="TAK"; break;
    case COP: str="COP"; break; case ADV: str="ADV"; break; case MED: str="MED"; break; case AVA: str="AVA"; break; case BEC: str="BEC"; break;
    case ASS: str="ASS"; break; case TOO: str="TOO"; break; case LAS: str="LAS"; break; case VID: str="VID"; break; case FEE: str="FEE"; break;
    case CAS: str="CAS"; break; case DEC: str="DEC"; break; case SUC: str="SUC"; break; case TWO: str="TWO"; break; case CIT: str="CIT"; break;
    case ENT: str="ENT"; break; case EMA: str="EMA"; break; case NUM: str="NUM"; break; case AUT: str="AUT"; break; case GO : str="GO" ; break;
    case STR: str="STR"; break; case NEX: str="NEX"; break; case MOS: str="MOS"; break; case OPE: str="OPE"; break; case DET: str="DET"; break;
    case LON: str="LON"; break; case FOU: str="FOU"; break; case UND: str="UND"; break; case SEX: str="SEX"; break; case WIN: str="WIN"; break;
    case GEN: str="GEN"; break; case FUN: str="FUN"; break; case SET: str="SET"; break; case MOD: str="MOD"; break; case LOO: str="LOO"; break;
    case CAT: str="CAT"; break; case ORD: str="ORD"; break; case ENG: str="ENG"; break; case SOF: str="SOF"; break; case BET: str="BET"; break;
    case SIN: str="SIN"; break; case CLA: str="CLA"; break; case AFT: str="AFT"; break; case PLE: str="PLE"; break; case FAC: str="FAC"; break;
    case TER: str="TER"; break; case AME: str="AME"; break; case SHE: str="SHE"; break; case BES: str="BES"; break; case MIN: str="MIN"; break;
    case MAT: str="MAT"; break; case CHE: str="CHE"; break; case POW: str="POW"; break; case WAY: str="WAY"; break; case SHA: str="SHA"; break;
    case JOB: str="JOB"; break; case EXP: str="EXP"; break; case SIG: str="SIG"; break; case SAI: str="SAI"; break; case AGE: str="AGE"; break;
    case FUL: str="FUL"; break; case SAM: str="SAM"; break; case SPO: str="SPO"; break; case PAY: str="PAY"; break; case EAC: str="EAC"; break;
    case RET: str="RET"; break; case WAT: str="WAT"; break; case SAL: str="SAL"; break; case WAN: str="WAN"; break; case OWN: str="OWN"; break;
    case EST: str="EST"; break; case EAS: str="EAS"; break; case NOR: str="NOR"; break; case TEX: str="TEX"; break; case VAL: str="VAL"; break;
    case IMP: str="IMP"; break; case FOL: str="FOL"; break; case SHI: str="SHI"; break; case TYP: str="TYP"; break; case EDU: str="EDU"; break;
    case LOG: str="LOG"; break; case DE : str="DE" ; break; case MIL: str="MIL"; break; case GIV: str="GIV"; break; case DOE: str="DOE"; break;
    case CUS: str="CUS"; break; case CUR: str="CUR"; break; case QUE: str="QUE"; break; case IMA: str="IMA"; break; case LIV: str="LIV"; break;
    case ISS: str="ISS"; break; case LIF: str="LIF"; break; case CAM: str="CAM"; break; case GUI: str="GUI"; break; case DVD: str="DVD"; break;
    case WRI: str="WRI"; break; case WOM: str="WOM"; break; case SEP: str="SEP"; break; case EDI: str="EDI"; break; case LAT: str="LAT"; break;
    case OCT: str="OCT"; break; case FAM: str="FAM"; break; case HAR: str="HAR"; break; case ELE: str="ELE"; break; case NOV: str="NOV"; break;
    case TEA: str="TEA"; break; case EBA: str="EBA"; break; case PAS: str="PAS"; break; case WEE: str="WEE"; break; case BEF: str="BEF"; break;
    case DID: str="DID"; break; case ROO: str="ROO"; break; case DIF: str="DIF"; break; case BLO: str="BLO"; break; case SAY: str="SAY"; break;
    case TEL: str="TEL"; break; case EFF: str="EFF"; break; case NON: str="NON"; break; case MEN: str="MEN"; break; case POR: str="POR"; break;
    case USI: str="USI"; break; case MAD: str="MAD"; break; case AGA: str="AGA"; break; case BOT: str="BOT"; break; case END: str="END"; break;
    case LOW: str="LOW"; break; case LEV: str="LEV"; break; case UK : str="UK" ; break; case MEA: str="MEA"; break; case DEA: str="DEA"; break;
    case FEA: str="FEA"; break; case LAR: str="LAR"; break; case SOC: str="SOC"; break; case JUN: str="JUN"; break; case HIM: str="HIM"; break;
    case REM: str="REM"; break; case LAW: str="LAW"; break; case COS: str="COS"; break; case FOO: str="FOO"; break; case COD: str="COD"; break;
    case JUL: str="JUL"; break; case TIT: str="TIT"; break; case BOA: str="BOA"; break; case VIS: str="VIS"; break; case POI: str="POI"; break;
    case EUR: str="EUR"; break; case LAN: str="LAN"; break; case QUA: str="QUA"; break; case BRO: str="BRO"; break; case APR: str="APR"; break;
    case KIN: str="KIN"; break; case UPD: str="UPD"; break; case SIM: str="SIM"; break; case TEE: str="TEE"; break; case AUG: str="AUG"; break;
    case TOD: str="TOD"; break; case BLA: str="BLA"; break; case JOI: str="JOI"; break; case OLD: str="OLD"; break; case LIT: str="LIT"; break;
    case SPA: str="SPA"; break; case BUI: str="BUI"; break; case BEI: str="BEI"; break; case MUC: str="MUC"; break; case FEB: str="FEB"; break;
    case WES: str="WES"; break; case SMA: str="SMA"; break; case SCI: str="SCI"; break; case GRA: str="GRA"; break; case STE: str="STE"; break;
    case BEL: str="BEL"; break; case GIF: str="GIF"; break; case TES: str="TES"; break; case JOH: str="JOH"; break; case MIC: str="MIC"; break;
    case MET: str="MET"; break; case GIR: str="GIR"; break; case AWA: str="AWA"; break; case RED: str="RED"; break; case ANO: str="ANO"; break;
    case SOL: str="SOL"; break; case MEE: str="MEE"; break; case DEP: str="DEP"; break; case DEL: str="DEL"; break; case GOL: str="GOL"; break;
    case BEA: str="BEA"; break; case POP: str="POP"; break; case PAP: str="PAP"; break; case COR: str="COR"; break; case BIG: str="BIG"; break;
    case OPT: str="OPT"; break; case SON: str="SON"; break; case SIZ: str="SIZ"; break; case LET: str="LET"; break; case TOT: str="TOT"; break;
    case DUR: str="DUR"; break; case HAN: str="HAN"; break; case SUR: str="SUR"; break; case GOV: str="GOV"; break; case AUS: str="AUS"; break;
    case LES: str="LES"; break; case AIR: str="AIR"; break; case USA: str="USA"; break; case ARC: str="ARC"; break; case DIG: str="DIG"; break;
    case FRA: str="FRA"; break; case LOA: str="LOA"; break; case ANN: str="ANN"; break; case LOV: str="LOV"; break; case RUN: str="RUN"; break;
    case HOS: str="HOS"; break; case GAL: str="GAL"; break; case WHY: str="WHY"; break; case WED: str="WED"; break; case EAR: str="EAR"; break;
    case SUN: str="SUN"; break; case DOC: str="DOC"; break; case CLO: str="CLO"; break; case CD : str="CD" ; break; case REF: str="REF"; break;
    case LOS: str="LOS"; break; case THU: str="THU"; break; case PUR: str="PUR"; break; case KEY: str="KEY"; break; case SAV: str="SAV"; break;
    case ENV: str="ENV"; break; case AMO: str="AMO"; break; case FLO: str="FLO"; break; case CHR: str="CHR"; break; case PAC: str="PAC"; break;
    case AGR: str="AGR"; break; case QUI: str="QUI"; break; case RAN: str="RAN"; break; case VAR: str="VAR"; break; case ANA: str="ANA"; break;
    case SAN: str="SAN"; break; case TRU: str="TRU"; break; case LEF: str="LEF"; break; case EQU: str="EQU"; break; case YOR: str="YOR"; break;
    case TAX: str="TAX"; break; case EXA: str="EXA"; break; case STI: str="STI"; break; case IDE: str="IDE"; break; case TRY: str="TRY"; break;
    case BRI: str="BRI"; break; case GAY: str="GAY"; break; case PAT: str="PAT"; break; case ASK: str="ASK"; break; case AVE: str="AVE"; break;
    case ARO: str="ARO"; break; case LEG: str="LEG"; break; case FIE: str="FIE"; break; case EXC: str="EXC"; break; case BOX: str="BOX"; break;
    case LIB: str="LIB"; break; case LA : str="LA" ; break; case DAV: str="DAV"; break; case HUM: str="HUM"; break; case QUO: str="QUO"; break;
    case WAR: str="WAR"; break; case VE : str="VE" ; break; case DRI: str="DRI"; break; case TAB: str="TAB"; break; case BAN: str="BAN"; break;
    case COV: str="COV"; break; case MIS: str="MIS"; break; case FUR: str="FUR"; break; case EMP: str="EMP"; break; case DEF: str="DEF"; break;
    case TOW: str="TOW"; break; case CEL: str="CEL"; break; case YAH: str="YAH"; break; case REN: str="REN"; break; case TRE: str="TRE"; break;
    case NEV: str="NEV"; break; case YES: str="YES"; break; case LL : str="LL" ; break; case MAJ: str="MAJ"; break; case SAF: str="SAF"; break;
    case CLE: str="CLE"; break; case MAG: str="MAG"; break; case GOI: str="GOI"; break; case SAT: str="SAT"; break; case LIG: str="LIG"; break;
    case FAS: str="FAS"; break; case ECO: str="ECO"; break; case ISL: str="ISL"; break; case MOB: str="MOB"; break; case SID: str="SID"; break;
    case CHO: str="CHO"; break; case SUM: str="SUM"; break; case GER: str="GER"; break; case EXT: str="EXT"; break; case MAC: str="MAC"; break;
    case HOL: str="HOL"; break; case VIR: str="VIR"; break; case RUL: str="RUL"; break; case SCO: str="SCO"; break; case BRA: str="BRA"; break;
    case ALT: str="ALT"; break; case BOD: str="BOD"; break; case ST : str="ST" ; break; case PC : str="PC" ; break; case TRI: str="TRI"; break;
    case LIM: str="LIM"; break; case GOT: str="GOT"; break; case FEW: str="FEW"; break; case TUE: str="TUE"; break; case CAP: str="CAP"; break;
    case FAR_:str="FAR"; break; case POK: str="POK"; break; case MUL: str="MUL"; break; case CLU: str="CLU"; break; case FAQ: str="FAQ"; break;
    case SEV: str="SEV"; break; case ROA: str="ROA"; break; case NIG: str="NIG"; break; case AL : str="AL" ; break; case TAL: str="TAL"; break;
    case AFF: str="AFF"; break; case BIL: str="BIL"; break; case INV: str="INV"; break; case YET: str="YET"; break; case LOT: str="LOT"; break;
    case SKI: str="SKI"; break; case TOU: str="TOU"; break; case MIG: str="MIG"; break; case ANI: str="ANI"; break; case OPP: str="OPP"; break;
    case FUT: str="FUT"; break; case SOR: str="SOR"; break; case TUR: str="TUR"; break; case KEE: str="KEE"; break; case BLU: str="BLU"; break;
    case AFR: str="AFR"; break; case ASI: str="ASI"; break; case CER: str="CER"; break; case JAP: str="JAP"; break; case HAL: str="HAL"; break;
    case MAS: str="MAS"; break; case AUD: str="AUD"; break; case BEN: str="BEN"; break; case DIE: str="DIE"; break; case BEG: str="BEG"; break;
    case CO : str="CO" ; break; case ALW: str="ALW"; break; case ENE: str="ENE"; break; case BAB: str="BAB"; break; case WAL: str="WAL"; break;
    case FAX: str="FAX"; break; case CA : str="CA" ; break; case ORG: str="ORG"; break; case ALO: str="ALO"; break; case ONC: str="ONC"; break;
    case PRA: str="PRA"; break; case HAP: str="HAP"; break; case ORI_:str="ORI"; break; case DOM: str="DOM"; break; case RSS: str="RSS"; break;
    case RAD: str="RAD"; break; case BOY: str="BOY"; break; case ID : str="ID" ; break; case II : str="II" ; break; case GEO: str="GEO"; break;
    case ABL: str="ABL"; break; case FIG: str="FIG"; break; case DRU: str="DRU"; break; case VOL: str="VOL"; break; case WIS: str="WIS"; break;
    case UNT: str="UNT"; break; case PUT: str="PUT"; break; case FAI: str="FAI"; break; case DAI: str="DAI"; break; case GOD: str="GOD"; break;
    case SCR: str="SCR"; break; case WRO: str="WRO"; break; case WEA: str="WEA"; break; case ERR: str="ERR"; break; case STY: str="STY"; break;
    case URL: str="URL"; break; case DON: str="DON"; break; case GAR: str="GAR"; break; case NEA: str="NEA"; break; case ADU: str="ADU"; break;
    case AGO: str="AGO"; break; case FED: str="FED"; break; case TIC: str="TIC"; break; case USU: str="USU"; break; case VOI: str="VOI"; break;
    case CUL: str="CUL"; break; case EIT: str="EIT"; break; case MOT: str="MOT"; break; case BAD: str="BAD"; break; case TIP: str="TIP"; break;
    case FLA: str="FLA"; break; case RIS: str="RIS"; break; case UPO: str="UPO"; break; case ROC: str="ROC"; break; case MID: str="MID"; break;
    case GLO: str="GLO"; break; case LYR: str="LYR"; break; case ATT: str="ATT"; break; case JOU: str="JOU"; break; case ALR: str="ALR"; break;
    case ITA: str="ITA"; break; case DUE: str="DUE"; break; case ANS: str="ANS"; break; case PLU: str="PLU"; break; case WEI: str="WEI"; break;
    case OFT: str="OFT"; break; case VIA: str="VIA"; break; case POO: str="POO"; break; case SPR: str="SPR"; break; case AMA: str="AMA"; break;
    case WID: str="WID"; break; case PET: str="PET"; break; case ET : str="ET" ; break; case CAU: str="CAU"; break; case CRI: str="CRI"; break;
    case TOG: str="TOG"; break; case NUD: str="NUD"; break; case LIC: str="LIC"; break; case WIR: str="WIR"; break; case CHU: str="CHU"; break;
    case JAM: str="JAM"; break; case FIV: str="FIV"; break; case DAN: str="DAN"; break; case ACA: str="ACA"; break; case PAI: str="PAI"; break;
    case ENO: str="ENO"; break; case OIL: str="OIL"; break; case KIT: str="KIT"; break; case EXI: str="EXI"; break; case ELS: str="ELS"; break;
    case PAU: str="PAU"; break; case EXE: str="EXE"; break; case MAX: str="MAX"; break; case ALB: str="ALB"; break; case ADM: str="ADM"; break;
    case DOI: str="DOI"; break; case DOG: str="DOG"; break; case PAN: str="PAN"; break; case DOU: str="DOU"; break; case BIT: str="BIT"; break;
    case FIT: str="FIT"; break; case BAR: str="BAR"; break; case IRA: str="IRA"; break; case RIC: str="RIC"; break; case OBJ: str="OBJ"; break;
    case NY : str="NY" ; break; case USR: str="USR"; break; case CRO: str="CRO"; break; case ACR: str="ACR"; break; case RUS: str="RUS"; break;
    case NEC: str="NEC"; break; case FUC: str="FUC"; break; case BEH: str="BEH"; break; case LAK: str="LAK"; break; case GAS: str="GAS"; break;
    case BRE: str="BRE"; break; case TOY: str="TOY"; break; case OH : str="OH" ; break; case EYE: str="EYE"; break; case DIV: str="DIV"; break;
    case HIT: str="HIT"; break; case ROB: str="ROB"; break; case BAY: str="BAY"; break; case WEN: str="WEN"; break; case CAB: str="CAB"; break;
    case DC : str="DC" ; break; case FAT: str="FAT"; break; case CNE: str="CNE"; break; case EN : str="EN" ; break; case MAL: str="MAL"; break;
    case GOA: str="GOA"; break; case FAL: str="FAL"; break; case FEM: str="FEM"; break; case AD : str="AD" ; break; case HTM: str="HTM"; break;
    case MOU: str="MOU"; break; case GUY: str="GUY"; break; case BED: str="BED"; break; case JAC: str="JAC"; break; case SOO: str="SOO"; break;
    case NAV: str="NAV"; break; case OBT: str="OBT"; break; case ROL: str="ROL"; break; case GUE: str="GUE"; break; case OPI: str="OPI"; break;
    case GLA: str="GLA"; break; case FAV: str="FAV"; break; case EG : str="EG" ; break; case ROU: str="ROU"; break; case ANT: str="ANT"; break;
    case ALM: str="ALM"; break; case ONT: str="ONT"; break; case YEL: str="YEL"; break; case HAI: str="HAI"; break; case POT: str="POT"; break;
    case HUG: str="HUG"; break; case LOU: str="LOU"; break; case TEN: str="TEN"; break; case HP : str="HP" ; break; case INN: str="INN"; break;
    case BUD: str="BUD"; break; case GMT: str="GMT"; break; case HOR: str="HOR"; break; case WAI: str="WAI"; break; case PDF: str="PDF"; break;
    case SMI: str="SMI"; break; case HEN: str="HEN"; break; case MEX: str="MEX"; break; case TX : str="TX" ; break; case JEW: str="JEW"; break;
    case RIV: str="RIV"; break; case TOL: str="TOL"; break; case IP : str="IP" ; break; case HOP: str="HOP"; break; case ENS: str="ENS"; break;
    case ESP: str="ESP"; break; case FIX: str="FIX"; break; case ORA: str="ORA"; break; case ALA: str="ALA"; break; case RAC: str="RAC"; break;
    case VAC: str="VAC"; break; case PA : str="PA" ; break; case SIX: str="SIX"; break; case RD : str="RD" ; break; case MD : str="MD" ; break;
    case LTD: str="LTD"; break; case IRE: str="IRE"; break; case ZIP: str="ZIP"; break; case EVI: str="EVI"; break; case VAN: str="VAN"; break;
    case HIL: str="HIL"; break; case FAN: str="FAN"; break; case RIN: str="RIN"; break; case BIN: str="BIN"; break; case NIC: str="NIC"; break;
    case MS : str="MS" ; break; case BAL: str="BAL"; break; case PUS: str="PUS"; break; case AUC: str="AUC"; break; case NOK: str="NOK"; break;
    case ELI: str="ELI"; break; case DEG: str="DEG"; break; case WON: str="WON"; break; case DAR: str="DAR"; break; case BAT: str="BAT"; break;
    case WOO: str="WOO"; break; case XML: str="XML"; break; case SIL: str="SIL"; break; case CIV: str="CIV"; break; case ISB: str="ISB"; break;
    case IE : str="IE" ; break; case ABI: str="ABI"; break; case PST: str="PST"; break; case ETC: str="ETC"; break; case BOS: str="BOS"; break;
    case BID: str="BID"; break; case III: str="III"; break; case OK : str="OK" ; break; case USB: str="USB"; break; case FL : str="FL" ; break;
    case LEN: str="LEN"; break; case MA : str="MA" ; break; case FOC: str="FOC"; break; case MSN: str="MSN"; break; case MB : str="MB" ; break;
    case PHE: str="PHE"; break; case LE : str="LE" ; break; case OHI: str="OHI"; break; case AZ : str="AZ" ; break; case CUT: str="CUT"; break;
    case UNL: str="UNL"; break; case TOM: str="TOM"; break; case MIK: str="MIK"; break; case PHY: str="PHY"; break; case SAW: str="SAW"; break;
    case JER: str="JER"; break; case HI : str="HI" ; break; case ANG: str="ANG"; break; case INP: str="INP"; break; case BIB: str="BIB"; break;
    case GOE: str="GOE"; break; case ILL: str="ILL"; break; case PHP: str="PHP"; break; case JAV: str="JAV"; break; case DOO: str="DOO"; break;
    case IL : str="IL" ; break; case ZEA: str="ZEA"; break; case LLC: str="LLC"; break; case WIF: str="WIF"; break; case LOR: str="LOR"; break;
    case NC : str="NC" ; break; case LEE: str="LEE"; break; case VOT: str="VOT"; break; case IBM: str="IBM"; break; case MR : str="MR" ; break;
    case ROY: str="ROY"; break; case OS : str="OS" ; break; case ENJ: str="ENJ"; break; case ISR: str="ISR"; break; case ARG: str="ARG"; break;
    case KAN: str="KAN"; break; case MM : str="MM" ; break; case ND : str="ND" ; break; case NAK: str="NAK"; break; case BOR: str="BOR"; break;
    case MYS: str="MYS"; break; case JIM: str="JIM"; break; case PP : str="PP" ; break; case GAV: str="GAV"; break; case DEE: str="DEE"; break;
    case BOB: str="BOB"; break; case ARI: str="ARI"; break; case VEH: str="VEH"; break; case VA : str="VA" ; break; case TAR: str="TAR"; break;
    case XXX: str="XXX"; break; case VEG: str="VEG"; break; case SC : str="SC" ; break; case IMM: str="IMM"; break; case PEN: str="PEN"; break;
    case CUM: str="CUM"; break; case PIE: str="PIE"; break; case ENA: str="ENA"; break; case SCA: str="SCA"; break; case JON: str="JON"; break;
    case BON: str="BON"; break; case COA: str="COA"; break; case COO: str="COO"; break; case PO : str="PO" ; break; case TH : str="TH" ; break;
    case ORE: str="ORE"; break; case KON: str="KON"; break; case GA : str="GA" ; break; case LED: str="LED"; break; case ABS: str="ABS"; break;
    case SES: str="SES"; break; case BEY: str="BEY"; break; case DEM: str="DEM"; break; case EL : str="EL" ; break; case PAL: str="PAL"; break;
    case MOM: str="MOM"; break; case JOE: str="JOE"; break; case JES: str="JES"; break; case RAP: str="RAP"; break; case INI: str="INI"; break;
    case FIC: str="FIC"; break; case SUI: str="SUI"; break; case KM : str="KM" ; break; case WWW: str="WWW"; break; case FEL: str="FEL"; break;
    case LCD: str="LCD"; break; case WA : str="WA" ; break; case NJ : str="NJ" ; break; case EU : str="EU" ; break; case DAK: str="DAK"; break;
    case XP : str="XP" ; break; case JUM: str="JUM"; break; case ARM: str="ARM"; break; case XBO: str="XBO"; break; case KNE: str="KNE"; break;
    case HON: str="HON"; break; case VHS: str="VHS"; break; case IOW: str="IOW"; break; case DAM: str="DAM"; break; case COC: str="COC"; break;
    case BOU: str="BOU"; break; case AU : str="AU" ; break; case FIS: str="FIS"; break; case CDS: str="CDS"; break; case IPO: str="IPO"; break;
    case HAW: str="HAW"; break; case TEM: str="TEM"; break; case ATL: str="ATL"; break; case USD: str="USD"; break; case DEB: str="DEB"; break;
    case LAC: str="LAC"; break; case KOR: str="KOR"; break; case AVO: str="AVO"; break; case EVA: str="EVA"; break; case SLI: str="SLI"; break;
    case MI : str="MI" ; break; case DOL: str="DOL"; break; case GON: str="GON"; break; case KB : str="KB" ; break; case DJ : str="DJ" ; break;
    case DAL: str="DAL"; break; case PHI: str="PHI"; break; case DR : str="DR" ; break; case JOS: str="JOS"; break; case DI : str="DI" ; break;
    case BYT: str="BYT"; break; case GEA: str="GEA"; break; case BC : str="BC" ; break; case DIA: str="DIA"; break; case TOR: str="TOR"; break;
    case AC : str="AC" ; break; case DIC: str="DIC"; break; case OKL: str="OKL"; break; case ESS: str="ESS"; break; case KEP: str="KEP"; break;
    case TAS: str="TAS"; break; case EDG: str="EDG"; break; case DRO: str="DRO"; break; case PEA: str="PEA"; break; case ZON: str="ZON"; break;
    case MIA: str="MIA"; break; case NT : str="NT" ; break; case AID: str="AID"; break; case SUG: str="SUG"; break; case EIG: str="EIG"; break;
    case GAI: str="GAI"; break; case GB : str="GB" ; break; case SD : str="SD" ; break; case CUP: str="CUP"; break; case ACH: str="ACH"; break;
    case CT : str="CT" ; break; case NEG: str="NEG"; break; case ZUM: str="ZUM"; break; case PHA: str="PHA"; break; case HIV: str="HIV"; break;
    case VS : str="VS" ; break; case APA: str="APA"; break; case IV : str="IV" ; break; case DNA: str="DNA"; break; case AR : str="AR" ; break;
    case ASP: str="ASP"; break; case UTA: str="UTA"; break; case POC: str="POC"; break; case SEQ: str="SEQ"; break; case ADO: str="ADO"; break;
    case KEN: str="KEN"; break; case CIS: str="CIS"; break; case DED: str="DED"; break; case CM : str="CM" ; break; case SRC: str="SRC"; break;
    case UPG: str="UPG"; break; case MO : str="MO" ; break; case UNK: str="UNK"; break; case ED : str="ED" ; break; case OCC: str="OCC"; break;
    case SA : str="SA" ; break; case SWI: str="SWI"; break; case PDA: str="PDA"; break; case DU : str="DU" ; break; case MER: str="MER"; break;
    case NA : str="NA" ; break; case VIC: str="VIC"; break; case ERI: str="ERI"; break; case ICO: str="ICO"; break; case DSL: str="DSL"; break;
    case VIL: str="VIL"; break; case TAY: str="TAY"; break; case NE : str="NE" ; break; case GUA: str="GUA"; break; case FUE: str="FUE"; break;
    case IRI: str="IRI"; break; case EM : str="EM" ; break; case TN : str="TN" ; break; case ROS: str="ROS"; break; case DAU: str="DAU"; break;
    case AOL: str="AOL"; break; case SWE: str="SWE"; break; case UTC: str="UTC"; break; case CIR: str="CIR"; break; case ORL: str="ORL"; break;
    case JEF: str="JEF"; break; case SYD: str="SYD"; break; case FES: str="FES"; break; case UPP: str="UPP"; break; case KEV: str="KEV"; break;
    case UN : str="UN" ; break; case SQL: str="SQL"; break; case ABU: str="ABU"; break; case ADS: str="ADS"; break; case RAI: str="RAI"; break;
    case VOY: str="VOY"; break; case MN : str="MN" ; break; case GPS: str="GPS"; break; case EAT: str="EAT"; break; case LAB: str="LAB"; break;
    case PDT: str="PDT"; break; case EME: str="EME"; break; case EDW: str="EDW"; break; case PR : str="PR" ; break; case AVG: str="AVG"; break;
    case TON: str="TON"; break; case HAM: str="HAM"; break; case BUR: str="BUR"; break; case NUR: str="NUR"; break; case AHE: str="AHE"; break;
    case PIN: str="PIN"; break; case OZ : str="OZ" ; break; case OBS: str="OBS"; break; case ATO: str="ATO"; break; case VIO: str="VIO"; break;
    case EPI: str="EPI"; break; case SQU: str="SQU"; break; case COF: str="COF"; break; case NUC: str="NUC"; break; case ARK: str="ARK"; break;
  }
  return str;
}
}  // namespace GestureDef
