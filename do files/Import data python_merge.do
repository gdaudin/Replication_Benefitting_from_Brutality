clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}

///////////////////////////////////////////////////////////////////////////-

* IMPORT CASH FLOW-DATABASES (now "transactions.csv" from python)
import delimited "$dir/python_merge/transactions.csv" , encoding(utf8) clear
save blouf.dat, replace

import delimited "$dir/python_merge/transactions_hypothetical.csv" , encoding(utf8) clear
append using blouf.dat
erase blouf.dat

rename *_* **
*drop if regexm(ventureid, "MR")
rename linenumber line_number



foreach var of varlist meansofpaymentreturn dateoftransaction {
	replace `var' = "" if "`var'" == "nan"
}

recast str2045 specification 
assert ventureid !=""

save "${output}Cash flow all.dta", replace


//To complete specification categories
import delimited "$dir/data/specification_categories.csv" , encoding(utf8) clear
recast str2045 specification 
keep specification specificationcategory

merge 1:m specification using "${output}Cash flow all.dta"
drop if _merge==1
bys specification: generate n=_N 
keep specification specificationcategory n
bys specification : keep if _n==1
gen nminus=-n
sort nminus specification, stable
outsheet using "$dir/data/specification_categories.csv", replace noquote


//To merge with specification categories
import delimited "$dir/data/specification_categories.csv" , encoding(utf8) clear
recast str2045 specification 
keep specification specificationcategory

merge 1:m specification using "${output}Cash flow all.dta"

assert _merge==3 | _merge==1 
drop if _merge==1


drop _merge

replace intermediarytradingoperation = 0 if intermediarytradingoperation==.
**Treating the date
gen date = date(dateoftransaction, "YMD")
gen date2 = date(dateoftransaction, "Y")
gen date3 = date(dateoftransaction, "YM")

drop dateoftransaction
generate dateoftransaction=date
replace dateoftransaction=date2 if dateoftransaction==.
replace dateoftransaction=date3 if dateoftransaction==.

drop date date2 date3

generate transaction_year = yofd(dateoftransaction)

sort ventureid line_number
save "${output}Cash flow all.dta", replace
export delimited "${output}Cash flow all.csv", replace


///////////////////////////////////
* IMPORT VENTURE DATABASE
////////////////////////////////////

clear

import delimited "$dir/python_merge/venture all.csv" , encoding(utf8) clear
**In the do file, spaces were initially removed. With the merged data, they werereplaced by 
rename *_* **
rename *_* **
rename *_* **
rename *_* **
rename *_* **
rename *_* **
rename dateofdeparturefromportofo dateofdeparturefromportofoutfitt
rename dateofreturntoportofoutfit dateofreturntoportofoutfitting
drop if regexm(ventureid, "MR")
drop if ventureid == ""

foreach var of varlist date* place* number* {
	replace `var' = "" if `var' == "nan"
}
list numberofslavespurchased if regexm(numberofslavespurchased, "[^0-9.]")

 
capture tostring  date* place* number* voyageidintstd internalcrossref nameofthecaptain  profitsreportedinsource, replace
capture replace shareoftheship=subinstr(shareoftheship, ",", ".",.)
capture destring shareoftheship, force replace
capture destring numberofvoyages, force replace
rename fate FATEcol 


* STANDARDIZE THE SPELLING IN SOME VARIABLES

*replace perspectiveofsource="Investor" if perspectiveofsource=="investor"
replace perspectiveofsource="Owner" if perspectiveofsource=="Owner?"
*replace completedataonoutlays="no" if  strpos(completedataonoutlays, "N")  |  strpos(completedataonoutlays, "n") 
*replace internalcrossref="" if internalcrossref=="."
*replace nameofoutfitter="" if nameofoutfitter=="."
*replace nameofthecaptain="" if nameofthecaptain=="."


*destring numberofslavespurchased, replace
*destring numberofslavessold, replace


