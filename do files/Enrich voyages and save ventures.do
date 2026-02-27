clear



use "${output}voyages.dta", clear

merge m:1 VOYAGEID using "${tstddb}tstddb-exp-2020_corr.dta"
drop _merge

****We work only on the voyages in the profit database
**we need to keep the voyages without full data to be able to impute latter
drop if ventureid==""

sort ventureid VOYAGEID

keep ventureid numberofvoyages voyagenumber VOYAGEID YEARAF MAJBYIMP MJBYPTIMP  /*
*/ SLAXIMP SLAMIMP CAPTAINA OWNERA DATEEND DATEDEP FATE FATE4 data nameofoutfitter/*
*/ nameofthecaptain YEARAF_own TONMOD nationality YEARDEP
sort ventureid DATEDEP

foreach rank of numlist 1(1)7 {
	foreach var of varlist DATEEND DATEDEP {
	capture gen `var'`rank'=.
	replace `var'`rank'=`var' if voyagenumber==`rank'
	}
}

//Here, we assume our data on outfitter is correct
replace OWNERA= nameofoutfitter if nameofoutfitter!=""
//Here, we assume stdt on captain and year is correct
replace CAPTAINA= nameofthecaptain if missing(CAPTAINA)
replace YEARAF = YEARAF_own if missing(YEARAF)
drop nameofoutfitter nameofthecaptain YEARAF_own


**Crowding
gen crowd=SLAXIMP/TONMOD
label var crowd "Number of embarked enslaved persons per ton"

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

label define fate 1 "Voyage completed as intended" 2 "Original goal thwarted before disembarking enslaved people" 3 "Original goal thwarted after disembarking enslaved people" 4 "Unspecified/unknown", replace
label values FATEcol fate

**Compute the length of each voyage (if possible)
gen length_in_days=(DATEEND-DATEDEP)/1000/60/60/24
label var length_in_days "Length of voyage (Europe to Europe) in days"
*drop DATEEND DATEDEP




***To get rid of values that cannot be averaged because some other one is missing (if we want to do that)
foreach var of varlist  SLAXIMP SLAMIMP length_in_days YEARAF {
	gen test`var'=1 if `var'==.
	replace test`var'=0 if `var'!=.
	egen test1=max(test`var'), by(ventureid)
	replace `var' =. if test1==1
	drop test`var' test1	
}



gsort - SLAXIMP
sort ventureid YEARAF, stable


******move back to ventures
collapse (first)  data (mean) YEARDEP YEARAF SLAXIMP SLAMIMP length_in_days (max) numberofvoyages FATEdum1 FATEdum2 FATEdum3 FATEdum4 DATEDEP* DATEEND* ////
			(mean) crowd TONMOD ///
			, by(ventureid)

generate VYMRTRAT=(SLAXIMP-SLAMIMP)/SLAXIMP


label var TONMOD "Tonnage standardized on British measured tons, 1773-1835"
label var crowd "Number of embarked enslaved people per ton"
label var SLAXIMP "Imputed number of enslaved people embarked"



sort ventureid YEARAF

*** GENERATE FATEcol from dummy variables after collapsing.
gen FATEcol=1 if FATEdum1==1
replace FATEcol=3 if FATEdum3==1
replace FATEcol=2 if FATEdum2==1
replace FATEcol=4 if FATEdum4==1
drop FATEdum*

label values FATEcol fate //label fate is defined earlier
label var FATEcol "Fate of venture"



save "${output}Ventures+TSTD variables.dta", replace

/////Enrich Venture all.dta








