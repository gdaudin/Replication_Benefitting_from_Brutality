
clear



* MERGE WITH initial venture file
use "${output}Ventures+TSTD variables.dta", clear
merge 1:1 ventureid  using "${output}Venture all.dta"

tab completedataonoutlays completedataonreturns if _merge==2
tab ventureid if _merge==2 & completedataonoutlays=="yes" & completedataonreturns=="yes"

assert completedataonoutlays =="no" | completedataonreturns =="no" if _merge==2
*drop if completedataonoutlays =="no" | completedataonreturns =="no"
drop _merge


encode nationality, generate(nationality_num)
gen ln_SLAXIMP = ln(SLAXIMP)
label var ln_SLAXIMP "Enslaved persons emparked (ln)"

gen MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP
replace MORTALITY=VYMRTRAT if missing(MORTALITY) | MORTALITY<=0
replace MORTALITY=0 if MORTALITY<0
label var MORTALITY "Enslaved people mortality rate"


gen period=1 if YEARAF<1751
replace period=2 if YEARAF>1750 & YEARAF<1776
replace period=3 if YEARAF>1775 & YEARAF<1801
replace period=4 if YEARAF>1800 & !missing(YEARAF)
label define lab_period 1 "pre-1750" 2 "1751-1775" 3 "1776-1800" 4 "post-1800"
label values period lab_period
label var period "Period"

save "${output}Enriched ventures.dta", replace
erase "${output}Ventures+TSTD variables.dta"