// Standardize OUTFITTER names for merge with TSDT
replace nameofoutfitter = "Delaville" if nameofoutfitter=="A. Delaville & Barthelemy"
replace nameofoutfitter = "Ballan (Aîné)" if nameofoutfitter=="Ballan ainé"
replace nameofoutfitter = "Romanet, Adrien" if nameofoutfitter=="A. Romanet"
replace nameofoutfitter = "Ménard" if nameofoutfitter=="A. Menard"
replace nameofoutfitter = "Dumaine"  if nameofoutfitter=="D’Haveloose et Dumaine"
replace nameofoutfitter = "Ducollet"  if nameofoutfitter=="Ducollet and Favreau Colleno et Cie"
replace nameofoutfitter = "Geslin"  if strmatch(nameofoutfitter,"*Geslin*")==1
replace nameofoutfitter = "Jogues"  if nameofoutfitter=="Jogues Freres"
replace nameofoutfitter = "Langevin"  if nameofoutfitter=="L. et F. Langevin frères"
replace nameofoutfitter = "Libault"  if strmatch(nameofoutfitter,"*Libault*")==1
replace nameofoutfitter = "Arnou"  if strmatch(nameofoutfitter,"*N. Arnou*")==1
replace nameofoutfitter = "Portier de Lantimo" if strmatch(nameofoutfitter,"*Portier de Lantimo*")==1
replace nameofoutfitter = "Rossel" if strmatch(nameofoutfitter,"*Rossel*")==1
replace nameofoutfitter = "Goad, John" if strmatch(nameofoutfitter,"*Goad, Joan*")==1


save "${output}Venture all.dta", replace


use "${output}Venture all.dta", clear
* LENGTH COMPUTATION (IN DAYS) WHEN WE HAVE AT LEAST THE MONTH OF DEPARTURE AND ARRIVAL IN OUR DATA


local varlist dateofdeparturefromportofoutfitt dateofreturntoportofoutfitting

