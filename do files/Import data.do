clear


if lower(c(username)) == "kraemer" {
	!subst X: /d
	!subst X:   "C:\Users\Kraemer\Documents"
	capture cd "X:\slaveprofits\"
	if _rc != 0 cd  "C:\Users\Kraemer\Documents\slaveprofits"
	global output "C:\Users\Kraemer\Documents\slaveprofits\script claire\output"
	global tastdb "C:\Users\Kraemer\Documents\slaveprofits\script claire"
}

 if lower(c(username)) == "claire" {
	!subst X: /d
	!subst X:   "/Users/claire/"
	capture cd "X:/slaveprofits/"
	if _rc != 0 cd  "/Users/claire/slaveprofits/"
	global output "/Users/claire/Desktop/temp"
	global tastdb "/Users/claire/slaveprofits/scripts claire/"
}

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

rename v1 year
rename v4 convlivretournois
drop v5-v12 
drop v2 v3
drop if year=="Source:"
drop if year==""
drop if convlivretournois==""
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

gen yearofdeparturefromportofoutfit=year(dateofdeparturefromportofoutfit)
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
gen VOYAGEID= voyageidintstd
*destring VOYAGEID, force replace
save "${output}Venture all.dta", replace

do "$dir/do files/Get TSTD info on multiple voyages ventures"


* MERGE WITH CORRECTION FILE FOR MULTIPLE VOYAGES
use "${output}Venture all.dta", clear
merge m:1 ventureid using "${output}Multiple voyages.dta"
replace YEARAF_own=YEARAFrev if _merge==3
replace VYMRTRAT=VYMRTRATrev if _merge==3
replace MAJBYIMP=MAJBYIMPrev if _merge==3
replace MJSELIMP=MJSELIMPrev if _merge==3
replace SLAXIMP=SLAXIMPrev if _merge==3
replace SLAMIMP=SLAMIMPrev if _merge==3
replace CAPTAINA=CAPTAINArev if _merge==3
replace OWNERA=OWNERArev if _merge==3
replace length_in_days=length_in_daysrev if _merge==3

drop _merge
drop VYMRTRATrev YEARAFrev MAJBYIMPrev MJSELIMPrev length_in_daysrev

save "${output}Venture all.dta", replace

///////////////////////////////////////////////////////////////////////////////
////Captains and OUTFITTERs’ career.
/////1. Start with tstd. Make VOYAGEID string
//// 2. correct names in STDT
//// 3. Merge with our ventures
/////4. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD

*1. Make VOYAGEID string
* EDIT: This line have been moved to Get TSTD info do-file, as we link info there already.
*tostring(VOYAGEID), replace

use "${tastdb}tastdb-exp-2020.dta", clear

//2. Correct owner’s names TSDT

