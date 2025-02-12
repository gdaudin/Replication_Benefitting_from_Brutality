* Do file to identify problem in profit rate 



* 0. PREAMBLE 
clear all 
if lower(c(username)) == "kraemer" {
	!subst X: /d
	!subst X:   "C:\Users\Kraemer\Documents"
	capture cd "X:\slaveprofits\"
	if _rc != 0 cd  "C:\Users\Kraemer\Documents\slaveprofits"
	global output "C:\Users\Kraemer\Documents\slaveprofits\script claire\output"
	global other "C:\Users\Kraemer\Documents\slaveprofits\script claire"
	global slaves "C:\Users\Kraemer\Documents\slaveprofits\script claire\slaves"
	global dofile "C:\Users\Kraemer\Documents\slaveprofits\script claire\do"
		}

else if lower(c(username)) == "claire" {
	!subst X: /d
	!subst X:   "/Users/claire/"
	capture cd "X:/slaveprofits/"
	if _rc != 0 cd  "/Users/claire/slaveprofits/"
	global output "/Users/claire/Desktop/temp"
	global others "/Users/claire/slaveprofits/script claire"
	global dofile "/Users/claire/slaveprofits/script claire/do"
}

else if lower(c(username)) == "guillaumedaudin" {
	*set trace on
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global others "$dir/script claire/"
	global slaves "$dir/script claire/slaves/"
	global dofile "$dir/script claire/do/"

}


qui do "${dofile}/Command IRR.do"
import delimited "./Cash flow database GD.csv"





drop if ventureid == "GD137" // we only have expenses not returns 

* 1. DETECT THE VENTURE WHERE IRR IS COMPUTABLE 

	bys venture dateof: gen count = _n if dateof == ""
	levelsof ventureid if count == 1, local(levels) // see all venture for which computation is NOT 
foreach vent of local levels {
    drop if ventureid == "`vent'" 
} // drop ventures where computaion is not feasible
	gen valueabs = value 
	replace valueabs = -value if typeof == "Expenditure"
	bys venture dateof: egen totaltransac = sum(valueabs)
	drop if totaltransac[_n] == totaltransac[_n+1]
	keep venture dateof totaltransac
	

* 2 YEARLY IRR 	
	gen date = date(dateoftransaction, "YMD")
	gen date2 = date(dateoftransaction, "Y")
	gen date3 = date(dateoftransaction, "YM")
	gen yearly_date  = date 
	replace yearly_date = date2 if yearly_date ==.
	replace yearly_date = date3 if yearly_date ==.
	replace yearly_date = yofd(yearly_date)
	bys venture yearly_date: egen totaltransac_year = sum(totaltransac)
	drop if totaltransac_year[_n] == totaltransac_year[_n+1]
	bys ventureid : gen count = _n 
	fillin venture yearly_date
	recode totaltransac_year (.= 0)
	keep venture totaltransac_year yearly_date count
	
	
levelsof venture, local(mylevs)
gen irr = .


	foreach v of local mylevs {
	preserve 
	dis "`v'"
	qui {
	keep if venture == "`v'"
	levelsof yearly_date if count == 1, local(year_min)
	su count, meanonly 
	local max = r(max)
	levelsof yearly_date if count == `max' , local(year_max)
	keep if year >= `year_min' & year <= `year_max'
	gen unit = _n
	su unit 
	local t = r(max)
	egen totaltransac_sum = sum(totaltransac_year)
	su totaltransac_sum
	local scf =  r(mean)
	su unit, meanonly 
	local t = r(max)
	scalar sum0 = 0
	}
	forval i = -1(0.0001)1{
		*dis "`i'"
		forval y = 1/`t'{
		local sum`t'= 1
		scalar year`y' = totaltransac_year[`y']/((1+`i')^`y')
		local j = `y' - 1
		scalar sum`y' = sum`j' + year`y'
		*dis sum`y'
		}
		if  sum`t'>= 0  & sum(`t'-1) <= 0 | sum`t'<= 0  & sum(`t'-1) >= 0 {
			dis `i'
			local irr = `i'
			continue, break
 
		}
	}
		restore
		dis "`v'"
		replace irr = `irr' if ventureid == "`v'"
	}
	
	bys venture: gen obs = _n
	keep if obs==1
	keep ventureid irr

	
	replace irr = irr *100 // have a rate in percentage 
	
	
	
