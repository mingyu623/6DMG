/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com)
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/
//
// 6DMG_loader_2.0
// Mingyu Chen @ Oct. 2. 2012
// Use "Config.h" to configure the running examples
// & the EXPORT configuration
// ----------------------------------------------------

#include <iostream>
#include <stdio.h>
#include <stdlib.h> // For EXIT_FAILURE, EXIT_SUCCESS
#include <vector>   // For STL
#include "GestureDef.h"
#include "Database.h"
#include "util.h"
#include "examples.h"
#include "Config.h"

using namespace std;
using namespace GestureDef;

int main() {
  //==================================================
  // MOTION GEST
  //==================================================
  // initialize the database and connect to SQLite
  Database* pDatabaseGest = new Database();
  if (pDatabaseGest->Open(0)) {
    // Example 1: load/print all testers
    vector<TesterInfo> testersList = gest_example1(pDatabaseGest);

    // Example 2: load a tester's ith trial of *gesture_name*, and print the timestamp + pos
    // Gesture g2 = gest_example2(pDatabaseGest, 2, V_SHAPE, 1);

#ifdef EXPORT_GEST_MAT
    // Example 3: MATLAB exporter for one specific motion gest
    gest_example3(pDatabaseGest, 2, V_SHAPE, 1);

    // Example 4: MATLAB exporter for all motion gests
    gest_example4(pDatabaseGest);
#endif

#ifdef EXPORT_GEST_HTK
    // Example 5: HTK exporter for one specific motion gest
    gest_example5(pDatabaseGest, 2, V_SHAPE, 1);

    // Example 6: HTK exporter for all
    gest_example6(pDatabaseGest);
#endif

#ifdef GEST_NORM_STAT
    // Example 7: Get a summary of the scaling factors
    gest_example7(pDatabaseGest);
#endif
  }

  //==================================================
  // MOTION CHAR
  //==================================================
  // initialize the database and connect to SQLite
  Database* pDatabaseChar = new Database();
  if (pDatabaseChar->Open(1)) {
#ifdef EXPORT_CHAR_HTK
    // Example 1: HTK exporter for motion char
    char_example1(pDatabaseChar);

    // Example 3: HTK exporter for one specific motion char trial
    // char_example3(pDatabaseChar, 16, UPPER_A , 1);
#endif

#ifdef EXPORT_CHAR_MAT
    // Example 2: MATLAB exporter for motion character
    char_example2(pDatabaseChar);
#endif
  }

  //==================================================
  // MOTION WORD
  //==================================================
  // initialize the database and connect to SQLite
  Database* pDatabaseWord = new Database();
  if (pDatabaseWord->Open(2)) {
#ifdef EXPORT_WORD_HTK
    // Example 1: HTK exporter for motion word
    word_example1(pDatabaseWord);

    // Example 4: HTK exporter for motion word from a specific tester
    // word_example4(pDatabaseWord, "M2", "ABC", 1);

    // Example 5: HTK exporter for motion word from a specific tester
    // word_example5(pDatabaseWord, "M2");
#endif

#ifdef EXPORT_WORD_MAT
    // Example 2: MATLAB exporter for motion word
    word_example2(pDatabaseWord);

    // Example 3: MATLAB exporter for motion word from a specific tester
    word_example3(pDatabaseWord, "M1");
#endif
  }

  cout << "Press enter to continue.";
  char ch;
  cin.get(ch);
  return 0;
}