**We make the assumption the first owner is the outfitter in tsdt
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	//French data
	replace OWNER`letter' = "Chateaubriand" if strmatch(OWNER`letter', "*Chateaubriand*")==1
	replace OWNER`letter' = "Romanet, Adrien" if strmatch(OWNER`letter', "*Romanet*")==1
	replace OWNER`letter' = "Ballan (Aîné)" if strmatch(OWNER`letter',"*Ballan*né*")==1
	replace OWNER`letter' = "Bouteiller Père et Fils" if strmatch(OWNER`letter',"*Bouteiller*")==1
	replace OWNER`letter' = "Chaurand" if strmatch(OWNER`letter',"*Chaurand*")==1
	replace OWNER`letter' = "Darreche (Frères)" if strmatch(OWNER`letter',"*Darreche*")==1
	replace OWNER`letter' = "De Guer" if strmatch(OWNER`letter',"*Deguer*")==1
	replace OWNER`letter' = "Desclos Le Perley freres" if strmatch(OWNER`letter',"*Desclos*")==1
	replace OWNER`letter' = "Geslin" if strmatch(OWNER`letter',"*Geslin*")==1
	replace OWNER`letter' = "Jogues" if strmatch(OWNER`letter',"*Jogues*")==1
	replace OWNER`letter' = "Langevin" if strmatch(OWNER`letter',"*Langevin*")==1
	replace OWNER`letter' = "Arnou" if strmatch(OWNER`letter',"*Arnou*(*)*")==1
	replace OWNER`letter' = "Bertrand, Nicolas" if strmatch(OWNER`letter',"*Bertrand, Nicolas*")==1
	replace OWNER`letter' = "Castaing, François" if strmatch(OWNER`letter',"*Castaing*")==1 & strmatch(OWNER`letter',"*Castaing, Abel*")!=1

	//Dutch data
	replace OWNER`letter' = "Zitter, Jan de" if OWNER`letter' =="Zitter, Jan, de"
	replace OWNER`letter' = "Middelburgse Commercie Compagnie" if OWNER`letter' == "Middelburgsche Commercie Compagnie"

	//English data
	replace OWNER`letter' = "Tuohy, David" if strmatch(OWNER`letter',"*Tuohy*")==1
	replace OWNER`letter' = "Rogers, James" if strmatch(OWNER`letter',"*Rogers*,*James*")==1
	replace OWNER`letter' = "Lumley, Thomas" if strmatch(OWNER`letter',"*Lumley*")==1
	replace OWNER`letter' = "Davenport, William" if strmatch(OWNER`letter',"*Davenport, Wm*")==1

	//Dutch data
	replace OWNER`letter' = "Bargum Trading Society" if strmatch(OWNER`letter',"*Bargum Trading Society*")==1
}


////// Correct captain’s names TSDT
foreach letter in A B C {
	replace CAPTAIN`letter' = "Devigne, Et" if strmatch(CAPTAIN`letter', "*Devigne, E*")==1
	replace CAPTAIN`letter' = "Barkley, John" if strmatch(CAPTAIN`letter', "*Barkley,J*")==1
	replace CAPTAIN`letter' = "Berthomme, Nicolas" if strmatch(CAPTAIN`letter', "*Berthommé, Nicholas*")==1
	replace CAPTAIN`letter' = "Bodin Desplantes" if strmatch(CAPTAIN`letter', "*Bodin Desplantes*")==1
	replace CAPTAIN`letter' = "Brancker, Peter" if strmatch(CAPTAIN`letter', "*Brancker, P*")==1
	replace CAPTAIN`letter' = "Brettargh, William" if strmatch(CAPTAIN`letter', "*Brettargh, William*")==1
	replace CAPTAIN`letter' = "Callow, C" if strmatch(CAPTAIN`letter', "*Callow*")==1
	replace CAPTAIN`letter' = "Carus, Chris" if strmatch(CAPTAIN`letter', "*Carus, Chr*")==1
	replace CAPTAIN`letter' = "Chateaubriand du Plessis, Pierre-Anne-Marie" if strmatch(CAPTAIN`letter', "*Chateaubriand*")==1
	replace CAPTAIN`letter' = "Clark, William" if strmatch(CAPTAIN`letter', "*Clark, W*")==1
	replace CAPTAIN`letter' = "Clémenceau, Alexandre" if strmatch(CAPTAIN`letter', "*Cl*menceau, Al*")==1
	replace CAPTAIN`letter' = "Durocher-Sorin" if strmatch(CAPTAIN`letter', "Durocher")==1 // there are homonymes, but not around the same time//
	replace CAPTAIN`letter' = "Fowler, John" if strmatch(CAPTAIN`letter', "*Fowler, John*")==1
	replace CAPTAIN`letter' = "Guyot, Jean" if strmatch(CAPTAIN`letter', "Guyot, J")==1
	replace CAPTAIN`letter' = "La Causse, Bernard" if strmatch(CAPTAIN`letter', "*La Causse*")==1
	replace CAPTAIN`letter' = "Lawson, William" if strmatch(CAPTAIN`letter', "*Lawson, W*m*")==1
	replace CAPTAIN`letter' = "Le Sourd, J-Fr" if strmatch(CAPTAIN`letter', "*Le Sourd, J-F*")==1
	replace CAPTAIN`letter' = "Mary, Joseph" if strmatch(CAPTAIN`letter', "*Mary, Jos*")==1
	replace CAPTAIN`letter' = "Nicholson, Joseph" if strmatch(CAPTAIN`letter', "*Nicholson, Jos*")==1
	replace CAPTAIN`letter' = "Pacaud, Pierre" if strmatch(CAPTAIN`letter', "*Pacaud, P*")==1
	replace CAPTAIN`letter' = "Ringeard, Mathurin" if strmatch(CAPTAIN`letter', "*Ringeard*")==1
	replace CAPTAIN`letter' = "Smale, John" if strmatch(CAPTAIN`letter', "*Smale, Jno*")==1
	replace CAPTAIN`letter' = "Smith, John" if strmatch(CAPTAIN`letter', "*Smith, Jn*")==1
	replace CAPTAIN`letter' = "Stangeways, James" if strmatch(CAPTAIN`letter', "*Stangeways, Jas*")==1
	replace CAPTAIN`letter' = "Tanquerel, Julien-Edouard" if strmatch(CAPTAIN`letter', "*Tanquerel, J-E*")==1
	replace CAPTAIN`letter' = "Van Alstein, Pierre-Ignace-Lievin" if strmatch(CAPTAIN`letter', "*Alstein*Pierre*")==1
	replace CAPTAIN`letter' = "Vigneron, François" if strmatch(CAPTAIN`letter', "*Vigneron*")==1
	replace CAPTAIN`letter' = "Wotherspoon, Alex" if strmatch(CAPTAIN`letter', "*Wotherspoon, Alexander*")==1
}


