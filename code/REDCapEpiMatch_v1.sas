/*
Author: Dano Aasland
Date: 2021-02-01
Version: 1.1.0
Last modified by: Dano Aasland
Last modified time: 2021-02-21 03:06:59

Copyright 2021 Dano Aasland

Licensed under the MIT License ("the License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://opensource.org/licenses/MIT

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

***********CHANGE SUMMARY*************

 - CONVERTED KEY MATCH CODE TO MACRO 'KEYMATCHER'
 - ADDED DEMO OUTPUT OF EACH KEY VALUE CREATED

************CODE SUMMARY**************

CREATES MULTIPLE VARIABLE "KEYS", THAT ARE GENERATED FROM 
FIRST NAME, LAST NAME, AND DATE OF BIRTH (DOB). 
ACCOUNTS FOR ERRORS AT TIME OF DATE ENTRY AND ALLOWS USER 
TO MERGE MULTIPLE DATA SOURCES WITH REDCAP PROJECT DATA. 
SEE EXAMPLE BELOW FOR VISUALIZATION OF EACH KEY GENERATION.

EXAMPLE:

CORRECT FULL NAME AND DOB - ANAKIN SKYWALKER 05/25/77

---FIRST NAME------------------LAST NAME--------------------DOB (MMDDYYYY)----
A  N  A  K  I  N		S  K  Y  W  A  L  K  E  R		0  5  2  5  1  9  7  7
1  2  3  4  5  6		1  2  3  4  5  6  7  8  9		1  2  3  4  5  6  7  8

[CORRECT FULL LAST + FIRST TRUNCATE 6 + DOB]
KEY01 - SKYWALKERANAKIN19770525

[DROP 2ND LETTER OF LAST NAME TRUNCATE 8, DROP 1ST LETTER OF FIRST NAME TRUNCATE 8, FULL DOB]
KEY02 - SYWALKERANAKIN19770525

[DROP 1ST LETTER OF LAST NAME TRUNCATE 6, FIRST NAME TRUNCATE 6, FULL DOB]
KEY03 - KYWALKANAKIN19770525

[FULL LAST NAME, FIRST NAME TRUNCATE 3, FULL DOB]
KEY04 - SKYWALKERANA19770525

[DROP 1ST TWO TRUNCATE 3 LAST NAME, TRUNCATE 3 FIRST NAME, FULL DOB]
KEY05 - YWAANA19770525

[TRUNCATE 4 LAST NAME, TRUNCATE 4 FIRST NAME, FULL DOB]
KEY06 - SKYWANAK19770525

[DROP 2ND LETTER LAST NAME TRUNCATE 8, DROP 1ST TRUNCATE 8, DOB DROP LAST TWO DIGITS ('77' OF '1977')]
KEY07 - SYWALKERNAKIN190525

[DROP 2ND LETTER LAST NAME TRUNCATE 8, DROP 1ST TRUNCATE 8, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')]
KEY08 - SYWALKERNAKIN770525

[LAST NAME TRUNCATE 5, FIRST NAME TRUNCATE 4, DOB DROP LAST TWO DIGITS ('77' OF '1977')]
KEY09 - SKYWAANAK190525

[SWITCH LAST WITH FIRST, FIRST DROP 2ND LETTER TRUNCATE 8, DROP 1ST LETTER TRUNCATE 8, DOB DROP LAST TWO DIGITS ('77' OF '1977')]
KEY10 - AAKINKYWALKER190525

[SWITCH LAST WITH FIRST, FIRST DROP 2ND LETTER TRUNCATE 8, DROP 1ST LETTER TRUNCATE 8, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')]
KEY11 - AAKINKYWALKER770525

[SWITCH LAST WITH FIRST, FIRST NAME TRUNCATE 5, LAST NAME TRUNCATE 4, DOB DROP LAST TWO DIGITS ('77' OF '1977')]
KEY12 - ANAKISKYW190525

[SWITCH LAST WITH FIRST, FIRST NAME TRUNCATE 5, LAST NAME TRUNCATE 4, DOB DROP FIRST TWO YEAR DIGITS ('19' OF '1977')]
KEY13 - ANAKISKYW770525
**************************************/

*SET TIMESTAMP TO MMDDYYYY IF DATASET LABELS TERMINATE WITH DATE;

%let timeStamp = 00000000;

************************************************************* 
FUNCTION - CONVERTS ALL CHAR TYPES TO UPPERCASE
				TO CALL FUNCTION
	--> %UPCASE_ALL(LibName, DatasetName) <--

