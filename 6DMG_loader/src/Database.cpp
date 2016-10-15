#include "Database.h"
#include <iostream>
using namespace GestureDef;
using namespace std;

Database::Database()
{
	dbOpened = false;	

	// stmt	
	loadOneGestureStmt	= 0;
	loadGesturesStmt	= 0;
	deleteOneGestureStmt= 0;
	getCurrentTrialStmt = 0;	
	loadTestersStmt     = 0;
} 

Database::~Database()
{	
	if (dbOpened){
		sqlite3_close(db);
	}
}

bool Database::Open(int flag)
{
	switch (flag)
	{	
	case 1:
		rc = sqlite3_open_v2("MotionChar.db", &db, SQLITE_OPEN_READWRITE, 0); break;
	case 2:
		rc = sqlite3_open_v2("MotionWord.db", &db, SQLITE_OPEN_READWRITE, 0); break;
	default:
		rc = sqlite3_open_v2("MotionGesture.db", &db, SQLITE_OPEN_READWRITE, 0); break;
	}	

    if(rc){
		cout << "Cannot open database: " << sqlite3_errmsg(db) << endl;
        sqlite3_close(db);
    }
	else{
		//cout << "Open database...\n";		
        dbOpened = true;
		/*
		// Mingyu: we don't create new table here!
        rc = sqlite3_exec(db,
            "CREATE TABLE IF NOT EXISTS GestureTable(          "
            "   name   TEXT    NOT NULL,                       "
			"   tester TEXT    NOT NULL,                       "
			"   trial     INTEGER NOT NULL,                    "
            "   length    INTEGER NOT NULL,                    "
			"   righthand INTEGER NOT NULL,                    "
            "   data   BLOB    NOT NULL,                       "
			"   noise  BLOB    NOT NULL,                       "
			"   bias   BLOB    NOT NULL,                       "
			"   PRIMARY KEY (name, tester, trial)              "
            ");                                                ",
            0, 0, &zErrMsg);
		if(rc!=SQLITE_OK) 
			cout << "Error when CREATE TABLE " << string(zErrMsg) << endl;	
		*/

		string loadOneGestureSQL = "SELECT length, data, noise, bias, righthand FROM GestureTable "
			"WHERE name=?1 AND tester=?2 AND trial=?3 LIMIT 1;";
		rc = sqlite3_prepare_v2(db,loadOneGestureSQL.c_str(),loadOneGestureSQL.size()+1,&loadOneGestureStmt,0);
		if(rc!=SQLITE_OK || loadOneGestureStmt==0) 
			cout << "Error when preparing loadOneGestureSQL\n";			

		string getCurrentTrialSQL = "SELECT count(*) FROM GestureTable WHERE name=?1 AND tester=?2;";
		rc = sqlite3_prepare_v2(db,getCurrentTrialSQL.c_str(),getCurrentTrialSQL.size()+1,&getCurrentTrialStmt,0);
		if(rc!=SQLITE_OK || getCurrentTrialStmt==0) 
			cout << "Error when prepraring getCurrentTrialSQL\n";

		string deleteOneGestureSQL = "DELETE FROM GestureTable WHERE name=?1 AND tester=?2 AND trial=?3;";
		rc = sqlite3_prepare_v2(db,deleteOneGestureSQL.c_str(),deleteOneGestureSQL.size()+1,&deleteOneGestureStmt,0);
		if(rc!=SQLITE_OK || deleteOneGestureStmt==0) 			
			cout << "Error when preparing deleteOneGestureSQL\n";

		string loadTestersSQL = "SELECT DISTINCT tester, righthand FROM GestureTable";
		rc = sqlite3_prepare_v2(db,loadTestersSQL.c_str(), loadTestersSQL.size()+1,&loadTestersStmt,0);
		if(rc!=SQLITE_OK || loadTestersStmt==0) 			
			cout << "Error when preparing loadTestersSQL\n";
	}
	return dbOpened;
}

void Database::Close()
{
	if (dbOpened){		
		cout << "Close Database with Close()\n";
		sqlite3_close(db);
		dbOpened = false;
	}
}