save "${tastdb}tastdb-exp-2020.dta", replace


//////3. merge with Venture all to get an extra 47 ventures + multiple voyages
use "${output}Venture all.dta", clear
//To get an unique key
replace VOYAGEID = ventureid if voyageidintstd==""  |  voyageidintstd=="."
//This is only useful if we know the name of the captain or the outfitter
drop if nameofthecaptain=="" & nameofoutfitter==""
duplicates drop nameofthecaptain nameofoutfitter VOYAGEID, force
merge 1:1 VOYAGEID  using "${tastdb}tastdb-exp-2020.dta"
drop _merge
//Here, we assume our data on outfitter is correct
replace OWNERA= nameofoutfitter if nameofoutfitter!=""
//Here, we assume stdt on captain is correct
replace CAPTAINA= nameofthecaptain if missing(CAPTAINA)
replace YEARAF = YEARAF_own if missing(YEARAF)
/*drop if strmatch(voyageidintstd,"*/*")==1
**I would like to avoid that line. Issues with DR051, KR014 (and probably not KR016) */
drop if YEARAF==.

decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
label var MAJMAJBYIMP "African region of trade"



save "tastdb-exp-2020+own.dta", replace

// * 4. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD

use "tastdb-exp-2020+own.dta", clear
keep CAPTAINA CAPTAINB CAPTAINC YEARAF VOYAGEID MAJMAJBYIMP

capture erase "${output}Captain.dta"
 