*************************************************************;

%MACRO UPCASE_ALL(LIB, DS);
	PROC SQL NOPRINT;
		SELECT STRIP(NAME)||" = UPCASE( "||STRIP(NAME) || ");" INTO :CODE_STR 
			SEPARATED BY ' ' FROM DICTIONARY.COLUMNS WHERE LIBNAME=UPCASE("&LIB") AND 
			MEMNAME=UPCASE("&DS") AND TYPE='char';
	QUIT;

	DATA &DS;
		SET  &DS;
		&CODE_STR;
	RUN;

%MEND;

*LOAD REDCAP DATA FILE, XLSX FORMAT, ADD SHEET TITLE WITH DATASET AS WELL;

PROC IMPORT OUT=REDCapRawData 
	DATAFILE="/PATH/TO/FILE/HERE/DatasetLabel&timeStamp..xlsx" 
	DBMS=XLSX REPLACE;
	GETNAMES=YES;
	Sheet="SHEET NAME HERE"; *adds timestamp to sheet name, ex: dataSheet11112021;
RUN;

*LOAD DATA TO MERGE FILE, XLSX FORMAT, ADD SHEET TITLE WITH DATASET AS WELL;

PROC IMPORT OUT=MergeRawData&timeStamp.
	DATAFILE="/PATH/TO/FILE/HERE/DatasetLabel&timeStamp..xlsx" 
	DBMS=XLSX REPLACE;
	GETNAMES=YES;
	Sheet="SHEET NAME HERE &timeStamp."; *adds timestamp to sheet name, ex: dataSheet11112021;
RUN;

* UPCASE ALL VARIABLES IN DATASETS;

%UPCASE_ALL(YourLibraryNameHere, REDCapRawData);
%UPCASE_ALL(YourLibraryNameHere, MergeRawData&timeStamp.);

*CREATE DATASET WITH PATIENT ID KEYS FROM REDCAP DATASET;

DATA YourLibraryNameHere.REDCapKey;
	SET YourLibraryNameHere.REDCapRawData;
	
	*CREATES A BOOL VAR FOR MATCH USE;
	
	REDCapKeyEngr = 1;
	
	*PREPROCESS VARIABLES FOR ID KEY GENERATION;
	
	*DATA CLEANSE AND FORMATIING OF LAST NAME, REMOVES WHITE SPACE, 
	UPCASE ALL CHARS, DROP HYPHENS, PERIODS, COMMAS;
	
	LENGTH newNameLast $15;
	newNameLast=SCAN(COMPRESS(LEFT(Last_Name),"*-.,' "),1);
	
	LENGTH newNameFirst $15;
	newNameFirst=SCAN(COMPRESS(LEFT(First_Name),"*-.,' "),1);
	
	*ENGINEER NEW VARIABLE, DOB IN YYMMDD FORMAT;
	
	newDOB=PUT(date_of_birth, yymmddn8.);
	
	*ENGINEER TEMP VARIABLES FOR REUSE IN KEYS;
	
	tmpLastName = CATX(' ', SUBSTR(newNameLast, 1, 1), SUBSTR(newNameLast, 3, 8));
	tmpFirstName = CATX(' ', SUBSTR(newNameFirst, 1, 1), SUBSTR(newNameFirst, 3, 8));
	tmpNewDOB01 = CATX('', SUBSTR(newDOB, 5, 2), SUBSTR(newDOB, 1, 4));
	tmpNewDOB02 = CATX('', SUBSTR(newDOB, 7, 2), SUBSTR(newDOB, 1, 4));
	
	*ENGINEER ID KEYS;
	
	Key01 = CATX(' ', newNameLast, SUBSTR(newFirstName,1,6), newDOB);
	Key02 = CATX(' ', tmpLastName, SUBSTR(newFirstName, 2, 8), newDOB);
	Key03 = CATX(' ', SUBSTR(newNameLast, 2, 6), SUBSTR(newNameFirst, 1, 6), newDOB);
	Key04 = CATX(' ', newNameLast, SUBSTR(newNameFirst, 1, 3), newDOB);
	Key05 = CATX(' ', SUBSTR(newNameLast, 3, 3), SUBSTR(newNameFirst, 1, 3), newDOB);
	Key06 = CATX(' ', SUBSTR(newNameLast, 1, 4), SUBSTR(newNameFirst, 1, 4), newDOB);
	Key07 = CATX(' ', tmpLastName, SUBSTR(newNameFirst, 2, 8), tmpNewDOB01);
	Key08 = CATX(' ', tmpLastName, SUBSTR(newNameFirst, 2, 8), tmpNewDOB02);
	Key09 = CATX(' ', SUBSTR(newNameLast, 1, 5), SUBSTR(newNameFirst, 1, 4), tmpNewDOB01);
	Key10 = CATX(' ', tmpFirstName, SUBSTR(newNameLast, 2, 8), tmpNewDOB01);
	Key11 = CATX(' ', tmpFirstName, SUBSTR(newNameLast, 2, 8), tmpNewDOB02);
	Key12 = CATX(' ', SUBSTR(newNameFirst, 1, 5), SUBSTR(newNameLast, 1, 4), tmpNewDOB01);
	Key13 = CATX(' ', SUBSTR(newNameFirst, 1, 5), SUBSTR(newNameLast, 1, 4), tmpNewDOB02);
	
	*Remove temp variables from dataset;
	
	DROP tmpLastName tmpFirstName tmpNewDOB01 tmpNewDOB02;

