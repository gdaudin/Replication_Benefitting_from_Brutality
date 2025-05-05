
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
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0" ///
	local hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0 IMP" ///
	local hyp="Imputed"


*****Just nationality and period

use "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear
keep ventureid profit
merge 1:m ventureid using "${output}voyages.dta"
keep VOYAGEID profit
merge 1:1 VOYAGEID using "${output}STDT_enriched.dta"


keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10
keep if YEARAF >= 1750 & YEARAF <=1795

tab period 

tab NATIONAL_tab3

svyset VOYAGEID, rake(bn.period bn.NATIONAL,totals(1782 3237 387 2519 5110 571 2244 7925, copy))
svy : mean profit




blif

***To recovert total (and hence) mean tonnage in the sample

egen sumTONMOD=total(TONMOD)
global totalTONMOD_support=sumTONMOD[1]

summarize TONMOD
global nbr_obs_ton=r(N)

summarize NATIONAL
global nbr_obs=r(N)



*****For population totals
gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3
egen Fate_x_National=group(FATE_3c NATIONAL)
collapse (count) pop_size_Fate_x_National=NATIONAL, by(Fate_x_National)

save "${output}pop_totals.dta", replace



*****For margins 
use "${output}STDT_enriched.dta", clear
keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10
keep if YEARAF >= 1750 & YEARAF <=1795
gen pop = 1
***For Fate_x_National
gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3
egen Fate_x_National=group(FATE_3c NATIONAL)
total pop, over(Fate_x_National, nolab)
matrix mat_Fate_x_National=e(b),e(N)

matrix colnames mat_Fate_x_National = ""
matrix rownames mat_Fate_x_National = ""




**Using war and peace for periods
gen period=1 if YEARAF<=1755
replace period=1 if YEARAF >1755 & YEARAF<=1762
replace period=2 if YEARAF >1762 & YEARAF <=1777
replace period=3 if YEARAF >1777 & YEARAF <=1783
replace period=4 if YEARAF >1783 & YEARAF <=1792
replace period=4 if YEARAF >1792 & !missing(YEARAF)

assert !missing(period) if sample==1


total pop, over(period, nolab)
matrix mat_period=e(b)
matrix rownames mat_period=period

**** The same without the missing TONMOD
drop if TONMOD==.
total pop, over(period, nolab) 
matrix mat_period_with_ton=e(b)
matrix rownames mat_period_with_ton=period

total pop, over(Fate_x_National, nolab)
matrix mat_Fate_x_National_with_ton=e(b)
matrix colnames mat_Fate_x_National_with_ton = ""
matrix rownames mat_Fate_x_National_with_ton = ""

total pop, over(FATE_3c, nolab)
matrix mat_Fate_with_ton=e(b),e(N)

total pop, over(NATIONAL, nolab)
matrix mat_National_with_ton=e(b),e(N)

****And now to analysis

use "${output}voy_weight.dta", clear


egen Fate_x_National=group(FATE_3c NATIONAL)

merge m:1 Fate_x_National using "${output}pop_totals.dta"
drop _merge

merge m:1 ventureid using "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta"

keep if _merge==3



gen pweight = $nbr_obs/_N


mean profit


***** Comparing profit with "by hand" post-stratification and use of svy command
svyset VOYAGEID [pw=pweight], poststrata(Fate_x_National) postweight(pop_size_Fate_x_National)
svy : mean profit
matrix list mat_Fate_x_National

svyset VOYAGEID [pw=pweight], rake(bn.Fate_x_National, totals(4219 530 1822 795 36 355 96 5 67 7925, copy))

matrix mat_Fate_x_National =  (4219,   530,  1822,   795,    36,   355,    96,     5,    67,  7925)
/*This does not work and I do not understand why...
matrix list mat_Fate_x_National

svyset VOYAGEID [pw=pweight], rake(bn.Fate_x_National, totals(mat_Fate_x_National))

*/
svy : mean profit
mean profit [pw=post_wt]

**Standard error is very slightly smaller with svy. The first two give exactly the right number


***** Comparing profit with "by hand" post-stratification + ipfraking  and use of svy command
**No : you cannot use both postrata and rake...
matrix list mat_period
svyset VOYAGEID [pw=pweight],  rake(bn.period bn.Fate_x_National, totals(1782 3237 387 2519  4219 530 1822 795 36 355 96 5 67 7925, copy))
svy : mean profit
mean profit [pw=frak_post_wt]

svyset VOYAGEID [pw=frak_post_wt]
svy: mean profit

**There is a relatively small difference... Easy to explain with 2 steps or 1 step ?
**And now with tonnage


matrix list mat_Fate_x_National_with_ton
matrix list mat_period_with_ton


svyset VOYAGEID [pw=pweight], rake(bn.period bn.Fate_x_National TONMOD,totals(1692 3077 335 1486  4140 344 986 758 23 222 92 2 23 $totalTONMOD_support $nbr_obs_ton , copy))
svy : mean profit

svyset VOYAGEID [pw=post_wt], rake(TONMOD,totals(TONMOD=$totalTONMOD_support _cons=$nbr_obs_ton))
svy : mean profit

svyset VOYAGEID [pw=frak_post_wt], rake(TONMOD,totals(TONMOD=$totalTONMOD_support _cons=$nbr_obs_ton))
svy : mean profit


******
**New option : without crossing Fate and National
matrix list mat_Fate_with_ton
matrix list mat_National_with_ton
matrix list mat_period_with_ton

svyset VOYAGEID [pw=pweight], rake(bn.period bn.FATE_3c bn.NATIONAL TONMOD,totals(1692 3077 335 1486 5470 1003 117 4990 369 1231 $totalTONMOD_support $nbr_obs_ton , copy))
svy : mean profit


end 

profit_analysis_survey 0.5 1 1 0 1 0 1 0

break