foreach captainletter in A B C {
	drop if CAPTAIN`captainletter' == ""
	preserve
	keep CAPTAIN`captainletter' YEARAF VOYAGEID MAJMAJBYIMP
	rename CAPTAIN`captainletter' CAPTAIN
	capture append using "${output}Captain.dta"
	duplicates report CAPTAIN VOYAGEID
	save "${output}Captain.dta", replace
	restore
}
//THERE IS AN ISSUE IN TSDT DATAT
use "${output}Captain.dta", clear
duplicates drop CAPTAIN VOYAGEID, force
save "${output}Captain.dta", replace
 
save "${output}Captain.dta", replace

use "tastdb-exp-2020+own.dta", clear

 keep OWNERA /*OWNERB OWNERC OWNERD /*
 */ OWNERE OWNERF OWNERG OWNERH OWNERI OWNERJ OWNERK OWNERL OWNERM OWNERN /* 
 */ OWNERO OWNERP*/ YEARAF VOYAGEID MAJMAJBYIMP

  
capture erase "${output}OUTFITTER.dta"
 
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	drop if OWNER`letter' == ""
	preserve
	keep OWNER`letter' YEARAF VOYAGEID MAJMAJBYIMP
	rename OWNER`letter' OUTFITTER
	capture append using "${output}OUTFITTER.dta"
	save "${output}OUTFITTER.dta", replace
	restore
}

use "${output}OUTFITTER.dta", clear

//This command insures that when multiple members of the same family are listed as OUTFITTERs, they are not counted twice
bys OUTFITTER VOYAGEID YEARAF: keep if _n==1

save "${output}OUTFITTER.dta", replace

**COMPUTE EXPERIENCE TAKING INTO ACCOUNT HOMONYMES

use "${output}Captain.dta", clear
sort CAPTAIN YEARAF

sort CAPTAIN YEARAF 

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'
}


sort CAPTAIN homonyme YEARAF 
bys CAPTAIN homonyme: generate captain_total_career = _N
bys CAPTAIN homonyme: generate captain_experience= _n-1

sort CAPTAIN homonyme  MAJMAJBYIMP YEARAF
bys CAPTAIN homonyme MAJMAJBYIMP : generate captain_regional_experience= _n-1 if MAJMAJBYIMP!=""

*For multiple voyages in a year (we take the max experience)
*First line workes if all the voyages in a specific year are to the same region
collapse (min) captain_experience captain_total_career captain_regional_experience (count) nbr_in_year=captain_experience, by(CAPTAIN YEARAF homonyme MAJMAJBYIMP)
egen temp_captain_experience = min(captain_experience), by(CAPTAIN YEARAF homonyme)
replace captain_experience=temp_captain_experience if captain_experience!=temp_captain_experience
drop temp_captain_experience
save "${output}Captain.dta", replace


//Idem for OUTFITTERs


use "${output}OUTFITTER.dta", clear
drop if OUTFITTER=="" | YEARAF==.
sort OUTFITTER YEARAF

sort OUTFITTER YEARAF

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'
}


sort OUTFITTER homonyme OUTFITTER 
bys OUTFITTER homonyme: generate OUTFITTER_total_career = _N
bys OUTFITTER homonyme: generate OUTFITTER_experience= _n-1

sort OUTFITTER homonyme MAJMAJBYIMP YEARAF 
bys OUTFITTER homonyme MAJMAJBYIMP: generate OUTFITTER_regional_experience= _n-1 if MAJMAJBYIMP!=""


*First line workes if all the voyages in a specific year are to the same region
collapse (min) OUTFITTER_experience OUTFITTER_total_career OUTFITTER_regional_experience (count) nbr_in_year=OUTFITTER_experience, by(OUTFITTER YEARAF homonyme MAJMAJBYIMP)
egen temp_OUTFITTER_experience = min(OUTFITTER_experience), by(OUTFITTER YEARAF homonyme)
replace OUTFITTER_experience=temp_OUTFITTER_experience if OUTFITTER_experience!=temp_OUTFITTER_experience
drop temp_OUTFITTER_experience

save "${output}OUTFITTER.dta", replace



////////////////////////////////////////////
//////////////////////////////////////////

* MERGE OUR DATASET WITH TSTD DATASET (VOYAGES)
use "${output}Venture all.dta", clear
merge m:1 VOYAGEID using "${tastdb}tastdb-exp-2020.dta", update
drop if _merge==2
drop _merge
*erase "tastdb-exp-2020.dta"

