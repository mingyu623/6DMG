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

#pragma comment(lib, "libmat.lib")
#pragma comment(lib, "libmx.lib")

#include <mat.h>
#include <GestureDef.h>
#include <Config.h>

using namespace GestureDef;
using namespace std;

#define N_ELEM 14           // total elements per sample (for Matlab exporter)
#define SAMP_PERIOD	1			// show the sample number instead of the true time stamp
//#define SAMP_PERIOD 166666	// 60 Hz

#define M_PI		3.14159265358979323846	// pi
#define EPSILON		0.01 // threshold or quaternion conversion

/* -------------------------------------------------- */
/* ----- Private type definition for HTKWrite() ----- */
/* -------------------------------------------------- */
typedef struct {
  unsigned int nSamples;	// sizeof(int) = 4 = sizeof(float)
  unsigned int sampPeriod;  // in 100ns units
  unsigned short sampSize;  // sizeof(short)= 2
  unsigned short parmKind;
} htk_header_t;

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

int GestToMat(char* fname, Gesture& g);
int GestToHTK(char* fname, Gesture& g);
int preprocessHTK(Gesture& g, unsigned short nElem, float* buff);
int preprocessHTK_Legacy(Gesture& g, unsigned short nElem, float* buff);

// compute the normalization "scale"
float normalizePOS(Gesture& g);
float normalizeVEL(Gesture& g);
float normalizeACC(Gesture& g);
float normalizeW(Gesture& g);
float normalizeORI(Gesture& g);
float normalizePitch(vector<float> pitch);
float normalizeORI_Legacy(Gesture& g);
float normalizePOS_univar(Gesture& g, XYZ& avgPOS);


XYZ   convertGACC(XYZ acc, ORI q);
XYZ   boundingBoxCenter(Gesture& g);
ORI   quatScale(ORI q, float s);
ORI   averageOri(Gesture& g);
void  leastSquaresFit(vector<float>& y, float& a, float& b); // y = ax + b
Euler quatToEulerZXY(ORI q);
ORI   eulerZXYToQuat(Euler e);
float centerPitch(vector<float> pitch);

#endif  // _6DMG_UTIL_H_