* COMPARE WITH 2004 RESULTS 
	
	preserve
	tempfile tmp
	import delimited "${others}/IRR in slavery accounts JEH 2004.csv", clear 
	keep v1 nomdu tauxderentabilité 
	rename v1 ventureid
	rename tauxderentabilité irr_2004
	save `"`tmp'"'
	restore
	merge m:m ventureid using `"`tmp'"', nogen 
	
	*Compare 
	replace irr_2004 = subinstr(irr_2004,"%","",.)
	replace irr_2004 = subinstr(irr_2004,",",".",.)
	destring irr_2004, replace 
	
	gen diff= abs(irr - irr_2004)
	gen results= "OK" if diff < 5
	replace result = "OK, new value " if irr != . & irr_2004 == .
	replace result = "Substantial mismatch" if diff >= 5 & irr != . & irr_2004 !=.
	
	export delimited using "${others}/IRR1_JEH2004-now.csv", replace 
	
	

* 2 MONTHLY IRR 	

import delimited "./Cash flow database GD.csv" , clear 
drop if ventureid == "GD137" // we only have expenses not returns 
bys venture dateof: gen count = _n if dateof == ""
	levelsof ventureid if count == 1, local(levels) // see all venture for which computation is NOT 
foreach vent of local levels {
    drop if ventureid == "`vent'" 
} // drop ventures where computaion is not feasible
	gen valueabs = value 
	replace valueabs = -value if typeof == "Expenditure"
	bys venture dateof: egen totaltransac = sum(valueabs)
	drop if totaltransac[_n] == totaltransac[_n+1]
	keep venture dateof totaltransac
	

	gen date = date(dateoftransaction, "YMD")
	gen date2 = date(dateoftransaction, "Y")
	gen date3 = date(dateoftransaction, "YM")
	gen monthly_date  = date 
	replace monthly_date = date2 if monthly_date ==.
	replace monthly_date = date3 if monthly_date ==.
	replace monthly_date = mofd(monthly_date)
	format monthly_date %tm
	bys venture monthly_date: egen totaltransac_month = sum(totaltransac)
	drop if totaltransac_month[_n] == totaltransac_month[_n+1]
	bys ventureid : gen count = _n 
	fillin venture monthly_date
	recode totaltransac_month (.= 0)
	keep venture totaltransac_month monthly_date count
	
	
levelsof venture, local(mylevs)
gen irr = .


	foreach v of local mylevs {
	preserve 
	dis "`v'"
	qui {
	keep if venture == "`v'"
	levelsof monthly_date if count == 1, local(year_min)
	su count, meanonly 
	local max = r(max)
	levelsof monthly_date if count == `max' , local(year_max)
	keep if monthly_date >= `year_min' & monthly_date <= `year_max'
	gen unit = _n
	su unit 
	local t = r(max)
	egen totaltransac_sum = sum(totaltransac_month)
	su totaltransac_sum
	local scf =  r(mean)
	su unit, meanonly 
	local t = r(max)
	scalar sum0 = 0
	}
	forval i = -1(0.0001)1{
		*dis "`i'"
		forval y = 1/`t'{
		local sum`t'= 1
		scalar year`y' = totaltransac_month[`y']/((1+`i')^`y')
		local j = `y' - 1
		scalar sum`y' = sum`j' + year`y'
		*dis sum`y'
		}
		if  sum`t'>= 0  & sum(`t'-1) <= 0 | sum`t'<= 0  & sum(`t'-1) >= 0 {
			dis `i'
			local irr = `i'
			continue, break
 
		}
	}
		restore
		dis "`v'"
		replace irr = `irr' if ventureid == "`v'"
	}
	

bys venture: gen obs = _n
keep if obs==1
keep ventureid irr
	
replace irr = ((1+irr)^12)-1
replace irr = irr * 100
ren irr irr_monthly
export delimited using "${others}/IRR2_JEH2004-now", replace


* MERGE 

clear 
import delimited "${others}/IRR1_JEH2004-now.csv"
preserve
tempfile tmp 
import delimited "${others}/IRR2_JEH2004-now.csv", clear 
save "`tmp'"
restore 
merge m:m venture using "`tmp'", nogen 

export delimited using "${others}/IRR_JEH2004-now", replace


	
	