replace YEARAF=YEARAF_own if YEARAF==.
decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
encode MAJMAJBYIMP, gen(MAJMAJBYIMP_num)
label var MAJMAJBYIMP "African region of trade"
label var MAJMAJBYIMP_num "African region of trade"



* MERGE OUR DATASET WITH TSTD DATASET (CAPTAIN)
generate CAPTAIN = ""
replace CAPTAIN = CAPTAINA
replace CAPTAIN = nameofthecaptain if CAPTAIN==""
replace CAPTAIN="" if CAPTAIN=="."
merge m:1 CAPTAIN YEARAF MAJMAJBYIMP using "${output}Captain.dta"
drop if _merge==2
*For debugging
*br CAPTAIN YEARAF ventureid VOYAGEID if _merge==1 & (CAPTAIN!="" & YEARAF !=.)
assert (CAPTAIN=="" | YEARAF ==.) if _merge==1 ///
	&  (completedataonoutlays=="yes" | completedataonoutlays=="with estimates") ///
	& (completedataonreturns=="yes" | completedataonreturns=="with estimates") 
	
drop _merge


* MERGE OUR DATASET WITH TSTD DATASET (OUTFITTER)
generate OUTFITTER = ""
replace OUTFITTER = nameofoutfitter
replace OUTFITTER = OWNERA if OUTFITTER==""
replace OUTFITTER="" if OUTFITTER=="."
merge m:1 OUTFITTER YEARAF MAJMAJBYIMP using "${output}OUTFITTER.dta"
drop if _merge==2
*For debugging
*br OUTFITTER YEARAF ventureid VOYAGEID if _merge==1 & (OUTFITTER!="" & YEARAF !=.)
assert (OUTFITTER=="" | YEARAF ==.) if _merge==1 ///
	&  (completedataonoutlays=="yes" | completedataonoutlays=="with estimates") ///
	& (completedataonreturns=="yes" | completedataonreturns=="with estimates") 




drop _merge




*erase "tastdb-exp-2020.dta"



save "${output}Venture all.dta", replace

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

save "${output}Venture all.dta", replace


*** COLLAPSE FATE-VARIABLE INTO FOUR CATEGORIES, DEPENDING ON WHETHER/WHEN SHIP WAS LOST
replace FATEcol=	1	if FATE==	1 & missing(FATEcol)
replace FATEcol=	2	if FATE==	2 & missing(FATEcol)
replace FATEcol=	2	if FATE==	3 & missing(FATEcol)
replace FATEcol=	3	if FATE==	4 & missing(FATEcol)
replace FATEcol=	2	if FATE==	11 & missing(FATEcol)
replace FATEcol=	3	if FATE==	12 & missing(FATEcol)
replace FATEcol=	2	if FATE==	23 & missing(FATEcol)
replace FATEcol=	3	if FATE==	29 & missing(FATEcol)
replace FATEcol=	4	if FATE==	30 & missing(FATEcol)
replace FATEcol=	4	if FATE==	40 & missing(FATEcol)
replace FATEcol=	2	if FATE==	44 & missing(FATEcol)
replace FATEcol=	3	if FATE==	49 & missing(FATEcol)
replace FATEcol=	2	if FATE==	50 & missing(FATEcol)
replace FATEcol=	2	if FATE==	51 & missing(FATEcol)
replace FATEcol=	3	if FATE==	54 & missing(FATEcol)
replace FATEcol=	4	if FATE==	59 & missing(FATEcol)
replace FATEcol=	3	if FATE==	68 & missing(FATEcol)
replace FATEcol=	2	if FATE==	69 & missing(FATEcol)
replace FATEcol=	4	if FATE==	70 & missing(FATEcol)
replace FATEcol=	2	if FATE==	71 & missing(FATEcol)
replace FATEcol=	2	if FATE==	74 & missing(FATEcol)
replace FATEcol=	4	if FATE==	77 & missing(FATEcol)
replace FATEcol=	3	if FATE==	78 & missing(FATEcol)
replace FATEcol=	3	if FATE==	92 & missing(FATEcol)
replace FATEcol=	3	if FATE==	95 & missing(FATEcol)
replace FATEcol=	3	if FATE==	97 & missing(FATEcol)
replace FATEcol=	3	if FATE==	122 & missing(FATEcol)
replace FATEcol=	2	if FATE==	161 & missing(FATEcol)
replace FATEcol=	4	if FATE==	172 & missing(FATEcol)

