/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com)
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/

// TODO(mingyu): fix this in cmake maybe
#pragma comment(lib, "libmat.lib")
#pragma comment(lib, "libmx.lib")

#include <6DMG/util.h>
#include <math.h>  // for M_PI
#include <mat.h>
#include <iostream>

using std::cout;
using std::endl;

namespace Util {

int GestToMat(char* file, Gesture& g) {
  MATFile *pmat;
  mxArray *pa, *pa2, *pa3;

  pmat = matOpen(file, "w");
  if (pmat == NULL) {
    cout << "GestToMat fails at creating file " << file << endl;
    return -1;
  }

  int num = g.data.size();
  // (row, col) or (tuple, sample #)
  pa  = mxCreateNumericMatrix(N_ELEM, num, mxSINGLE_CLASS, mxREAL);
  pa2 = mxCreateNumericMatrix(3, 1, mxSINGLE_CLASS, mxREAL);
  pa3 = mxCreateNumericMatrix(3, 1, mxSINGLE_CLASS, mxREAL);
  if (pa == NULL || pa2 == NULL || pa3 == NULL) {
    cout << "GestToMat fails at creating mxArray" << endl;
    return -1;
  }

  // fill in mxArrays
  float *ptr = (float*)mxGetData(pa);
  for (int i = 0; i < num; i++) {
    Sample s = g.data.at(i);
    memcpy((void*)ptr, (void*)&s, sizeof(Sample));
    ptr += N_ELEM;
  }
  memcpy(mxGetData(pa2), (void*)&(g.noise), sizeof(YPR));
  memcpy(mxGetData(pa3), (void*)&(g.bias),  sizeof(YPR));

  // save mxArrays
  if (matPutVariable(pmat, "gest", pa) != 0) {
    cout << "GestToMat fails at saving samples: " << file << endl;
    return -1;
  }
  if (matPutVariable(pmat, "noise", pa2) != 0) {
    cout << "GestToMat fails at saving noise " << file << endl;
    return -1;
  }
  if (matPutVariable(pmat, "bias", pa3) != 0) {
    cout << "GestToMat fails at saving bias " << file << endl;
    return -1;
  }

  // clean up
  mxDestroyArray(pa);
  if (matClose(pmat) != 0) {
    cout << "GestToMat fails at closing file " << file << endl;
    return -1;
  }

  cout << "Export to " << file << endl;
  return 0;
}

// Utils to swap endian (big <-> little)
inline void endian_swap(unsigned short& x) {
  x = (x >> 8) |
      (x << 8);
}

inline void endian_swap(unsigned int& x) {
  x = (x >> 24) |
      ((x << 8) & 0x00FF0000) |
      ((x >> 8) & 0x0000FF00) |
      (x << 24);
}

int GestToHTK(char* fname, Gesture& g) {
  unsigned short nElem = 0;  // the # of elems we want to export (not ALL!)
  if (HTK_EXP & HTK_ACC) nElem += 3;
  if (HTK_EXP & HTK_POS) nElem += 3;
  if (HTK_EXP & HTK_VEL) nElem += 3;
  if (HTK_EXP & HTK_W)   nElem += 3;
  if (HTK_EXP & HTK_ORI) nElem += 4;
  if (HTK_EXP & HTK_P2D) nElem += 2;
  if (HTK_EXP & HTK_V2D) nElem += 2;
  if (HTK_EXP & HTK_POS_LR) nElem += 1;
  if (HTK_EXP & HTK_ORI_LR) nElem += 4;
  if (HTK_EXP & HTK_EA_PITCH) nElem += 1;
  if (HTK_EXP & HTK_POS_UV) nElem += 3;
  if (HTK_EXP & HTK_P2D_UV) nElem += 2;

  FILE* f = fopen(fname, "wb");  // write binary
  htk_header_t header;
  unsigned int num = g.data.size();  // # of samples
  header.nSamples = num;
  header.sampPeriod = SAMP_PERIOD;
  header.sampSize = nElem * sizeof(float);
  header.parmKind = H_USER;  // user defined data w/o flags (HASENERGY, HASDELTA, etc)

  // Swap from little endian (Windows) to big endian (required by HTK)
  endian_swap(header.nSamples);
  endian_swap(header.sampPeriod);
  endian_swap(header.sampSize);
  endian_swap(header.parmKind);

  // Write HTK header
  if (fwrite(&header, sizeof(htk_header_t), 1, f) != 1) {
    cout << "Error: write HTK header of " << fname << endl;
    return -1;
  }

  // Preprocess the data
  cout << "Export to " << fname << "\t";
  float* buff = new float [nElem * g.data.size()];
  preprocessHTK(g, nElem, buff);

  // Write HTK data
  // Mingyu: swap from little endian (Windows) to big endian (required by HTK)
  unsigned int* uint_buff = (unsigned int*)buff;
  for (int j = 0; j < nElem * g.data.size(); j++) {
    endian_swap(uint_buff[j]);
  }
  if (fwrite(uint_buff, sizeof(unsigned int), nElem*g.data.size(), f) != nElem*g.data.size()) {
    cout << "Error: write HTK data at " << fname << endl;
    return -1;
  }

  cout << "OK." << endl;
  delete [] buff;
  fclose(f);
  return 0;
}

// Have to pre-process the data (normalization)
int preprocessHTK(Gesture& g, unsigned short nElem, float* buff) {
  float scale_acc = (HTK_EXP & (HTK_ACC)) ? normalizeACC(g) : 1;
  float scale_pos = (HTK_EXP & (HTK_POS | HTK_P2D | HTK_POS_LR)) ? normalizePOS(g) : 50;
  float scale_vel = (HTK_EXP & (HTK_VEL | HTK_V2D)) ? normalizeVEL(g) : 100;
  float scale_w   = (HTK_EXP & (HTK_W)) ? normalizeW(g) : 1;

  // The following process may overwrite the ori in gesture g!
  // The original ori is stored in ori_raw
  std::vector<ORI> ori_raw;
  for (unsigned int i = 0; i < g.data.size(); i++) {
    ori_raw.push_back(g.data.at(i).ori);
  }

  // Euler angles in Z(roll), X(pitch), Y(yaw) respectively
  std::vector<float> psis, thetas, phis;
  if (HTK_EXP & (HTK_ORI_LR | HTK_EA_PITCH)) {
    // special case for left-to-right ori
    // quat -> euler
    for (unsigned int i = 0; i < g.data.size(); i++) {
      Euler e = quatToEulerZXY(g.data.at(i).ori);
      psis.push_back(e.psi);
      thetas.push_back(e.theta);
      phis.push_back(e.phi);
    }

    // least squares offset psi (yaw)
    float a, b;
    leastSquaresFit(phis, a, b);
    for (unsigned int i = 0; i < g.data.size(); i++) {
      float offset_phi = phis.at(i) - (a * i + b);
      phis.at(i) = offset_phi;
    }

    // euler -> quat (overwrite gesture g)
    for (unsigned int i = 0; i < g.data.size(); i++) {
      Euler e;
      e.psi   = psis.at(i);
      e.theta = thetas.at(i);
      e.phi   = phis.at(i);
      g.data.at(i).ori = eulerZXYToQuat(e);
    }
  }

  float scale_ori = (HTK_EXP & (HTK_ORI | HTK_ORI_LR)) ? normalizeORI(g) : 1;
  float scale_ea_pitch  = (HTK_EXP & HTK_EA_PITCH) ? normalizePitch(thetas) : 1;
  float cenPitch = (HTK_EXP & HTK_EA_PITCH) ? centerPitch(thetas) : 0;

  XYZ startPos = g.data.at(0).pos;
  XYZ prevPos  = startPos;
  XYZ cen = boundingBoxCenter(g);
  ORI startOriInv = quatConj(g.data.at(0).ori);
  ORI prevOriInv = startOriInv;
  ORI avgOriInv  = quatConj(averageOri(g));

  if (HTK_EXP & (HTK_POS_UV | HTK_P2D_UV)) {
    scale_pos = normalizePOS_univar(g, cen);  // cen becomes avgPos
  }

  for (unsigned int i = 0; i < g.data.size(); i++) {
    Sample s = g.data.at(i);
    XYZ acc, pos, vel;
    YPR w;
    ORI q;
    float pitch;

    // Adjust with proper scale
    // TODO(mingyu): implement operator overloads for my structs
    acc = (HTK_EXP & HTK_ACC) ? convertGACC(g.data.at(i).acc, ori_raw.at(i)) : g.data.at(i).acc;
    acc.x *= scale_acc;
    acc.y *= scale_acc;
    acc.z *= scale_acc;

    pos.x = (s.pos.x - cen.x) * scale_pos;
    pos.y = (s.pos.y - cen.y) * scale_pos;
    pos.z = (s.pos.z - cen.z) * scale_pos;

    if (i == 0) {  // duplicate the pos/vel at the second sample to avoid 0 vel
      vel.x = (g.data.at(1).pos.x - s.pos.x) * scale_vel;
      vel.y = (g.data.at(1).pos.y - s.pos.y) * scale_vel;
      vel.z = (g.data.at(1).pos.z - s.pos.z) * scale_vel;
    } else {
      vel.x = (s.pos.x - prevPos.x) * scale_vel;
      vel.y = (s.pos.y - prevPos.y) * scale_vel;
      vel.z = (s.pos.z - prevPos.z) * scale_vel;
    }
    w.yaw   = s.w.yaw   * scale_w;
    w.pitch = s.w.pitch * scale_w;
    w.roll  = s.w.roll  * scale_w;
    q = s.ori;

    if (HTK_EXP & (HTK_ORI | HTK_ORI_LR)) {
      // Ori normalization used for motion word
      q = quatNorm(quatMul(q, avgOriInv));  // offset by the *average* orientation
      // scale the rotation angle will cause HERest fail for motion words?
      q = quatScale(q, scale_ori);

      // Ori normalization used in ICASSP12 & 6DMG journal (for motion gestures)
      /*
      q = quatNorm(quatMul(q, startOriInv)); // offset by the starting orientation
      q = quatScale(q, scale_ori);  // scale the rotation angle
      //printf("%5.4f, %5.4f, %5.4f, %5.4f\n", q.w, q.x, q.y, q.z);
      */
    }

    prevPos = s.pos;
    prevOriInv = quatConj(s.ori);

    // store into buff
    float* ptr = buff + i * nElem;
    if (HTK_EXP & HTK_ACC) {
      memcpy(ptr, &acc, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_POS) {
      memcpy(ptr, &pos, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_POS_UV) {
      memcpy(ptr, &pos, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_VEL) {
      memcpy(ptr, &vel, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_W) {
      memcpy(ptr, &w, sizeof(YPR));
      ptr += 3;
    }
    if (HTK_EXP & HTK_ORI) {
      memcpy(ptr, &q, sizeof(ORI));
      ptr += 4;
    }
    if (HTK_EXP & HTK_P2D) {
      memcpy(ptr, &pos, sizeof(float) * 2);
      ptr += 2;
    }
    if (HTK_EXP & HTK_P2D_UV) {
      memcpy(ptr, &pos, sizeof(float) * 2);
      ptr += 2;
    }
    if (HTK_EXP & HTK_V2D) {
      memcpy(ptr, &vel, sizeof(float) * 2);
      ptr += 2;
    }
    if (HTK_EXP & HTK_POS_LR) {  // only use y coord
      memcpy(ptr, &pos.y, sizeof(float));
      ptr += 1;
    }
    if (HTK_EXP & HTK_ORI_LR) {
      memcpy(ptr, &q, sizeof(ORI));
      ptr += 4;
    }
    if (HTK_EXP & HTK_EA_PITCH) {
      pitch = (thetas.at(i) - cenPitch) * scale_ea_pitch;
      memcpy(ptr, &pitch, sizeof(float));
      ptr += 1;
    }
  }
  return 0;
}

// normalize based on unit var in y direction only
float normalizePOS_univar(Gesture& g, XYZ& avgPOS) {
  avgPOS.x = avgPOS.y = avgPOS.z = 0;
  for (unsigned int i = 0; i < g.data.size(); i++) {
    avgPOS.x += g.data.at(i).pos.x;
    avgPOS.y += g.data.at(i).pos.y;
    avgPOS.z += g.data.at(i).pos.z;
  }
  avgPOS.x /= g.data.size();
  avgPOS.y /= g.data.size();
  avgPOS.z /= g.data.size();

  float vary = 0;  // var in y
  for (unsigned int i = 0; i < g.data.size(); i++) {
    vary += (g.data.at(i).pos.y - avgPOS.y)*(g.data.at(i).pos.y - avgPOS.y);
  }
  vary /= (g.data.size()-1);

  return 1/sqrt(vary);
}

// calculate the scaling factor for normalization
// normalize based on the bounding box
float normalizePOS(Gesture& g) {
  XYZ startPos = g.data.at(0).pos;
  XYZ posMin = g.data.at(0).pos;
  XYZ posMax = posMin;
  for (unsigned int i = 1; i < g.data.size(); i++) {
    XYZ p = g.data.at(i).pos;
    if (p.x > posMax.x) posMax.x = p.x;
    if (p.y > posMax.y) posMax.y = p.y;
    if (p.z > posMax.z) posMax.z = p.z;
    if (p.x < posMin.x) posMin.x = p.x;
    if (p.y < posMin.y) posMin.y = p.y;
    if (p.z < posMin.z) posMin.z = p.z;
  }

  float diff_x = posMax.x - posMin.x;
  float diff_y = posMax.y - posMin.y;
  float diff_z = posMax.z - posMin.z;
  float diff;
  if (HTK_EXP & HTK_POS_LR) {
    diff = diff_y;  // only use the y position
  } else if (HTK_EXP & HTK_P2D) {
    diff = max(diff_x, diff_y);  // only use the x & y position
  } else {
    diff = max(max(diff_x, diff_y), diff_z);
  }
  return 2 / diff;
}

// compute the center of the bounding box
XYZ boundingBoxCenter(Gesture& g) {
  XYZ startPos = g.data.at(0).pos;
  XYZ posMin = g.data.at(0).pos;
  XYZ posMax = posMin;
  XYZ center;
  for (unsigned int i = 1; i < g.data.size(); i++) {
    XYZ p = g.data.at(i).pos;
    if (p.x > posMax.x) posMax.x = p.x;
    if (p.y > posMax.y) posMax.y = p.y;
    if (p.z > posMax.z) posMax.z = p.z;
    if (p.x < posMin.x) posMin.x = p.x;
    if (p.y < posMin.y) posMin.y = p.y;
    if (p.z < posMin.z) posMin.z = p.z;
  }
  center.x = (posMax.x + posMin.x) / 2;
  center.y = (posMax.y + posMin.y) / 2;
  center.z = (posMax.z + posMin.z) / 2;
  return center;
}

// normalize based on the amplitude of the velocity
float normalizeVEL(Gesture& g) {
  float velMax = 0;
  for (unsigned int i = 1; i < g.data.size(); i++) {
    XYZ p = g.data.at(i).pos;
    XYZ v;
    v.x = p.x - g.data.at(i-1).pos.x;
    v.y = p.y - g.data.at(i-1).pos.y;
    v.z = p.z - g.data.at(i-1).pos.z;
    float vNorm;
    if (HTK_EXP & HTK_V2D) {
      vNorm = sqrt(v.x * v.x + v.y * v.y);  // only use x & y velocity
    } else {
      vNorm = sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
      if (vNorm > velMax) velMax = vNorm;
    }
  }
  return 2 / velMax;
}

// convert to GAcc and then normalize
float normalizeACC(Gesture& g) {
  float accMax = 0;
  for (unsigned int i = 0; i < g.data.size(); i++) {
    XYZ gacc = convertGACC(g.data.at(i).acc, g.data.at(i).ori);
    float aNorm = sqrt(gacc.x * gacc.x + gacc.y * gacc.y + gacc.z * gacc.z);
    if (aNorm > accMax) accMax = aNorm;
  }
  return 2 / accMax;
}

float normalizeW(Gesture& g) {
  float speedY = 0;
  float speedP = 0;
  float speedR = 0;
  for (unsigned int i = 0; i < g.data.size(); i++) {
    YPR w = g.data.at(i).w;
    if (abs(w.yaw)   > speedY) speedY = abs(w.yaw);
    if (abs(w.pitch) > speedP) speedP = abs(w.pitch);
    if (abs(w.roll)  > speedR) speedR = abs(w.roll);
  }
  float speed = max(max(speedY, speedP), speedR);
  return 10 / speed;
}

// q = w + ai + bj + ck
//   = cos(a/2) + sin(a/2)(xi + yj + zk)
float normalizeORI(Gesture& g) {
  ORI avgOriInv  = quatConj(averageOri(g));
  float angleMax = 0;
  for (unsigned int i = 1; i < g.data.size(); i++) {
    ORI q = quatMul(g.data.at(i).ori, avgOriInv);
    float angle = 2 * acos(q.w);  // in the range [0 2pi]: this angle is OK!
    if (angle > angleMax) angleMax = angle;
  }
  // if (angleMax > M_PI) printf("angleMax= %4.3f\n", angleMax);
  return 0.2 * M_PI/angleMax;  // stretch to pi/5 (for motion char/word)
}

// calculate the normalization scale
// scale the (max - min) to 1 (in radian)
float normalizePitch(vector<float> thetas) {
  float t_max = thetas.at(0);
  float t_min = t_max;
  for (unsigned int i = 1; i < thetas.size(); i++) {
    float t = thetas.at(i);
    if (t > t_max) t_max = t;
    if (t < t_min) t_min = t;
  }
  return 1 / (t_max - t_min);
}

// calculate the center of the bounding thetas
float centerPitch(vector<float> thetas) {
  float t_max = thetas.at(0);
  float t_min = t_max;
  for (unsigned int i = 1; i < thetas.size(); i++) {
    float t = thetas.at(i);
    if (t > t_max) t_max = t;
    if (t < t_min) t_min = t;
  }
  return (t_max + t_min) / 2;
}

// convert local acc to global acc w/o gravity
// p' = q p q^-1,  where p = (0, x, y, z)
XYZ convertGACC(XYZ acc, ORI q) {
  XYZ gacc;
  ORI quat, res;
  quat.w = 0;
  quat.x = acc.x;
  quat.y = acc.y;
  quat.z = acc.z;
  res = quatMul(quatMul(q, quat), quatConj(q));
  gacc.x = res.x;
  gacc.y = res.y - 1;
  gacc.z = res.z;
  return gacc;
}

// scale the "angle" of quaternion in axis-angle form
ORI quatScale(ORI q, float scale) {
  float angle = 2 * acos(q.w);
  // if (angle > M_PI) angle -= 2*M_PI; // range: [0 2pi] -> [-pi pi], ICASSP12
  if (abs(angle) < EPSILON) {  // q.w ~ 1, the axis may not be stable
    return q;
  } else {
    float den = sqrt(1 - q.w * q.w);
    float x = q.x / den;
    float y = q.y / den;
    float z = q.z / den;
    ORI res;
    float sHalfAngle = angle * scale * 0.5;
    res.w = cos(sHalfAngle);
    res.x = sin(sHalfAngle) * x;
    res.y = sin(sHalfAngle) * y;
    res.z = sin(sHalfAngle) * z;
    return quatNorm(res);
  }
}

// compute the approximate *average* of a set of orientation
ORI averageOri(Gesture& g) {
  ORI accOri;
  accOri.w = accOri.x = accOri.y = accOri.z = 0;
  for (unsigned int i = 0; i < g.data.size(); i++) {
    accOri.w += g.data.at(i).ori.w;
    accOri.x += g.data.at(i).ori.x;
    accOri.y += g.data.at(i).ori.y;
    accOri.z += g.data.at(i).ori.z;
  }
  accOri = quatNorm(accOri);
  return accOri;
}

// least squares fitting: y=ax + b
// x is the index (0 to N-1)
void leastSquaresFit(std::vector<float>& y, float& a, float& b) {
  float sum_x = 0;
  float sum_y = 0;
  float sum_x_sq = 0;
  float sum_xy = 0;
  float n = y.size();
  for (int i = 0; i < y.size(); i++) {
    sum_x += i;
    sum_y += y.at(i);
    sum_x_sq += i * i;
    sum_xy += i*y.at(i);
  }

  a = (n * sum_xy - sum_x * sum_y) / (n * sum_x_sq - sum_x * sum_x);
  b = (sum_y * sum_x_sq - sum_x * sum_xy) / (n * sum_x_sq - sum_x * sum_x);
  return;
}

Euler quatToEulerZXY(ORI q) {
  Euler e;
  e.psi   = atan2(2 * (q.w * q.z - q.x * q.y),
                  q.w * q.w - q.x * q.x + q.y * q.y - q.z * q.z);
  e.theta = asin(2 * (q.w * q.x + q.y * q.z));
  e.phi   = atan2(2 * (q.w * q.y - q.x * q.z),
                  q.w * q.w - q.x * q.x - q.y * q.y + q.z * q.z);
  return e;
}

ORI eulerZXYToQuat(Euler e) {
  ORI q;
  float c1 = cos(e.psi/2);
  float c2 = cos(e.theta/2);
  float c3 = cos(e.phi/2);
  float s1 = sin(e.psi/2);
  float s2 = sin(e.theta/2);
  float s3 = sin(e.phi/2);

  q.w = c1*c2*c3 - s1*s2*s3;
  q.x = c1*s2*c3 - s1*c2*s3;
  q.y = c1*c2*s3 + s1*s2*c3;
  q.z = c1*s2*s3 + s1*c2*c3;
  return q;
}


// The normalization scheme used in ICASSP12 and the journal
// "Feature processing and modeling for 6D motion gesture recognition"
int preprocessHTK_Legacy(Gesture& g, unsigned short nElem, float* buff) {
  float scale_acc = (HTK_ACC) ? normalizeACC(g) : 1;
  float scale_pos = (HTK_POS | HTK_P2D) ? normalizePOS(g) : 50;
  float scale_vel = (HTK_VEL | HTK_V2D) ? normalizeVEL(g) : 100;
  float scale_w   = (HTK_W)   ? normalizeW(g)   : 1;
  float scale_ori = (HTK_ORI) ? normalizeORI_Legacy(g) : 1;

  XYZ startPos = g.data.at(0).pos;
  XYZ prevPos  = startPos;
  ORI startOriInv = quatConj(g.data.at(0).ori);
  ORI prevOriInv = startOriInv;
  ORI avgOriInv  = quatConj(averageOri(g));
  for (unsigned int i = 0; i <g.data.size(); i++) {
    Sample s = g.data.at(i);
    XYZ acc, pos, vel;
    YPR w;
    ORI q;

    // Adjust with proper scale
    // TODO(mingyu): implement operator overloads for my structs
    acc = (HTK_ACC) ? convertGACC(g.data.at(i).acc, g.data.at(i).ori) : g.data.at(i).acc;
    acc.x *= scale_acc;
    acc.y *= scale_acc;
    acc.z *= scale_acc;

    // the version used for ICASSP12 & 6DMG journal
    pos.x = (s.pos.x - startPos.x) * scale_pos;
    pos.y = (s.pos.y - startPos.y) * scale_pos;
    pos.z = (s.pos.z - startPos.z) * scale_pos;
    vel.x = (s.pos.x - prevPos.x) * scale_vel;
    vel.y = (s.pos.y - prevPos.y) * scale_vel;
    vel.z = (s.pos.z - prevPos.z) * scale_vel;
    w.yaw   = s.w.yaw   * scale_w;
    w.pitch = s.w.pitch * scale_w;
    w.roll  = s.w.roll  * scale_w;
    q = s.ori;
    if (HTK_ORI) {
      // Ori normalization used in ICASSP12 & 6DMG journal (for motion gestures)
      q = quatNorm(quatMul(q, startOriInv));  // offset by the starting orientation
      q = quatScale(q, scale_ori);
      // printf("%5.4f, %5.4f, %5.4f, %5.4f\n", q.w, q.x, q.y, q.z);
    }

    prevPos = s.pos;
    prevOriInv = quatConj(s.ori);

    // store into buff
    float* ptr = buff + i*nElem;
    if (HTK_EXP & HTK_ACC) {
      memcpy(ptr, &acc, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_POS) {
      memcpy(ptr, &pos, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_VEL) {
      memcpy(ptr, &vel, sizeof(XYZ));
      ptr += 3;
    }
    if (HTK_EXP & HTK_W) {
      memcpy(ptr, &w, sizeof(YPR));
      ptr += 3;
    }
    if (HTK_EXP & HTK_ORI) {
      memcpy(ptr, &q, sizeof(ORI));
      ptr += 4;
    }
    if (HTK_EXP & HTK_P2D) {
      memcpy(ptr, &pos, 8);
      ptr += 2;
    }
    if (HTK_EXP & HTK_V2D) {
      memcpy(ptr, &vel, 8);
      ptr += 2;
    }
  }
  return 0;
}

// the normalization used for ICASSP12 the journal
// "Feature processing and modeling for 6D motion gesture recognition"
// !!! SLIGHTLY DIFFERENT !!!
float normalizeORI_Legacy(Gesture& g) {
  ORI startOriInv = quatConj(g.data.at(0).ori);
  float angleMax = 0;
  for (unsigned int i = 1; i < g.data.size(); i++) {
    ORI q = quatMul(g.data.at(i).ori, startOriInv);
    float angle = 2 * acos(q.w);  // in the range [0 2pi]: this angle is OK!
    /*
    // method in ICASSP12
    if (angle > M_PI){
    // we are only interested in the "abs" angle ([0 pi])
    // i.e. rotate 181 degree = rotate -179 degree
    //printf("at i=%d, angle=%4.3f\n", i,angle);
    angle = 2*M_PI - angle;
    }
    */
    // method in the journal
    if (angle > angleMax)
      angleMax = angle;
  }
  if (angleMax > M_PI) {
    printf("angleMax= %4.3f\n", angleMax);
  }
  // return M_PI / angleMax;  // stretch to pi (NOs)
  return 0.5 * M_PI / angleMax;  // stretch to pi/2 (NOs2)
}

}  // namespace Util
