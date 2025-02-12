
if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
}

else if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
}
clear


********************************
*Work on the ventures where we can compute the profit


capture program drop profit_computation
program define profit_computation
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0" ///
	local hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0 IMP" ///
	local hyp="Imputed"

use "${output}Database for profit computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear

keep if (completedataonoutlays=="yes" | completedataonoutlays=="with estimates") ///
	& (completedataonreturns=="yes" | completedataonreturns=="with estimates" | completedataonreturns=="imputed")

sort ventureid

* NUMBER THE INDIVIDUAL OBSERVATIONS FOR EACH VENTURE, AND KEEP THE PROFIT ESTIMATES ONLY FOR ONE OBSERVATION PER VENTURE


gen profit= totalnetreturn/ totalnetexp-1
bysort ventureid: gen seq=_n
replace profit=. if seq>1
label var profit "(Net returns over net outlays) -1"


**Compute the silver value of the total investment


gen totalnetexp_silver_ship = totalnetexp_silver / shareoftheship / numberofvoyages
label var totalnetexp_silver_ship "Total net expenditure in grams of silver for the whole ship"
gen ln_totalnetexp_silver_ship = ln(totalnetexp_silver_ship)
label var ln_totalnetexp_silver_ship "Net expenditure on venture (ln(silver grams))"

gen totalnetexpperton=totalnetexp_silver_ship/TONMOD

**Generate a couple of further variables for the analysis
gen investment_per_slave = totalnetexp_silver_ship/SLAXIMP
label var investment_per_slave "Total net expenditure in g. of silver per enslaved person"
gen investment_per_slavekg = investment_per_slave/1000
label var investment_per_slavekg "Total net expenditure in kg of silver per enslaved person"
gen ln_length_in_days=ln(length_in_days)

*save "${output}Problemid.dta", replace
*erase "${output}Database for profit computation.dta"

save "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", replace

if "`hyp'"=="Baseline"  | "`hyp'"=="Imputed" ///
	save "${output}Ventures&profit_`hyp'.dta", replace


end

* order of the profit hypotheses: OR VSDO VSDR VSDT VSRV VSRT INV INT


profit_computation 0.5 1 1 0 1 0 1 0 /*Baseline, right ?*/




profit_computation . 1 1 0 1 0 1 0
/*For test VSDT*/

profit_computation . 1 1 1 1 0 1 0



profit_computation 0 1 1 0 1 0 1 0

profit_computation 1 1 1 0 1 0 1 0


* FURTHER ROBUSTNESS TESTS
*assuming that no insurance was purchased if we have no positive proof that it was

profit_computation 0.5 1 1 0 1 0 0 0
* assuming a 50% higher value of the ship relative to cost of other outlays that we assume in baseline

profit_computation 0.5 1.5 1 0 1 0 1 0
* assuming that depreciation was only 10% rather than the 25% we assume in baseline.

profit_computation 0.5 1 0.83 0 1.2 0 1 0
* assuming that insurance was purchased on all ventures, even for the ones where the accounts we have seem to suggest total outlays.

profit_computation 0.5 1 1 0 1 0 1 1
* assuming that value of the ship was not included in the accounts where the accounts we have seem to suggest total outlays/returns

profit_computation 0.5 1 1 1 1 1 1 0
* assuming both of the above

profit_computation 0.5 1 1 1 1 1 1 1