replace FATEcol=3 if FATE4>1 & !missing(FATEcol) & numberofvoyages>1

replace FATE4=1 if FATEcol==1

label var FATEcol "Fate of venture"
label define fate 1 "Voyage completed as intended" 2 "Original goal thwarted before disembarking slaves" 3 "Original goal thwarted after disembarking slaves" 4 "Unspecified/unknown"
label values FATEcol fate

replace FATEcol=4 if missing(FATEcol)
replace FATE4=4 if missing(FATE4)

****add port shares
merge m:1 YEARAF MJBYPTIMP using "${output}port_shares.dta", keep(1 3)
drop _merge


***some more variables
encode nationality, generate(nationality_num)
gen ln_SLAXIMP = ln(SLAXIMP)
label var ln_SLAXIMP "Enslaved persons emparked (ln)"

gen MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP
replace MORTALITY=VYMRTRAT if missing(MORTALITY)
label var MORTALITY "Enslaved person mortality rate"

gen crowd=SLAXIMP/TONMOD
label var crowd "Number of embarked enslaved persons per ton"

gen captain_experience_d=0 if !missing(captain_experience)
replace captain_experience_d=1 if captain_experience>0 & !missing(captain_experience)
label var captain_experience_d "Not the first voyage of the captain"


gen captain_regional_experience_d=0 if !missing(captain_regional_experience)
replace captain_regional_experience_d=1 if captain_regional_experience>0 & !missing(captain_regional_experience)
label var captain_regional_experience_d "Not the first voyage of the captain in the region"



gen captain_total_career_d=0 if !missing(captain_total_career)
replace captain_total_career_d=1 if captain_total_career>1 & !missing(captain_total_career)


gen OUTFITTER_experience_d=0 if !missing(OUTFITTER_experience)
replace OUTFITTER_experience_d=1 if OUTFITTER_experience>0 & !missing(OUTFITTER_experience)
label var OUTFITTER_experience_d "Not the first voyage of the outfitter"

gen OUTFITTER_regional_experience_d=0 if !missing(OUTFITTER_regional_experience)
replace OUTFITTER_regional_experience_d=1 if OUTFITTER_regional_experience>0 & !missing(OUTFITTER_regional_experience)
label var OUTFITTER_regional_experience_d "Not the first voyage of the outfitter in the region"

gen OUTFITTER_total_career_d=0 if !missing(OUTFITTER_total_career)
replace OUTFITTER_total_career_d=1 if OUTFITTER_total_career>1 & !missing(OUTFITTER_total_career)

encode perspectiveofsource, generate(perspective)

gen yearsq=YEARAF*YEARAF
gen ln_year=ln(YEARAF)

gen period=1 if YEARAF<1751
replace period=2 if YEARAF>1750 & YEARAF<1776
replace period=3 if YEARAF>1775 & YEARAF<1801
replace period=4 if YEARAF>1800 & !missing(YEARAF)
label define lab_period 1 "pre-1750" 2 "1751-1775" 3 "1776-1800" 4 "post-1800"
label values period lab_period
label var period "Period"

gen blif = (DATEEND-DATEDEP)/1000/60/60/24
replace length_in_days=blif if blif!=.
drop blif


gen big_port=0
replace big_port=1 if port_share>0.01 & !missing(port_share)
label var big_port "Big African slave-trading port"



save "${output}Venture all.dta", replace

