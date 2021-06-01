
libname Death '/folders/myfolders/Portfolio3';

%let path=/folders/myfolders/Portfolio3/;
filename N01 "&path\Dataset.xlsx";

/************** Importing the Dataset **************/
PROC IMPORT DATAFILE=N01
	REPLACE
	DBMS=XLSX
	OUT=DEATH.Dataset;
	SHEET="Data";
	GETNAMES=YES;
RUN;


/************** Cleaning the Dataset **************/

data Death.Clean;
	set DEATH.Dataset (drop=K L);

/************** EOSSTT variable **************/
	EOSSTT=UPCASE(EOSSTT);
	if EOSSTT='DISC' then EOSSTT='DISCONTINUED';
	else if EOSSTT = 'UNK' then EOSSTT='UNKNOWN';

	if DCSREAS = 'COMPLETED' then EOSSTT='COMPLETED';
	else if DCSREAS = 'DEATH' then EOSSTT='DISCONTINUED';
	else if DTHDT ^=. then EOSSTT='DISCONTINUED';
	

/************** DCSREAS variable **************/
	if DTHDT ^=. then DCSREAS='DEATH';
	
/************** CREATBL variable **************/
/**** updating as per single observation ******/
	if USUBJID='XYZ-001-008' then CREATBL=1.1;
	if USUBJID='XYZ-001-028' then CREATBL=1.3;

/************** GFREBL variable **************/
	if USUBJID='XYZ-001-080' then GFREBL=91.1;
	if USUBJID='XYZ-001-097' then GFREBL=63.8;
	
/************** DTHDT variable **************/
/* No Change */

/************** DTHCAUS variable **************/
/* No Change */

/************** EOSDT variable **************/
/* No Change */
	
/************** TRTSDT variable **************/
/* No Change */
	
Label	USUBJID	= "Unique Subject Identifier"
		EOSSTT	= "End of Study Status"
		DCSREAS	= "Reason for Discontinuation from Study"
		CREATBL	= "Baseline Creatinine (mg/dL)"
		GFREBL	= "Baseline GFRE (mL/min/1.73m2)"
		DTHDT	= "Date of Death"
		DTHCAUS	= "Cause of Death"
		EOSDT	= "End of Study Date"
		TRTSDT	= "Date of First Exposure to Treatment";
run;

/************** Remove all unknown observations **************/
data Death.Clean;
	modify death.clean;
	if find(EOSSTT,'UNKNOWN') then remove;
run;

	


/************** Create the Listing **************/
%let outpath=/folders/myfolders/Portfolio3/;

Proc Sort data=Death.Clean;
	by USUBJID;
run;

proc export data=demo.needs_review
	outfile="&outpath\Death_Report.xls"
	dbms=xls
	replace;
run;


/************** TESTING DATASET **************/

/* data temp; */
/* 	set Death.Clean; */
/* 		where GFREBL>110; */
/* run; */
/*  */
/* PROC SORT DATA=death.clean;BY GFREBL; RUN; */
/* PROC FREQ DATA=death.clean order=internal;TABLE GFREBL; RUN; */

/* PROC CONTENTS DATA=Death.dataset; RUN; */