RUN;

*CREATE PATIENT ID KEYS FROM TO MERGE DATASET AND ADD TO DATASET;

DATA YourLibraryNameHere.MergeDataCln&timeStamp.;
	SET YourLibraryNameHere.MergeData&timeStamp.;
	
	*CREATES A BOOL VAR FOR MATCH USE;
	
	MergeDataKeyEngr = 1;
	
	*PREPROCESS VARIABLES FOR ID KEY GENERATION;
	
	*DATA CLEANSE AND FORMATIING OF LAST NAME, REMOVES WHITE SPACE, 
	UPCASE ALL CHARS, DROP HYPHENS, PERIODS, COMMAS;
	
	LENGTH newNameLast $15;
	newNameLast=SCAN(COMPRESS(LEFT(Last_Name),"*-.,' "),1);
	
	LENGTH newNameFirst $15;
	newNameFirst=SCAN(COMPRESS(LEFT(First_Name),"*-.,' "),1);
	
	*ENGINEER NEW VARIABLE, DOB IN YYMMDD FORMAT;
	
	newDOB=PUT(date_of_birth, yymmddn8.);
	
	*ENGINEER TEMP VARIABLES FOR REUSE IN KEYS;
	
	tmpLastName = CATX(' ', SUBSTR(newNameLast, 1, 1), SUBSTR(newNameLast, 3, 8));
	tmpFirstName = CATX(' ', SUBSTR(newNameFirst, 1, 1), SUBSTR(newNameFirst, 3, 8));
	tmpNewDOB01 = CATX('', SUBSTR(newDOB, 5, 2), SUBSTR(newDOB, 1, 4));
	tmpNewDOB02 = CATX('', SUBSTR(newDOB, 7, 2), SUBSTR(newDOB, 1, 4));
	
	*ENGINEER ID KEYS;
	
	Key01 = CATX(' ', newNameLast, SUBSTR(newFirstName,1,6), newDOB);
	Key02 = CATX(' ', tmpLastName, SUBSTR(newFirstName, 2, 8), newDOB);
	Key03 = CATX(' ', SUBSTR(newNameLast, 2, 6), SUBSTR(newNameFirst, 1, 6), newDOB);
	Key04 = CATX(' ', newNameLast, SUBSTR(newNameFirst, 1, 3), newDOB);
	Key05 = CATX(' ', SUBSTR(newNameLast, 3, 3), SUBSTR(newNameFirst, 1, 3), newDOB);
	Key06 = CATX(' ', SUBSTR(newNameLast, 1, 4), SUBSTR(newNameFirst, 1, 4), newDOB);
	Key07 = CATX(' ', tmpLastName, SUBSTR(newNameFirst, 2, 8), tmpNewDOB01);
	Key08 = CATX(' ', tmpLastName, SUBSTR(newNameFirst, 2, 8), tmpNewDOB02);
	Key09 = CATX(' ', SUBSTR(newNameLast, 1, 5), SUBSTR(newNameFirst, 1, 4), tmpNewDOB01);
	Key10 = CATX(' ', tmpFirstName, SUBSTR(newNameLast, 2, 8), tmpNewDOB01);
	Key11 = CATX(' ', tmpFirstName, SUBSTR(newNameLast, 2, 8), tmpNewDOB02);
	Key12 = CATX(' ', SUBSTR(newNameFirst, 1, 5), SUBSTR(newNameLast, 1, 4), tmpNewDOB01);
	Key13 = CATX(' ', SUBSTR(newNameFirst, 1, 5), SUBSTR(newNameLast, 1, 4), tmpNewDOB02);
	
	*Remove temp variables from dataset;
	
	DROP tmpLastName tmpFirstName tmpNewDOB01 tmpNewDOB02;

