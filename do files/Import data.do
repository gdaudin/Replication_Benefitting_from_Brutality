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


** Import and transform war dataset for war variable
import delimited "$dir/external data/European wars.csv", clear
reshape long wars comment, i(year) j(country) string
replace country= "English" if country=="uk"
replace country= "French" if country=="fr"
replace country= "Danish" if country=="dk"
replace country= "Dutch" if country=="nl"
replace country= "Spanish" if country=="sp"
rename country nationality
rename year YEARAF
rename wars war
label var war "War involving own nationality"


save "${output}European wars.dta", replace

** Import and transform war dataset for neutral variable
import delimited "$dir/external data/European wars.csv", clear
drop comment*
generate neutraluk=0
replace neutraluk=1 if warsuk==0 & (warsfr ==1 | warsnl==1 | warssp==1)
generate neutralfr=0
replace neutralfr=1 if warsfr==0 & (warsuk ==1 | warsnl==1 | warssp==1)
generate neutralnl=0
replace neutralnl=1 if warsnl==0 & (warsuk ==1 | warsfr==1 | warssp==1)
generate neutraldk=0
replace neutraldk=1 if warsdk==0 & (warsuk ==1 | warsfr==1 | warsnl==1 | warssp==1)
generate neutralsp=0
replace neutralsp=1 if warsdk==0 & (warsuk ==1 | warsfr==1 | warsnl==1)
list year if neutralfr==1
drop wars*
reshape long neutral, i(year) j(country) string
replace country= "English" if country=="uk"
replace country= "French" if country=="fr"
replace country= "Danish" if country=="dk"
replace country= "Dutch" if country=="nl"
replace country= "Spanish" if country=="sp"
rename country nationality
rename year YEARAF
label var neutral "Neutrality of own nation"

save "${output}Neutrality.dta", replace



** Import and transform exchange rate dataset
import delimited "$dir/external data/Exchange rates from Denzel.csv", clear
rename v1 year
rename francsperpoundssterling francsperpoundsterling
rename *perpoundsterling conv*
reshape long conv, i(year) j(currency) string
drop if conv==.
rename conv blink 
generate conv=1/blink
drop blink
rename year transaction_year
save "${output}Exchange rates from Denzel.dta", replace

** Import conversion in grams of silver
import delimited "$dir/external data/Silver equivalent of the lt and franc (Hoffman).csv", clear

*rename v1 year
rename value_of_livre convlivretournois
/*drop v5-v12 
drop v2 v3
drop if year=="Source:"
drop if year==""
drop if convlivretournois=="" */
replace convlivretournois = subinstr(convlivretournois,",",".",.)
destring year, replace
destring convlivretournois, replace
drop if year<1668 
drop if year>1840

save "${output}FR_silver.dta", replace

import delimited "$dir/external data/Silver equivalent of dollar (Lindert).csv", clear

ren gramsofsilverperpesofuerte convpesofuerte
save "${output}SP_silver.dta", replace

import delimited "$dir/external data/Silver equivalent of the pound sterling (see colum CI _ CH).csv", clear
drop v1-v85
drop v90-v172
drop v88
drop v86
rename v89 year
rename v87 convpoundsterling
drop if convpoundsterling=="market price"
drop if year=="Year"
drop if year==""
drop if  convpoundsterling==""
destring year, replace
destring convpoundsterling, replace


merge 1:1 year using "${output}FR_silver.dta"
drop _merge
erase "${output}FR_silver.dta"

merge 1:1 year using "${output}SP_silver.dta"
erase "${output}SP_silver.dta"
drop _merge

drop if year <1668 | year >1830
**From Klas’s email December 15th, 2022
generate convguilder=9.61
generate convrixdollars=25.81
generate convrigsbanksdaler=12.649
reshape long conv, i(year) j(currency) string
replace currency = "Livres tournois" if currency=="livretournois"
replace currency = "Dutch Guilder" if currency=="guilder"
replace currency = "Pound sterling" if currency=="poundsterling"
replace currency = "Danish rigsdaler" if currency=="rigsbanksdaler"
replace currency = "Peso fuerte" if currency=="pesofuerte"
rename conv conv_in_silver
rename year transaction_year
save "${output}Exchange rates in silver.dta", replace


* PREPARE SLAVE PRICES TO DATASET TO BE APPENDED
clear
import delimited "$dir/external data/Slave prices/Slave prices to append.csv"
ipolate africa year, generate(priceafrica)
ipolate america year, generate(priceamerica)
drop africa
drop america
ren year YEARAF

