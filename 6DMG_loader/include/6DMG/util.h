/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com) 
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/
#ifndef _6DMG_UTIL_H_
#define _6DMG_UTIL_H_

#include <6DMG/GestureDef.h>
#include <6DMG/Config.h>

using namespace GestureDef;

#define N_ELEM 14      // total elements per sample (for Matlab exporter)
#define SAMP_PERIOD 1  // show the sample number instead of the true time stamp
// #define SAMP_PERIOD 166666  // 60 Hz

#define H_LPC       1
#define H_LPREFC    2
#define H_LPCEPSTRA 3
#define H_MFCC      6
#define H_FBANK     7
#define H_USER      9

#define HASENERGY   0x0040
#define HASNOE      0x0080
#define HASDELTA    0x0100
#define HASZMEAN    0x0800


#define EPSILON 0.01  // threshold for quaternion conversion

namespace Util {

class Converter {
 public:
  /**
   * Utility functions to convert a gesture recording to a Mat file
   */
  int GestToMat(char* fname, Gesture& g);

  /**
   * Utility functions to convert a gesture recording to a HTK file
   */
  int GestToHTK(char* fname, Gesture& g);

  /**
   * Preprocess a gesture recording (i.e., normalization)
   */
  int preprocessHTK(Gesture& g, unsigned short nElem, float* buff);

  /**
   * Preprocess a gesture recording (i.e., normalization) used in ICASSP12
   * and the journal "Feature Processing and Modeling for 6D Motion Gesture Recognition"
   */
  int preprocessHTK_Legacy(Gesture& g, unsigned short nElem, float* buff);

 private:
  // Header for HTKWrite()
  struct htk_header_t {
    unsigned int nSamples;    // sizeof(int) = 4 = sizeof(float)
    unsigned int sampPeriod;  // in 100ns units
    unsigned short sampSize;  // sizeof(short)= 2
    unsigned short parmKind;
  };

  /**
   * The implementation of normalization of various types of motion data
   */
  float normalizePOS(Gesture& g);
  float normalizeVEL(Gesture& g);
  float normalizeACC(Gesture& g);
  float normalizeW(Gesture& g);
  float normalizeORI(Gesture& g);
  float normalizePitch(vector<float> pitch);
  float normalizeORI_Legacy(Gesture& g);
  float normalizePOS_univar(Gesture& g, XYZ& avgPOS);

  /**
   * Other internal utility functions
   */
   XYZ   convertGACC(XYZ acc, ORI q);
   XYZ   boundingBoxCenter(Gesture& g);
   ORI   quatScale(ORI q, float s);
   ORI   averageOri(Gesture& g);
   void  leastSquaresFit(vector<float>& y, float& a, float& b); // y = ax + b
   Euler quatToEulerZXY(ORI q);
   ORI   eulerZXYToQuat(Euler e);
   float centerPitch(vector<float> pitch);
};





}  // namespace Util
#endif  // _6DMG_UTIL_H_
