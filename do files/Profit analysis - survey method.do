
clear
*ssc install estout, replace
*ssc install outreg2, replace


if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tastdb "$dir/script guillaume-claire-judith/"
	global slaves "$dir/script guillaume-claire-judith/slaves/"
	global graphs "$dir/graphs"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
	global slaves "$dir\do files\script guillaume-claire-judith\slaves\"
	global graphs "$dir\graphs"
}


capture program drop profit_analysis_survey
program define profit_analysis_survey
args HYP
*eg profit_analysis OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 for the baseline


if "`HYP'"=="French" | "`HYP'"== "British" | "`HYP'"== "Dutch" {
	use "${output}Ventures&profit_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.dta", clear
}
else {
	use "${output}Ventures&profit_`HYP'.dta", clear
}

keep ventureid profit
merge 1:m ventureid using "${output}voyages.dta"
keep VOYAGEID profit
merge 1:1 VOYAGEID using "${output}STDT_enriched.dta"


keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10
keep if YEARAF >= 1750 & YEARAF <=1795
label list labels19
if "`HYP'"== "French" keep if NATIONAL==10 
if "`HYP'"== "French" keep if YEARAF>=1763
if "`HYP'"== "French" drop if YEARAF>=1778 & YEARAF <=1783 
if "`HYP'"== "British" keep if NATIONAL==7
if "`HYP'"== "Dutch" keep if NATIONAL==8 

**Without raking
collect get, tags(raking[none] hyp[`HYP']) : mean profit

*********
*****Just nationality and period
**********

***Extracting matrixes to use with rake
tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'"!= "British" & "`HYP'"!= "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list= "`regressor_list' bn.NATIONAL"
}

macro list

local support_size=_N
display "rake(`regressor_list', totals(for_rake `support_size', copy))"
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))

collect get, tags(raking[nat_period] hyp[`HYP']) : svy : mean profit


***********
****Adding fate and mortality
************
gen FATE_forraking=FATE4
replace FATE_forraking=. if FATE_forraking==4
replace FATE_forraking=2 if FATE_forraking==3





preserve
drop if FATE_forraking==.
local support_size=_N


tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'"!= "British" & "`HYP'"!= "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list = "`regressor_list' bn.NATIONAL"
}


tabulate FATE_forraking, matcell(FATE_forraking)
matrix for_rake = for_rake, FATE_forraking'
local regressor_list= "`regressor_list' bn.FATE_forraking"


display "rake(`regressor_list', totals(for_rake `support_size', copy))"
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))
display "bn.period bn.NATIONAL bn.FATE_forraking"
svy : mean profit
restore



preserve
drop if MORTALITY==.
local support_size=_N

tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'"!= "British" & "`HYP'"!= "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list= "`regressor_list' bn.NATIONAL"
}


egen sumMORTALITY=total(MORTALITY)
global totalMORTALITY_support=sumMORTALITY[1]

matrix for_rake = for_rake, $totalMORTALITY_support
local regressor_list= "`regressor_list' MORTALITY"

display "rake(`regressor_list', totals(for_rake `support_size', copy))"
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))
display "bn.period bn.NATIONAL MORTALITY"
svy : mean profit
restore

preserve
drop if MORTALITY==.
drop if FATE_forraking==.
local support_size=_N


tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'"!= "British" & "`HYP'"!= "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list= "`regressor_list' bn.NATIONAL"
}


egen sumMORTALITY=total(MORTALITY)
global totalMORTALITY_support=sumMORTALITY[1]
matrix for_rake = for_rake, $totalMORTALITY_support
local regressor_list= "`regressor_list' MORTALITY"

tabulate FATE_forraking, matcell(FATE_forraking)
matrix for_rake = for_rake, FATE_forraking'
local regressor_list= "`regressor_list' bn.FATE_forraking"


