#ifndef _6DMG_DATABASE_H_
#define _6DMG_DATABASE_H_

#include "sqlite3.h"
#include "GestureDef.h"

using namespace std;

class Database{
 public:
  Database();
  ~Database();
  bool Open(int flag);
  void Close(void);

  // main functions
  bool SaveGesture(const GestureDef::Gesture& gesture);
  bool LoadOneGesture(const string name, const string tester, int trial,
                      GestureDef::Gesture& gesture);
  bool DeleteOneGesture(const string name, const string tester, int trial);
  void LoadGestures(const string name);
  std::vector<GestureDef::TesterInfo> LoadTesters(void);
  int GetCurrentTrial(const string name, const string tester);

 private:
  // sqlite3 database
  sqlite3 *db;

  // whether database is opened
  bool dbOpened;
  // result code of sqlite3 functions
  int rc;
  // error message of sqlite3 functions
  char *zErrMsg;

  // statements
  sqlite3_stmt* loadOneGestureStmt;
  sqlite3_stmt* loadGesturesStmt;
  sqlite3_stmt* getCurrentTrialStmt;
  sqlite3_stmt* deleteOneGestureStmt;
  sqlite3_stmt* loadTestersStmt;
};

#endif  // _6DMG_DATABASE_H_