RUN;

*USE FOR KEYMATCHER MACRO;
%LET mergeDSVal = "ENTER ALL COLUMN NAMES TO BE DROPPED FROM DATASET TO BE MATCHED HERE";

/**************************************************************** 
FUNCTION - CREATES TWO DATASETS, MATCHED ROWS, TO BE MATCHED
				      TO CALL FUNCTION
--> %KEYMATCHER(sortDS01=, sortDS02=, sortKey=, dropVals=) <--

****************************************************************

- THE mergeData DATASET WILL BE USED AS INPUT FOR SUBSEQUENT sortDS02 VALUES
- INPUT DATASET TO BE MATCHED ON AS sortDS02
- INPUT DATASET OF ENGR KEY VALUES TO BE USED FOR MATCHING AS sortDS01
- INPUT KeyN INT VALUE (E.G. KEY12 == 12) AS sortKey*/

%MACRO KEYMATCHER(sortDS01=, sortDS02=, sortKey=, dropVals=&mergeDSVal.);
	PROC SORT DATA=&sortDS01;
		BY &sortKey;
	PROC SORT DATA=&sortDS02;
		BY &sortKey;
	DATA KeyMatch&sortKey (DROP=Key01-Key13)
		mergeData&sortKey (DROP=dropVals);
		
		MERGE &sortDS01 (in=A) &sortDS02 (in=B);
		BY &sortKey;
		
		*INNER JOIN OF TABLES ON sortKey VALUE;
	 	*OUTPUTS ROWS SUCCESSFULLY MATCHED TO THIS POINT;
	 	IF A=1 AND B=1 THEN OUTPUT keyMatch&sortKey; 
	 	
	 	*RIGHT JOIN OF TABLES ON Key01 VALUE;
	 	*THESE WILL BE THE ROWS YET TO MATCH;
	 	ELSE IF A=0 AND B=1 THEN OUTPUT mergeData&sortKey;
	RUN;
%MEND KEYMATCHER;

*KEY MATCHING FROM Key01,...,KeyN;

*KEY01;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=MergeDataCln&timeStamp., sortKey=01, dropVals=&mergeDSVal.);

*KEY02;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData01, sortKey=02, dropVals=&mergeDSVal.);

*KEY03;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData02, sortKey=03, dropVals=&mergeDSVal.);

*KEY04;
%KEYMATCHER(sortDS01=REDCapKey, sortDS03=mergeData03, sortKey=04, dropVals=&mergeDSVal.);

*KEY05;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData04, sortKey=05, dropVals=&mergeDSVal.);

*KEY06;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData05, sortKey=06, dropVals=&mergeDSVal.);

*KEY07;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData06, sortKey=07, dropVals=&mergeDSVal.);

*KEY08;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData07, sortKey=08, dropVals=&mergeDSVal.);

*KEY09;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData08, sortKey=09, dropVals=&mergeDSVal.);

*KEY10;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData09, sortKey=10, dropVals=&mergeDSVal.);

*KEY11;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData10, sortKey=11, dropVals=&mergeDSVal.);

*KEY12;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData11, sortKey=12, dropVals=&mergeDSVal.);

*KEY13;
%KEYMATCHER(sortDS01=REDCapKey, sortDS02=mergeData12, sortKey=13, dropVals=&mergeDSVal.);

*MERGE ALL SUBSETS CREATED BY KEYMATCHER AND OUTPUT FINAL MERGED/MATCHED DATASET;

DATA SigPTMatch;
	SET mergeData01 mergeData02 mergeData03 mergeData04 mergeData05 mergeData06 mergeData07
		mergeData08 mergeData09 mergeData10 mergeData11 mergeData12 mergeData13;
	MATCH = 1;
RUN;

PROC EXPORT DATA=MrgMatDS
	OUTFILE= "/PATH/TO/WHERE/DATASET/TO/BE/SAVED/REDCapDatasetMatched&timeStamp..xlsx"
	DBMS=xlsx REPLACE;
	SHEET="Output_&timeStamp."; 
run;
