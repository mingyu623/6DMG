/*******************************************************************
 * Copyright (C) 2016 Mingyu Chen (mingyu623@gmail.com)
 * You may use, distribute and modify this code under the terms of
 * the BSD license
 *
 * This is a re-write of my work 6DMG_loader_2.0 that can be
 * downloaded at http://www2.ece.gatech.edu/6DMG/Download.html
 *******************************************************************/
#ifndef _6DMG_EXAMPLES_H_
#define _6DMG_EXAMPLES_H_

#include <6DMG/GestureDef.h>
#include <6DMG/Database.h>

using namespace GestureDef;

vector<TesterInfo> gest_example1(Database* pDatabase);
Gesture	gest_example2(Database* pDatabase, int tester_idx, int gesture_enum, int trial);
void gest_example3(Database* pDatabase, int tester_idx, int gesture_enum, int trial);
void gest_example4(Database* pDatabase);
void gest_example5(Database* pDatabase, int tester_idx, int gesture_enum, int trial);
void gest_example6(Database* pDatabase);
void gest_example7(Database* pDatabase);
void char_example1(Database* pDatabase);
void char_example2(Database* pDatabase);
void char_example3(Database* pDatabase, int tester_idx, int gesture_enum, int trial);
void word_example1(Database* pDatabase);
void word_example2(Database* pDatabase);
void word_example3(Database* pDatabase, std::string tester);
void word_example4(Database* pDatabase, std::string tester, std::string word, int trial);
void word_example5(Database* pDatabase, std::string tester);

#endif  // _6DMG_EXAMPLES_H_
