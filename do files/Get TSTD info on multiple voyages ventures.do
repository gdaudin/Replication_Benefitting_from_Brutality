clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "$dir/output/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits data and programs"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}




use "${output}voyages.dta", clear

merge m:1 VOYAGEID using "${tastdb}tastdb-exp-2020.dta"
drop _merge

****We work only on the voyages in the profit database, and in the sample
drop if ventureid=="" | sample==0

sort ventureid VOYAGEID

keep ventureid numberofvoyages VOYAGEID YEARAF MAJBYIMP MJSELIMP SLAXIMP SLAMIMP CAPTAINA OWNERA DATEEND DATEDEP FATE FATE4
sort ventureid DATEDEP

gen voyagerank=.
by ventureid (VOYAGEID): replace voyagerank=_n

foreach rank of numlist 1(1)7 {
	foreach var of varlist DATEEND DATEDEP {
	capture gen `var'`rank'=.
	replace `var'`rank'=`var' if voyagerank==`rank'
	}
}


*** COLLAPSE FATE-VARIABLE INTO FOUR CATEGORIES, DEPENDING ON WHETHER/WHEN SHIP WAS LOST, THEN GENERATE DUMMY-VARS TO CAPTURE DIFFERENT OUTCOMES
gen FATEcol=1 if FATE==1
replace FATEcol=2 if FATE==2
replace FATEcol=2 if FATE==3
replace FATEcol=3 if FATE==4
replace FATEcol=3 if FATE==29
replace FATEcol=4 if FATE==49
replace FATEcol=3 if FATE==68
replace FATEcol=3 if FATE==95
replace FATEcol=3 if FATE==97
replace FATEcol=3 if FATE==162
replace FATEcol=4 if FATE==208

gen FATEdum1=1 if FATEcol==1
gen FATEdum2=1 if FATEcol==2
gen FATEdum3=1 if FATEcol==3
gen FATEdum4=1 if FATEcol==4

label define fate 1 "Voyage completed as intended" 2 "Original goal thwarted before disembarking slaves" 3 "Original goal thwarted after disembarking slaves" 4 "Unspecified/unknown", replace
label values FATEcol fate

**Compute the length of each voyage (if possible)
gen length_in_days=(DATEEND-DATEDEP)/1000/60/60/24
label var length_in_days "Length of voyage (Europe to Europe) in days"
drop DATEEND DATEDEP




***To get rid of values that cannot be averaged because some other one is missing (if we want to do that)
foreach var of varlist  SLAXIMP SLAMIMP length_in_days /*YEARAF*/ {
	gen test`var'=1 if `var'==.
	replace test`var'=0 if `var'!=.
	egen test1=max(test`var'), by(ventureid)
	replace `var' =. if test1==1
	drop test`var' test1	
}


*HERE I TEST FOR DIFFERENCES IN MAJBYIMP OR MJSELIMP. IF THERE IS ONE, I REPLACE THEM BY MISSING
foreach var of varlist MAJBYIMP MJSELIMP {

	egen test`var'=group(`var'), missing
	egen test`var'1=min(test`var'), by(ventureid)
	egen test`var'2=max(test`var'), by(ventureid)
	egen test`var'3=max(test`var'2-test`var'1), by(ventureid)
	replace `var'=. if test`var'3 !=0 
	drop test*
}
gsort - SLAXIMP
sort ventureid YEARAF, stable
*We take the chronolgically first captain and owner 


collapse (first) CAPTAINA OWNERA (min) YEARAF (mean) SLAXIMP SLAMIMP length_in_days (max) numberofvoyages FATEdum1 FATEdum2 FATEdum3 FATEdum4 DATEDEP* DATEEND* /*
	*/ (first) MAJBYIMP MJSELIMP, by(ventureid)

generate VYMRTRAT=(SLAXIMP-SLAMIMP)/SLAXIMP

sort ventureid YEARAF


*** GENERATE FATEcol from dummy variables after collapsing.
gen FATEcol=1 if FATEdum1==1
replace FATEcol=3 if FATEdum3==1
replace FATEcol=2 if FATEdum2==1
replace FATEcol=4 if FATEdum4==1
drop FATEdum*

label values FATEcol fate //label fate is defined earlier


foreach var of varlist CAPTAINA OWNERA YEARAF SLAXIMP SLAMIMP length_in_days MAJBYIMP MJSELIMP VYMRTRAT {
	rename `var' `var'rev
}

save "${output}Ventures with multiple voyages TSTD variables.dta", replace

/////Enrich Venture all.dta