save "${output}Prices.dta", replace

///////////////////////////////////////////////////////////////////////////-

* IMPORT CASH FLOW-DATABASES
* STANDARDIZING STRING FIELDS, IN CASE SOME DATASETS HAVE MISSING VARIABLES FOR ALL OBS
* STANDARDIZING THE NUMERIC VARIABLES SO THAT COMMAS ARE REPLACED BY DOTS AS DECIMAL-SEPARATOR IN THE VALUE-FIELD
* STANDARDIZING THE VARIABLES SO THAT THE FIELD WITH VALUES REALLY ARE NUMERIC, EVEN IF DATA IS MISSING IN SOME CASES
* ROUTINE THE REPEATED FOR EACH DATASET

foreach y in "DR" "GD" "GK" "KR - new" "MR - new"{
	import delimited "$dir/data/Cash flow database `y'.csv" , encoding(utf8) clear
	capture tostring meansofpaymentreturn dateoftransaction , replace
	capture replace value=subinstr(value, ",", ".",.)
	capture destring value, force replace
	save "${output}Cash flow `y'.dta", replace
	assert ventureid !=""
}



 
* ALL CASH FLOW DATASETS MERGED INTO ONE FILE, AND SAVED IN NEW FILE

use "${output}Cash flow DR.dta", clear
	foreach y in "GD" "GK" "KR - new" "MR - new"{
	append using "${output}Cash flow `y'.dta", force
	assert ventureid !=""
}

*append using "C:\Users\xronkl\ShareFile\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\STATA\Cash flow MR.dta"

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


save "${output}Cash flow all.dta", replace

foreach y in "DR" "GD" "GK" "KR - new" "MR - new"{
	erase "${output}Cash flow `y'.dta" 
}


* IMPORT VENTURE DATABASES
* STANDARDIZING STRING FIELDS, IN CASE SOME DATASETS HAVE MISSING VARIABLES FOR ALL OBS
* STANDARDIZING NUMERIC FIELDS, IN CASE THEY FOR SOME REASON CONTAIN STRINGS. THIS IS CURRENTLY FORCED, SO STRING VALUES ARE LOST.
* ROUTINE THE REPEATED FOR EACH DATASET

foreach y in "DR" "GD" "GK" "KR - new" /*"MR"*/ {
	import delimited "$dir/data/Venture database `y'.csv", encoding(utf8) clear 
	capture tostring  date* place* number* voyageidintstd internalcrossref nameofthecaptain  profitsreportedinsource, replace
	capture replace shareoftheship=subinstr(shareoftheship, ",", ".",.)
	capture destring shareoftheship, force replace
	capture destring numberofvoyages, force replace
	rename fate FATEcol 
save "${output}Venture `y'.dta", replace
}

clear


* ALL VENTURE DATASETS MERGED INTO ONE FILE, AND SAVED IN NEW FILE

use "${output}Venture DR.dta"

foreach y in "GD" "GK" "KR - new" /*"MR"*/ {
	append using "${output}Venture `y'.dta", force
}

 
*append using "C:\Users\xronkl\ShareFile\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\STATA\Venture MR.dta"

* STANDARDIZE THE SPELLING IN SOME VARIABLES

replace perspectiveofsource="Investor" if perspectiveofsource=="investor"
replace perspectiveofsource="Owner" if perspectiveofsource=="Owner?"
replace completedataonoutlays="no" if  strpos(completedataonoutlays, "N")  |  strpos(completedataonoutlays, "n") 
replace internalcrossref="" if internalcrossref=="."
replace nameofoutfitter="" if nameofoutfitter=="."
replace nameofthecaptain="" if nameofthecaptain=="."


destring numberofslavespurchased, replace
destring numberofslavessold, replace


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
foreach y in "DR" "GD" "GK" "KR - new" /*"MR"*/ {
	erase "${output}Venture `y'.dta"
}

use "${output}Venture all.dta", clear
* LENGTH COMPUTATION (IN DAYS) WHEN WE HAVE AT LEAST THE MONTH OF DEPARTURE AND ARRIVAL IN OUR DATA

local varlist dateofdeparturefromportofoutfitt dateofreturntoportofoutfitting

foreach var of local varlist {
	gen year1=substr( `var' ,1,4)
	gen month1=substr( `var' ,6,2)
	gen day1=substr( `var' ,9,2)
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
	gen month1=substr( `var' ,6,2)
	gen day1=substr( `var' ,9,2)
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

gen yearofdeparturefromportofoutfit=year(destring(substr(dateofdeparturefromportofoutfit,4)))
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