// main functions
bool Database::LoadOneGesture(const string name, const string tester, int trial, Gesture& gesture)
{	
	string msg;
	bool ok = true;	

	// binding values
	// SQL:loadOneGestureSQL = "SELECT length, data, noise, bias, righthand FROM GestureTable "
	//			"WHERE name=?1 AND tester=?2 AND trial=?3 LIMIT 1";
	rc = sqlite3_bind_text(loadOneGestureStmt,1,name.c_str(),-1,SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db));	ok = false;
		cout << "Error when binding name in LoadOneGesture() " << msg << endl;
	}

	rc = sqlite3_bind_text(loadOneGestureStmt,2,tester.c_str(),tester.size(),SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when binding tester in LoadOneGesture() " << msg << endl;
	}

	rc = sqlite3_bind_int(loadOneGestureStmt,3,trial);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when binding trial in LoadOneGesture() " << msg << endl;
	}

	// evaluation
	const GestureDef::YPR* pYpr = 0;
	const GestureDef::Sample* pSample = 0;
	rc = sqlite3_step(loadOneGestureStmt);        
    while(rc==SQLITE_ROW){
		// Mingyu: this loop should only be executed once!
		gesture.length = sqlite3_column_int(loadOneGestureStmt, 0);		
		pSample = (const GestureDef::Sample*)sqlite3_column_blob(loadOneGestureStmt, 1); // data
		gesture.data.assign(pSample, pSample + gesture.length);
		pYpr = (const GestureDef::YPR*)sqlite3_column_blob(loadOneGestureStmt, 2); // noise
		gesture.noise = *pYpr;		
		pYpr = (const GestureDef::YPR*)sqlite3_column_blob(loadOneGestureStmt, 3); // bias
		gesture.bias = *pYpr;
		gesture.rightHand = sqlite3_column_int(loadOneGestureStmt, 4); // rightHand
        rc = sqlite3_step(loadOneGestureStmt);
    }
	if(rc!=SQLITE_DONE){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when reading data in LoadOneGesture() " << msg << endl;
	}

	// append other fields of this gesture
	gesture.name   = name;
	gesture.tester = tester;
	gesture.trial  = trial;

	// reset
    sqlite3_reset(loadOneGestureStmt);
    sqlite3_clear_bindings(loadOneGestureStmt);
	return ok;
}

int Database::GetCurrentTrial(const string name, const string tester)
{
	string msg;

	// SQL: "SELECT count(*) FROM GestureTable WHERE name=?1 AND tester=?2;"
	rc = sqlite3_bind_text(getCurrentTrialStmt,1,name.c_str(),-1,SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db));
		cout << "Error when binding name in GetCurrentTrial() " << msg << endl;
	}

	rc = sqlite3_bind_text(getCurrentTrialStmt,2,tester.c_str(),tester.size(),SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db));
		cout << "Error when binding tester in GetCurrentTrial() " << msg << endl;
	}

	// evaluation
	int storedTrials = -1;	
	rc = sqlite3_step(getCurrentTrialStmt);
    while(rc==SQLITE_ROW){
		// Mingyu: this loop should only be executed once!
		storedTrials = sqlite3_column_int(getCurrentTrialStmt, 0);		
        rc = sqlite3_step(getCurrentTrialStmt);
    }
	if(rc!=SQLITE_DONE){
		msg.assign(sqlite3_errmsg(db));
		cout << "Error when reading data in GetCurrentTrial() " << msg << endl;
	}

	// reset
    sqlite3_reset(getCurrentTrialStmt);
    sqlite3_clear_bindings(getCurrentTrialStmt);

	return storedTrials+1;
}

bool Database::DeleteOneGesture(const string name, const string tester, int trial)
{	
	string msg;
	bool ok = true;

	// binding values
	// SQL:deleteOneGestureSQL = "DELETE FROM GestureTable WHERE name=?1 AND tester=?2 AND trial=?3;";"	
	rc = sqlite3_bind_text(deleteOneGestureStmt,1,name.c_str(),-1,SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db));	ok = false;
		cout << "Error when binding name in DeleteOneGesture() " << msg << endl;
	}

	rc = sqlite3_bind_text(deleteOneGestureStmt,2,tester.c_str(),tester.size(),SQLITE_TRANSIENT);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when binding tester in DeleteOneGesture() " << msg << endl;
	}

	rc = sqlite3_bind_int(deleteOneGestureStmt,3,trial);
	if(rc!=SQLITE_OK){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when binding trial in DeleteOneGesture() " << msg << endl;
	}

	 //evaluating
    rc = sqlite3_step(deleteOneGestureStmt);
	if(rc!=SQLITE_DONE){
		msg.assign(sqlite3_errmsg(db));
		cout << "Error when evaluating in DeleteOneGesture() " << msg << endl;
	}			

    //reset statement for next evaluation
    sqlite3_reset(deleteOneGestureStmt);
    sqlite3_clear_bindings(deleteOneGestureStmt);
	if (ok){
		cout << "DeleteOneGesture() success: " << name << " by " << tester << " no. " << trial << " is deleted\n";		
	}
	return ok;
}

std::vector<TesterInfo> Database::LoadTesters()
{	
	string msg;
	std::vector<TesterInfo> testers;
	bool ok = true;
	
	// SQL:loadOneGestureSQL = "SELECT DISTINCT tester FROM GestureTable"	
	
	// evaluation
	rc = sqlite3_step(loadTestersStmt);        
    while(rc==SQLITE_ROW){		
		TesterInfo tester;
		tester.name.assign((const char*)sqlite3_column_text(loadTestersStmt,0));
		tester.rightHand = sqlite3_column_int(loadTestersStmt,1);
		testers.push_back(tester);	
        rc = sqlite3_step(loadTestersStmt);
    }
	if(rc!=SQLITE_DONE){
		msg.assign(sqlite3_errmsg(db)); ok = false;
		cout << "Error when reading data in loadTesters() " << msg << endl;
	}

	// reset
    sqlite3_reset(loadTestersStmt);    
	return testers;
}