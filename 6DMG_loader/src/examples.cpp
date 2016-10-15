#include <iostream>
#include <stdio.h>
#include "examples.h"
#include "util.h"
using namespace std;

//==================================================
// MOTION GEST
//==================================================
// Example 1: load all testers
vector<TesterInfo> gest_example1(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<testersList.size(); i++){
		TesterInfo tester = testersList.at(i);
		string hand = tester.rightHand ? "right-handed" : "left -handed";
		cout << tester.name << " is " << hand << endl;
	}
	return testersList;
}		


// Example 2: load a tester's ith trial of *gesture_name*, and print the timestamp + pos
Gesture gest_example2(Database* pDatabase, int tester_idx, int gesture_enum, int trial){
	Gesture g;
	TesterInfo tester = pDatabase->LoadTesters().at(tester_idx);
	if (pDatabase->LoadOneGesture(getGestureName(gesture_enum), tester.name, trial, g)){
		cout << g.name << " by " << g.tester << ": trial No. " << g.trial << endl;
		printf("time(ms) pos.x\t pos.y\ tpos.z\n");
		for (int i=0; i<g.data.size(); i++){			
			Sample s = g.data.at(i);
			printf("%6.2f\t %4.3f %4.3f %4.3f\n", s.timestamp, s.pos.x, s.pos.y, s.pos.z);							
		}		
	}	
	return g;
}


// Example 3: MATLAB exporter for one specific motion gest
void gest_example3(Database* pDatabase, int tester_idx, int gesture_enum, int trial){
	Gesture g;
	TesterInfo tester = pDatabase->LoadTesters().at(tester_idx);
	if (pDatabase->LoadOneGesture(getGestureName(gesture_enum), tester.name, trial, g)){
		char filename[20];
		sprintf(filename, "g%02d_%s_t%02d.mat", gesture_enum, tester.name.c_str(), trial);
		GestToMat(filename, g);
	}
}


// Example 4: MATLAB exporter for all motion gests	
void gest_example4(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_GESTURES; i++){			// gesture idx
		for (int j=0; j<testersList.size(); j++){	// tester  idx		
			string name = getGestureName(i);
			string tester = testersList.at(j).name;
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){					
					char filename[30];
					if (testersList.at(j).rightHand)
						sprintf(filename, "../matR/g%02d_%s_t%02d.mat", i, tester.c_str(), k);
					else
						sprintf(filename, "../matL/g%02d_%s_t%02d.mat", i, tester.c_str(), k);
					GestToMat(filename, gest);
				}
			}
		}	
	}
}


// Example 5: HTK exporter for motion gest
void gest_example5(Database* pDatabase, int tester_idx, int gesture_enum, int trial){
	Gesture g;
	TesterInfo tester = pDatabase->LoadTesters().at(tester_idx);
	if (pDatabase->LoadOneGesture(getGestureName(gesture_enum), tester.name, trial, g)){		
		char filename[20];
		sprintf(filename, "g%02d_%s_t%02d.htk", gesture_enum, tester.name.c_str(), trial);
		GestToHTK(filename, g);
	}
}

// Example 6: HTK exporter for all
void gest_example6(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_GESTURES; i++){			// gesture idx
		for (int j=0; j<testersList.size(); j++){	// tester  idx		
			string name = getGestureName(i);
			string tester = testersList.at(j).name;
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){
					char filename[30];
					sprintf(filename, "../htk/g%02d_%s_t%02d.htk", i, tester.c_str(), k);
					GestToHTK(filename, gest);
				}
			}
		}
	}
}

// Example 7: Get a summary of the scaling factors
void gest_example7(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_GESTURES; i++){			// gesture idx			
		for (int j=0; j<testersList.size(); j++){	// tester idx
			float min_scale_acc = 100000;
			float min_scale_pos = 100000;
			float min_scale_vel = 100000;
			float min_scale_w   = 100000;
			float min_scale_ori = 100000;
			float min_scale_dori= 100000;
			float max_scale_acc = 0;
			float max_scale_pos = 0;
			float max_scale_vel = 0;
			float max_scale_w   = 0;
			float max_scale_ori = 0;

			string name = getGestureName(i);
			string tester = testersList.at(j).name;
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++)
			{
				Gesture g;
				if (pDatabase->LoadOneGesture(name, tester, k, g)){
					float scale_acc = normalizeACC(g);
					float scale_pos = normalizePOS(g);
					float scale_vel = normalizeVEL(g);
					float scale_w   = normalizeW(g);
					float scale_ori = normalizeORI(g);					
					if (scale_acc < min_scale_acc) min_scale_acc = scale_acc;
					if (scale_pos < min_scale_pos) min_scale_pos = scale_pos;
					if (scale_vel < min_scale_vel) min_scale_vel = scale_vel;
					if (scale_w   < min_scale_w  ) min_scale_w   = scale_w;
					if (scale_ori < min_scale_ori) min_scale_ori = scale_ori;			
	
					if (scale_acc > max_scale_acc) max_scale_acc = scale_acc;
					if (scale_pos > max_scale_pos) max_scale_pos = scale_pos;
					if (scale_vel > max_scale_vel) max_scale_vel = scale_vel;
					if (scale_w   > max_scale_w  ) max_scale_w   = scale_w;
					if (scale_ori > max_scale_ori) max_scale_ori = scale_ori;					
				}
			}
			printf("Gesture: %s by %s\n", getGestureName(i).c_str(), tester.c_str());
			printf("scale_acc = [ %6.2f %6.2f ] => ratio= %6.2f\n", min_scale_acc, max_scale_acc, max_scale_acc/min_scale_acc);
			printf("scale_pos = [ %6.2f %6.2f ] => ratio= %6.2f\n", min_scale_pos, max_scale_pos, max_scale_pos/min_scale_pos);
			printf("scale_vel = [ %6.2f %6.2f ] => ratio= %6.2f\n", min_scale_vel, max_scale_vel, max_scale_vel/min_scale_vel);
			printf("scale_w   = [ %6.2f %6.2f ] => ratio= %6.2f\n", min_scale_w,   max_scale_w,   max_scale_w/min_scale_w);
			printf("scale_ori = [ %6.2f %6.2f ] => ratio= %6.2f\n", min_scale_ori, max_scale_ori, max_scale_ori/min_scale_ori);			
		}			
	}
}


