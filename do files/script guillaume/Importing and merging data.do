*version 16.1

if "`c(username)'" == "guillaumedaudin" global dir_git "~/Répertoires GIT/slaveprofits data and programs"
if "`c(username)'" == "guillaumedaudin" global dir_stata "~/Documents/Recherche/2019 Profits of slavery/Stata slavery"
if "`c(username)'" == "xronkl" global dir_git "C:\Users\xronkl\ShareFile\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits\"
if "`c(username)'" == "xronkl" global dir_stata "C:\Users\xronkl\ShareFile\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\STATA\"


******Cashflow db treatment

local cash_flow_files `" "Cash flow database GD" "Cash flow database GK" "Cash flow database KR - new" "Cash flow database DR" "'


*For latter : "Cash flow database MR- new"



local i 1

foreach file of local cash_flow_files {
	import delimited using "$dir_git/`file'.csv", clear encoding(utf-8) varnames(1) stringcols(_all) case(lower) 
	capture	replace value  =usubinstr(value,",",".",.)
	destring value, replace float
	destring estimate, replace
	save "$dir_stata/`file'.dta", replace	
	if `i' !=1 append using "$dir_stata/Cash flow database.dta"
	save "$dir_stata/Cash flow database.dta", replace
	local i `i'+1	
}

export delimited using "$dir_git/Cash flow database.csv", replace



******Venture db

local venture_files `" "Venture database GD" "Venture database GK" "Venture database KR - new" "Venture database DR" "'
local var_for_destring profitsreportedinsource shareoftheship numberofslavespurchased numberofslavessold

local i 1
foreach file of local venture_files {
	import delimited using "$dir_git/`file'.csv", clear encoding(utf-8) varnames(1) stringcols(_all) case(lower) 
	capture	replace shareoftheship  =usubinstr(shareoftheship,",",".",.)
	foreach var of local var_for_destring {
		destring `var', replace float
	}	
	save "$dir_stata/`file'.dta", replace	
	if `i' !=1 append using "$dir_stata/Venture database.dta"
	save "$dir_stata/Venture database.dta", replace
	local i `i'+1	
}

use "$dir_stata/Venture database.dta", clear
/*
rename dateofdeparturefromportofoutfitt dateofdepartureportofoutfitt
rename date* d_*
local var_for_dates d_ofdepartureportofoutfitt d_ofprimarysource d_tradebeganinafrica d_ofdeparturefromafrica d_vesselarrivedwithslaves d_ofreturntoportofoutfitting /*dateofreturntoeurope dateofdeparturefromeurope*/



foreach var of local var_for_dates {
	gen year1=substr( `var',1,4)
	gen month1=substr( `var',6,2)
	gen day1=substr( `var',9,2)
	destring year1, replace
	destring month1, replace
	destring day1, replace
	local var_short = subinstr("`var'","date","",.)
	gen m`var_short' = month1
	replace month1=1 if missing(month1) & year1<.
	replace day1=1 if missing(day1) & year1<.
	gen date1=mdy(month1, day, year)
	format date1 %d
	drop year1 month1 day1 
	ren `var' `var'_s
	ren date1 `var'
}

/*
replace dateofdepartureportofoutfit= dateofdeparturefromeurope if dateofdeparturefromeurope<. & dateofdeparturefromportofoutfit==.
replace dateofreturntoportofoutfitting= dateofreturntoeurope if dateofreturntoeurope<. & dateofreturntoportofoutfitting==.
drop dateofdeparturefromeurope dateofreturntoeurope
*/
foreach var of local var_for_dates {
	gen y_of_`var'=year(`var')
}



gen yearmin= y_of_d_of_departurefromportofoutfit
replace yearmin= y_of_tradebeganinafrica if yearmin==.
replace yearmin= y_of_departurefromafrica if yearmin==.
replace yearmin= y_of_vesselarrivedwithslaves if yearmin==.
replace yearmin= y_of_returntoportofoutfitting if yearmin==.
*/

save "$dir_stata/Venture database.dta"

******************


blif
/*

gen VOYAGEID= voyageidintstd
destring VOYAGEID, force replace
merge m:1 VOYAGEID using "C:\Users\xronkl\ShareFile\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\STATA\tastdb-exp-2020.dta"
drop if _merge==2
drop _merge
*/


******** Clash flow classification
import delimited using "$dir_git/Cash flow classification.csv", clear encoding(utf-8) varnames(1) stringcols(_all) case(preserve)
gen str2000 blouk=specification
drop specification
rename blouk specification
save "$dir_stata/Cash flow classification.dta", replace



******** Merge to cash flow classification

use "$dir_stata/Cash flow database.dta", clear
bysort specification: keep if _n==1
keep specification
merge 1:m specification using "$dir_stata/Cash flow classification.dta"
sort specification
drop _merge
save "$dir_stata/Cash flow classification.dta", replace
export delimited using "$dir_git/Cash flow classification.csv", replace


********Big flat database

use "$dir_stata/Venture database.dta", clear
merge 1:m ventureid using "$dir_stata/Cash flow database.dta"
tab ventureid if _merge!=3
drop if _merge!=3
assert _merge!=2
drop _merge
merge m:1 specification using "$dir_stata/Cash flow classification.dta"

assert _merge!=1
drop if _merge!=3
drop _merge

save "$dir_stata/Flat database.dta", replace
export delimited using "$dir_git/Flat database.csv", replace