display "rake(`regressor_list', totals(for_rake `support_size', copy))"
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))
display "bn.period bn.NATIONAL bn.FATE_forraking MORTALITY"
svy : mean profit
restore

***********
****Adding crowding
************

preserve
drop if crowd==.
local support_size=_N


tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'" != "British" & "`HYP'" != "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list= "`regressor_list' bn.NATIONAL"
}


egen sumcrowd=total(crowd)
global totalcrowd_support=sumcrowd[1]
local regressor_list= "`regressor_list' crowd"
matrix for_rake = for_rake, $totalcrowd_support 


display "rake(`regressor_list', totals(for_rake `support_size', copy))"
matrix list for_rake
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))
display "bn.period bn.NATIONAL  crowd"
if "`HYP'"!="French" svy : mean profit
restore

preserve
drop if crowd==. | MORTALITY==. | FATE_forraking==.
local support_size=_N

tabulate period, matcell(period_mat)
matrix for_rake = period_mat'
local regressor_list= "bn.period"

if "`HYP'"!="French" & "`HYP'"!= "British" & "`HYP'"!= "Dutch" {
	tabulate NATIONAL_tab3, matcell(NATIONAL_mat)
	matrix for_rake = for_rake, NATIONAL_mat'
	local regressor_list= "`regressor_list' bn.NATIONAL"
}

egen sumcrowd=total(crowd)
global totalcrowd_support=sumcrowd[1]
local regressor_list= "`regressor_list' crowd"
matrix for_rake = for_rake, $totalcrowd_support 

tabulate FATE_forraking, matcell(FATE_forraking)
matrix for_rake = for_rake, FATE_forraking'
local regressor_list= "`regressor_list' bn.FATE_forraking"


display "rake(`regressor_list', totals(for_rake `support_size', copy))"
svyset ventureid, rake(`regressor_list', totals(for_rake `support_size', copy))
display "bn.period bn.NATIONAL bn.FATE_forraking MORTALITY crow"
if "`HYP'"!="French" collect get, tags(raking[all] hyp[`HYP']) : svy : mean profit
restore

end 


////////// 
*****For appendix
////////////////





global hyp_list 	OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					French British Dutch ///	
					OR._VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR1_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1.5_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR0.83_VSDT0_VSRV1.2_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV0_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT1 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT1
*					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0IMP /// 
*					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0onlyIMP
*/




global hyp_list_name `""Baseline" "Only French" "Only British" "Only Dutch" "Without Observations with outstanding claims"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to not have been paid at all"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to have been paid in full"'
global hyp_list_name `"$hyp_list_name" "Higher cost of hull relative to other outlays (25% instead of 17% in baseline)"'
global hyp_list_name `"$hyp_list_name" "Lower rate of depreciation (10% instead of baseline 25%)"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance not added to any voyages"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays"'
global hyp_list_name `"$hyp_list_name" "Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns"'
*global hyp_list_name `"$hyp_list_name" "Baseline including imputed profits"'
*global hyp_list_name `"$hyp_list_name" "Baseline including only imputed profits""'



tokenize `"$hyp_list_name"'
macro list
display "`1'"

collect clear
local label_list
local i 1
foreach hyp of global hyp_list {
	profit_analysis_survey `hyp'
	local label_list `label_list' `hyp' "``i''"
	local i = `i'+1
}

macro list

collect label levels hyp `label_list', replace
collect label levels raking none "No raking" nat_period "Nationality and period" all "All", replace
collect label levels result _r_b mean _r_ci "95% ci" N "Nbr. of observations", replace
collect style cell result[_r_ci], sformat([%s]) cidelimiter(, )
collect style cell result[_r_b _r_ci], nformat(%4.2fc)
collect style cell hyp[none nat_period all]#result[_r_b _r_ci N], halign(center)
*collect style header result, halign(left)
collect layout (hyp#result[_r_b _r_ci N]) (raking)

collect export "${output}Profit analysis survey robustess.docx", as(docx) replace


break
