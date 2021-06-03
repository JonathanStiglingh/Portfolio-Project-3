
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
	set DEATH.Dataset (drop=Row K L);

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
	DTHCAUS=strip(Upcase(DTHCAUS));

/************** EOSDT variable **************/
/* No Change */
	
/************** TRTSDT variable **************/
/* No Change */
run;

/************** Remove all unknown observations **************/
data Death.Clean;
	modify Death.Clean;
	if find(EOSSTT,'UNKNOWN') then remove;
run;

Data Coding;
	set Death.Clean;
	length DTHCAUS1 $50;
/************** DTHCAUS variable **************/
/******** CODING Cause of death term **********/

		if DTHCAUS=1 then DTHCAUS1='ACUTE MYOCARDIAL INFARCTION';
		if DTHCAUS=2 then DTHCAUS1='ATHEROSCLEROTIC HEART DISEASE';
		if DTHCAUS=3 then DTHCAUS1='CORONARY ARTERY DISEASE';
		if DTHCAUS=4 then DTHCAUS1='CORONARY THROMBOSIS';
		if DTHCAUS=5 then DTHCAUS1='HYPERKALEMIA';
		if DTHCAUS=6 then DTHCAUS1='MALIGNANCY';
		if DTHCAUS=7 then DTHCAUS1='OTHER INFECTION';
		if DTHCAUS=8 then DTHCAUS1='RENAL FAILURE';
		if DTHCAUS=9 then DTHCAUS1='SEPSIS';
		if DTHCAUS=10 then DTHCAUS1='STROKE';
		if DTHCAUS=11 then DTHCAUS1='SUDDEN CARDIAC DEATH';
	drop DTHCAUS; rename DTHCAUS1=DTHCAUS;
	format DTHCAUS1 $50.;
run;



/************** Adding Labels **************/
data Death.Final;
	set coding;
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


/************** Create the Listing **************/
%let outpath=/folders/myfolders/Portfolio3/;
ods pdf file="&outpath\DeathReport.pdf" style=Meadow bookmarkgen=Yes;
ods noproctitle;
options nodate; /*removes the date*/
options label;

Title "Reason for Discontinue";
ods proclabel "Deaths vs Completion";
PROC FREQ DATA=Death.Final order=freq;
TABLE DCSREAS /nocum nofreq nopercent; 
RUN;

Title "Number of Deaths per Year";
ods proclabel "Number of Deaths per year";
proc freq data=Death.Final;
	table DTHDT /nocum nopercent plots=freqplot; /*this can also be done using the Proc SGPLOTS step*/
	format DTHDT year.;
	where DTHDT is not missing;
run;



proc sort data=death.final;
by dthcaus;
run; 

Title "Creatinine and GFRE for those with deaths reported";
ods proclabel "Creatinine and GFRE for those with deaths reported";
proc means data=death.final mean median maxdec=1;
var CREATBL GFREBL;
by dthcaus;
where dthcaus is not missing;
run;

Title "Cummulative Cause of Death";
ods proclabel "Cummulative Cause of Death";
proc freq data=Death.Final;
	table dthcaus /nocum nopercent plots= cumfreqplot; /*this can also be done using the Proc SGPLOTS step*/
	where dthcaus is not missing;
run;

ods pdf close;


/*Eport final to excel file*/

proc sort data=death.final;
by USUBJID ;
run;

proc export data=Death.Final
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
/* PROC SORT DATA=Death.Final;BY DTHCAUS1; RUN; */
PROC FREQ DATA=Death.Final order=freq;TABLE DCSREAS; RUN;

/* PROC CONTENTS DATA=Death.dataset; RUN; */
