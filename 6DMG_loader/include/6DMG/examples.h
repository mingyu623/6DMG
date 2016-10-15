#ifndef _6DMG_EXAMPLES_H_
#define _6DMG_EXAMPLES_H_

#include "GestureDef.h"
#include "Database.h"
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
void word_example3(Database* pDatabase, string tester);
void word_example4(Database* pDatabase, string tester, string word, int trial);
void word_example5(Database* pDatabase, string tester);

#endif  // _6DMG_EXAMPLES_H_
