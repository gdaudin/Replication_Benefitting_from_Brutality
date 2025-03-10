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

merge m:1 VOYAGEID using "${tastdb}tastdb-exp-2020_corr.dta"
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


****add port shares
merge m:1 YEARAF MJBYPTIMP using "${output}port_shares.dta", keep(1 3)
drop _merge

**Crowding
gen crowd=SLAXIMP/TONMOD
label var crowd "Number of embarked enslaved persons per ton"

* APPEND SLAVE PRICES
merge m:1 YEARAF using "${output}Prices.dta"
drop if _merge==2
drop _merge
gen pricemarkup=priceamerica/priceafrica
label var pricemarkup "Slave price markup between America and Africa"

*APPEND WARS
merge m:1 YEARAF nationality using "${output}European wars.dta"
drop if _merge==2
drop _merge

***APPEND NEUTRALITY
merge m:1 YEARAF nationality using  "${output}Neutrality.dta"
drop if _merge==2
drop _merge


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
*drop DATEEND DATEDEP




***To get rid of values that cannot be averaged because some other one is missing (if we want to do that)
foreach var of varlist  SLAXIMP SLAMIMP length_in_days YEARAF {
	gen test`var'=1 if `var'==.
	replace test`var'=0 if `var'!=.
	egen test1=max(test`var'), by(ventureid)
	replace `var' =. if test1==1
	drop test`var' test1	
}



***Simplify trading regions

decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
encode MAJMAJBYIMP, gen(MAJMAJBYIMP_num)
label var MAJMAJBYIMP "African region of trade"
label var MAJMAJBYIMP_num "African region of trade"


*****Now merge voyages with careers


* MERGE WITH Career DATASET (CAPTAIN)
generate CAPTAIN = ""
replace CAPTAIN = CAPTAINA
*replace CAPTAIN = nameofthecaptain if CAPTAIN==""
replace CAPTAIN="" if CAPTAIN=="."
merge m:1 CAPTAIN YEARAF MAJMAJBYIMP using "${output}Captain.dta"
drop if _merge==2
*For debugging
*br CAPTAIN YEARAF ventureid VOYAGEID if _merge==1 & (CAPTAIN!="" & YEARAF !=.)
assert (CAPTAIN=="" | YEARAF ==.) if _merge==1 	&  data >=1
	
drop _merge


* MERGE WITH Career DATASET (OUTFITTER)
generate OUTFITTER = ""
replace OUTFITTER = OWNERA if OUTFITTER==""
replace OUTFITTER="" if OUTFITTER=="."
merge m:1 OUTFITTER YEARAF MAJMAJBYIMP using "${output}OUTFITTER.dta"
drop if _merge==2
*For debugging
*br OUTFITTER YEARAF ventureid VOYAGEID if _merge==1 & (OUTFITTER!="" & YEARAF !=.)
assert (OUTFITTER=="" | YEARAF ==.) if _merge==1 &  data >=1




drop _merge


**** only keep region if it is constant inside each ventureid

foreach var of varlist MAJMAJBYIMP {
	bys  ventureid (`var'): replace `var'="" if `var'[1]!=`var'[_N]
}


gsort - SLAXIMP
sort ventureid YEARAF, stable


******move back to ventures
collapse (first)  MAJMAJBYIMP data (mean) YEARDEP YEARAF SLAXIMP SLAMIMP length_in_days (max) numberofvoyages FATEdum1 FATEdum2 FATEdum3 FATEdum4 DATEDEP* DATEEND* /*
			*/ (min) OUTFITTER_experience OUTFITTER_regional_experience captain_experience captain_regional_experience /*
			*/ (mean) OUTFITTER_total_career captain_total_career priceamerica/*
			*/ (mean) port_share crowd pricemarkup war neutral TONMOD/*
			*/, by(ventureid)

generate VYMRTRAT=(SLAXIMP-SLAMIMP)/SLAXIMP

*make dummies out of means

foreach var in war neutral {
	replace `var' = 1 if `var' >=0.5
	replace `var' = 0 if `var' <0.5
}


sort ventureid YEARAF

*** GENERATE FATEcol from dummy variables after collapsing.
gen FATEcol=1 if FATEdum1==1
replace FATEcol=3 if FATEdum3==1
replace FATEcol=2 if FATEdum2==1
replace FATEcol=4 if FATEdum4==1
drop FATEdum*

label values FATEcol fate //label fate is defined earlier



save "${output}Ventures+TSTD variables.dta", replace

/////Enrich Venture all.dta