//==================================================
// MOTION CHAR
//==================================================
// Example 1: HTK exporter for motion char
void char_example1(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_CHARS; i++){			// char idx
		for (int j=0; j<testersList.size(); j++){	// tester  idx		
			string name = getCharName(i);
			string tester = testersList.at(j).name;
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){
					char filename[40];
					sprintf(filename, "../htk/%s_%s_t%02d.htk", name.c_str(), tester.c_str(), k);
					GestToHTK(filename, gest);
				}
			}
		}
	}
}

// Example 2: MATLAB exporter for motion character
void char_example2(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_CHARS; i++){			// char idx
		for (int j=0; j<testersList.size(); j++){	// tester  idx		
			string name = getCharName(i);
			string tester = testersList.at(j).name;
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){
					char filename[30];
					if (testersList.at(j).rightHand)
						sprintf(filename, "../matR/%s_%s_t%02d.mat", name.c_str(), tester.c_str(), k);
					else
						sprintf(filename, "../matL/%s_%s_t%02d.mat", name.c_str(), tester.c_str(), k);
					GestToMat(filename, gest);
				}
			}
		}
	}
}

// Example 3: HTK exporter for one specific motion char
void char_example3(Database* pDatabase, int tester_idx, int char_enum, int trial){
	Gesture g;
	TesterInfo tester = pDatabase->LoadTesters().at(tester_idx);
	string name = getCharName(char_enum);
	if (pDatabase->LoadOneGesture(name, tester.name, trial, g)){
		char filename[20];		
		sprintf(filename, "%s_%s_t%02d.htk", name.c_str(), tester.name.c_str(), trial);
		GestToHTK(filename, g);
	}
}


//==================================================
// MOTION WORD
//==================================================
// Example 1: HTK exporter for motion word
void word_example1(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_WORDS; i++){		// word idx	
		for (int j=0; j<testersList.size(); j++){	// tester idx
			string name = getWordName(i);
			string tester = testersList.at(j).name;			
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){
					char filename[40];
					sprintf(filename, "../htk/%s_%s_t%02d.htk", name.c_str(), tester.c_str(), k);
					GestToHTK(filename, gest);
				}
			}
		}
	}
}


// Example 2: MATLAB exporter for motion word
void word_example2(Database* pDatabase){
	vector<TesterInfo> testersList = pDatabase->LoadTesters();
	for (int i=0; i<TOTAL_WORDS; i++){		// word idx
		for (int j=0; j<testersList.size(); j++){	// tester idx
			string name = getWordName(i);
			string tester = testersList.at(j).name;	
			int trialNum = pDatabase->GetCurrentTrial(name, tester);
			for (int k=1; k<trialNum; k++){
				Gesture gest;				
				if (pDatabase->LoadOneGesture(name, tester, k, gest)){
					char filename[40];
					if (testersList.at(j).rightHand)
						sprintf(filename, "../matR/%s_%s_t%02d.mat", name.c_str(), tester.c_str(), k);
					else
						sprintf(filename, "../matL/%s_%s_t%02d.mat", name.c_str(), tester.c_str(), k);
					GestToMat(filename, gest);
				}
			}
		}
	}
}

// Example 3: MATLAB exporter for motion word from a specific tester
void word_example3(Database* pDatabase, string tester){
	for (int i=0; i<TOTAL_WORDS; i++){	// word idx
		string name = getWordName(i);
		int trialNum = pDatabase->GetCurrentTrial(name, tester);
		for (int k=1; k<trialNum; k++){
			Gesture gest;
			if (pDatabase->LoadOneGesture(name, tester, k, gest)){
				char filename[40];			
				sprintf(filename, "../matR/%s_%s_t%02d.mat", name.c_str(), tester.c_str(), k);				
				GestToMat(filename, gest);
			}
		}
	}
}

// Example 4: HTK exporter for a motion word from a specific trial and tester
void word_example4(Database* pDatabase, string tester, string word, int trial){
	Gesture gest;
	if (pDatabase->LoadOneGesture(word, tester, trial, gest)){
		char filename[40];
		sprintf(filename, "../htk/%s_%s_t%02d.htk", word.c_str(), tester.c_str(), trial);
		GestToHTK(filename, gest);
	}
}

// Example 5: HTK exporter for motion words from a specific tester
void word_example5(Database* pDatabase, string tester){
	for (int i=0; i<TOTAL_WORDS; i++){
		string name = getWordName(i);
		int trialNum = pDatabase->GetCurrentTrial(name, tester);
		for (int k=1; k<trialNum; k++){
			Gesture gest;
			if (pDatabase->LoadOneGesture(name, tester, k, gest)){
				char filename[40];
				sprintf(filename, "../htk/%s_%s_t%02d.htk", name.c_str(), tester.c_str(), k);
				GestToHTK(filename, gest);
			}
		}
	}
}