foreach var of local varlist {
	gen year1=substr( `var' ,1,4)
	**Multiple voyages will be an issue
	gen month1=substr( `var' ,6,2) if strmatch(`var',"*/*")!=1
	gen day1=substr( `var' ,9,2) if strmatch(`var',"*/*")!=1
	destring year1, replace
	destring month1, replace
	destring day1, replace
	local x = substr("`var'",  7,100)
	gen  `x'=.
	replace `x'= month1
	replace day1=1 if missing(day1) & year1!=. & month1!=. 
	gen date1=mdy(month1, day1, year1)
	format date1 %d
	drop year1 month1 day1 
	if  "`var'" == "dateofdeparturefromportofoutfitt" {
		ren `var' datedepartureportofoutfitt_str
	} 
	if  "`var'" == "dateofreturntoportofoutfitting" {
		ren `var' datereturnportofoutfitting_str
	} 
	ren date1  `var'
}

gen length_in_days=(dateofreturntoportofoutfitting-dateofdeparturefromportofoutfitt)
label var length_in_days "Length of voyage (Europe to Europe) in days"
drop dateofreturntoportofoutfitting dateofdeparturefromportofoutfitt returntoportofoutfitting departurefromportofoutfitt
rename datereturnportofoutfitting_str dateofreturntoportofoutfitting
rename datedepartureportofoutfitt_str dateofdeparturefromportofoutfitt


* A SET OF DATES IN STATA-READABLE FORMAT ARE DERIVED FROM DATE IN STRING FORMAT, BASED ON POSITION OF CHARACTERS IN THE STRING (DATES ARE TO BE FORMATTED AS: YYYY-MM-DD)
* IF MONTH & DAY IS MISSING IN THE OBSERVATION, BUT WE HAVE AN OBSERVATION FOR YEAR, MONTH AND DATE IS CURRENTLY ASSUMED TO BE 1st OF JULY, IN ORDER TO CREATE A STATA-READABLE DATE-VAR.
* ROUTINE IS THEN REPEATED FOR ALL DIFFERENT DATES IN THE DATASETS


local varlist dateofdeparturefromportofoutfitt dateofprimarysource datetradebeganinafrica dateofdeparturefromafrica datevesselarrivedwithslaves dateofreturntoportofoutfitting

foreach var of local varlist {
	gen year1=substr( `var' ,1,4)
	gen month1=substr( `var' ,6,2) if strmatch(`var',"*/*")!=1
	gen day1=substr( `var' ,9,2) if strmatch(`var',"*/*")!=1
	destring year1, replace
	destring month1, replace
	destring day1, replace
	if "`var'" == "datevesselarrivedwithslaves" |   "`var'" == "datetradebeganinafrica" {
		local x = substr("`var'",  5,100)
	}
	else {
		local x = substr("`var'",  7,100)
	}
	gen  `x'=.
	replace `x'= month1
	replace month1=7 if missing(month1) & year1<.
	replace day1=1 if missing(day1) & year1<.
	gen date1=mdy(month1, day1, year1)
	format date1 %d
	drop year1 month1 day1 
	if  "`var'" == "dateofdeparturefromportofoutfitt" {
		ren `var' datedepartureportofoutfitt_str
	} 
	else if  "`var'" == "dateofreturntoportofoutfitting" {
		ren `var' datereturnportofoutfitting_str
	} 
	else {
	ren `var' `var'_str
	}
	ren date1  `var'
}


* VARIABLES ONLY INCLUDING THE YEARS OF THE VARIOUS CHRONOLOGICAL VARS ARE DERIVED FROM THE RESPECTIVE DATE-VARS

gen yearofdeparturefromportofoutfit=year(dateofdeparturefromportofoutfitt)
gen yearofprimarysource=year(dateofprimarysource)
gen yeartradebeganinafrica=year(datetradebeganinafrica)
gen yearofdeparturefromafrica=year(dateofdeparturefromafrica)
gen yearvesselarrivedwithslaves=year(datevesselarrivedwithslaves)
gen yearofreturntoportofoutfitting=year(dateofreturntoportofoutfitting)

* GENERAL YEAR-VARIABLE, THE LOWEST COMMON DENOMINATOR, IN ORDER TO BE ABLE TO ORDER THE VENTURES ROUGHLY CHRONOLOGICALLY

gen yearmin= yearofdeparturefromportofoutfit
replace yearmin= yeartradebeganinafrica if yearmin==.
replace yearmin= yearofdeparturefromafrica if yearmin==.
replace yearmin= yearvesselarrivedwithslaves if yearmin==.
replace yearmin= yearofreturntoportofoutfitting if yearmin==.


** Generate YEARAF_own if WE HAVE SOME DATA ON THE TIMING IN OUR DATASETS
* NB: SOME ASSUMPTIONS ARE MADE AS TO THE TIMING, IF WE ONLY HAVE DATE FROM DEPARTURE FROM OR RETURN TO EUROPE.

generate YEARAF_own=.
replace YEARAF_own= yeartradebeganinafrica if missing(YEARAF_own)
replace YEARAF_own= yearofdeparturefromafrica if missing(YEARAF_own)
replace YEARAF_own= yearvesselarrivedwithslaves if missing(YEARAF_own)
replace YEARAF_own= yearofdeparturefromportofoutfit+1 if missing(YEARAF_own)
replace YEARAF_own= yearofreturntoportofoutfitting-1 if missing(YEARAF_own)
replace YEARAF_own= yearofprimarysource if missing(YEARAF_own)


* CREATE A NUMERIC VARIABLE OUT OF THE VAR FOR ID IN THE TRANSATLANTIC SLAVE TRADE DATABASE, FOR LINKING THE DATASETS
* THEN THE DATASETS ARE MERGED, AND UNNECESSARY OBSERVATIONS FROM THE TSTD (I.E. THOSE THAT ARE NOT PRESENT IN OUR DATASETS) ARE DROPPED
* NB: CURRENT ROUTINE ONLY MANAGES TO DO THIS FOR OBS OF ONE SINGLE VOYAGE; VENTURES INCORPORATING MULTIPLE VOYAGES CANNOT BE CAPTURED IN THIS WAY. HAVE NOT YET FIGURED OUT A GOOD WAY TO LINK WHEN THERE ARE MULTIPLE VOYAGES
***GD Februrary 2025 : I am not sure we use this anymore
gen VOYAGEID= voyageidintstd
*destring VOYAGEID, force replace
save "${output}Venture all.dta", replace
export delimited "${output}Venture all.csv", replace

codebook ventureid
quietly summarize numberofvoyages
display r(sum)



