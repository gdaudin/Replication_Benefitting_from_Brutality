
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
*"

capture program drop profit_computation_db
program define profit_computation_db
args OR VSDO VSDR VSDT VSRV VSRT INV INT
*eg profit_computation 0.5 1 1 0 1 0 1 0 for the baseline
**you can put a dot when you want to exclude ventures depending on a particular hypothesis


use "${output}Cash flow all.dta", clear
assert ventureid !=""

**Applying the hypotheses (counting the number of them that apply first)
foreach hypo in OR VSDO VSDR VSDT VSRV VSRT INV INT {
	gen nbr_`hypo' = 0
	replace nbr_`hypo' = 1 if strmatch(hypothesis,"*`hypo'*")==1 
	replace nbr_`hypo' = 2 if strmatch(hypothesis,"*`hypo'*`hypo'*")==1 
	replace nbr_`hypo' = 3 if strmatch(hypothesis,"*`hypo'*`hypo'*`hypo'*")==1 
	replace nbr_`hypo' = 4 if strmatch(hypothesis,"*`hypo'*`hypo'*`hypo'*`hypo'*")==1 
	replace nbr_`hypo' = 5 if strmatch(hypothesis,"*`hypo'*`hypo'*`hypo'*`hypo'*`hypo'*")==1 
	
	replace value=value*``hypo'' if nbr_`hypo' !=0
	replace value=value*``hypo''^(nbr_`hypo'-1) if nbr_`hypo' !=0 & value !=.

	**This means for example that if the OR hypothesis is 0.5, then the value in the database is multiplied by 0.5, if it is 1, then it is not changed, if it is 0, then it is set to zero.
	
	*drop nbr
}

egen missing = max(value), by(ventureid) missing
drop if missing==.
drop missing

* ASSUMPTION ABOUT THE TIMING OF INSURANCE PAYMENTS FOR OBS WHERE EXACT TIMING IS UNKNONWN, 
*I.E. THEY ARE NOW ASSUMED TO HAVE BEEN PAID ONLY AFTER THE VOYAGE FOR THE FRENCH (ie GD’s ventures), AFTER FOR OTHERS

replace timing="Return" if strpos(ventureid,"GD")!=0 & ///
	(timing=="Unknown" & specification=="Insurance" |  timing=="Unknown" & specification=="Assurances" | timing=="Unknown" & specification=="Insurance (Assurances)")

replace timing="Outfitting" if strpos(ventureid,"GD")==0 & ///
	(timing=="Unknown" & specification=="Insurance" |  timing=="Unknown" & specification=="Assurances" | timing=="Unknown" & specification=="Insurance (Assurances)")


* FILL IN INFORMATION ON TWO DUMMY VARS, ASSUMING BOTH OF THESE TO TAKE THE VALUE OF ZERO, IF MISSING.
replace intermediarytradingoperation=0 if missing(intermediarytradingoperation)
*replace estimate=0 if missing(estimate)


* MERGE CASH FLOW AND VENTURE-DATABASES INTO ONE
merge m:1 ventureid using "${output}Enriched ventures.dta", nogen


drop if value==.

drop if nationality==""
drop if intermediarytradingoperation==1


save "${output}Database for IRR computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.dta", replace

*Assign a transaction year when absent and assignement is possible
assert mod(transaction_year,1)==0 | transaction_year==.
replace transaction_year=int(yearofdeparturefromportofoutfit) if transaction_year==. & (timing=="Outfitting" | timing=="After outfitting")
assert mod(transaction_year,1)==0 | transaction_year==.
replace transaction_year=int(YEARDEP) if transaction_year==. &  (timing=="Outfitting" | timing=="After outfitting") & numberofvoyages==1
replace transaction_year=int(YEARAF) if transaction_year==. &  (timing=="Outfitting" | timing=="After outfitting") & numberofvoyages==1
assert mod(transaction_year,1)==0 | transaction_year==.
egen yearmax=max(transaction_year), by(ventureid timing)
assert mod(transaction_year,1)==0 | transaction_year==.
replace transaction_year=yearmax  if transaction_year==. &  (timing=="Return" | timing=="Transactions during voyage")
drop yearmax
replace transaction_year=int(yearofreturntoportofoutfitting) if transaction_year==. & (timing=="Return" | timing=="Transactions during voyage")
assert mod(transaction_year,1)==0 | transaction_year==.
*replace transaction_year=year(DATEEND/100000000) if transaction_year==. &  timing=="Return"
replace transaction_year=int(YEARAF)+1 if transaction_year==. &  (timing=="Return" | timing=="Transactions during voyage")
assert mod(transaction_year,1)==0 | transaction_year==.

* Change all cash flows in grams of silver for the whole ship
replace value = value *2/3 if currency =="Livres coloniales" | currency == "Livres des colonies"
replace currency = "Livres tournois" if currency =="Livres" | currency =="Livres coloniales" | currency == "Livres des colonies"

merge m:1 transaction_year currency using  "${output}Exchange rates in silver.dta" 
replace conv_in_silver = 4.5 if currency=="Francs"
drop if _merge==2 


gen value_silver = value * conv_in_silver
tab ventureid if value_silver ==. & value !=.

drop _merge

gen value_silver_ship = value_silver / shareoftheship



* GENERATE FOUR VARIABLES - EXPENDITURE, DISCOUNT, RETURN AND COSTONRETURN - BASED ON THE TYPE AND TIMING OF TRANSACTIONothi
* both in currency and silver

gen expenditure=value if typeofcashflow=="Expenditure" & (timing=="Outfitting" | timing=="After outfitting") & intermediarytradingoperation==0
replace expenditure=0 if missing(expenditure)

gen discount=value if typeofcashflow=="Return" & (timing=="Outfitting" | timing=="After outfitting") & intermediarytradingoperation==0
replace discount=0 if missing(discount)

gen return=value if typeofcashflow=="Return" & (timing=="Return" | timing=="Transactions during voyage") & intermediarytradingoperation==0

gen costonreturn=value if typeofcashflow=="Expenditure" & (timing=="Return" | timing=="Transactions during voyage") & intermediarytradingoperation==0
replace costonreturn=0 if missing(costonreturn)

**Silver
gen expenditure_silver=value_silver if typeofcashflow=="Expenditure" & (timing=="Outfitting" | timing=="After outfitting") & intermediarytradingoperation==0
replace expenditure_silver=0 if missing(expenditure_silver)

gen discount_silver=value_silver if typeofcashflow=="Return" & (timing=="Outfitting" | timing=="After outfitting") & intermediarytradingoperation==0
replace discount_silver=0 if missing(discount_silver)

gen return_silver=value_silver if typeofcashflow=="Return" & (timing=="Return" | timing=="Transactions during voyage") & intermediarytradingoperation==0

gen costonreturn_silver=value_silver if typeofcashflow=="Expenditure" & (timing=="Return" | timing=="Transactions during voyage") & intermediarytradingoperation==0
replace costonreturn_silver=0 if missing(costonreturn_silver)

***End of the creation of the four variables

* SUM UP ALL THESE FOUR VARIABLES BY VENTURE

bysort ventureid: egen totalgrossexp=total(expenditure)
bysort ventureid: egen totaldisc=total(discount)
bysort ventureid: egen totalgrossreturn=total(return)
bysort ventureid: egen totalcostonreturn=total(costonreturn)

bysort ventureid: egen totalgrossexp_silver=total(expenditure_silver)
bysort ventureid: egen totaldisc_silver=total(discount_silver)
bysort ventureid: egen totalgrossreturn_silver=total(return_silver)
bysort ventureid: egen totalcostonreturn_silver=total(costonreturn_silver)

* DEAL WITH DANISH BARGUM TRADING SOCIETY WHERE SOME RETURNS ARE REPORTED COLLECTIVELY FOR SEVERAL VENTURES
*bysort nameofoutfitter: egen totalgrossexp2=total(expenditure)
*bysort nameofoutfitter: egen totaldisc2=total(discount)
*bysort nameofoutfitter: egen totalgrossreturn2=total(return)
*bysort nameofoutfitter: egen totalcostonreturn2=total(costonreturn)

**Back to DANISH BARGUM TRADING SOCIETY WHERE SOME RETURNS ARE REPORTED COLLECTIVELY FOR SEVERAL VENTURES
*replace totalgrossexp2=. if ventureid!="KR016"
*replace totaldisc2=. if ventureid!="KR016"
*replace totalgrossreturn2=. if ventureid!="KR016"
*replace totalcostonreturn2=. if ventureid!="KR016"

*replace totalgrossexp=totalgrossexp2 if ventureid=="KR016"
*replace totaldisc=totaldisc2 if ventureid=="KR016"
*replace totalgrossreturn=totalgrossreturn2 if ventureid=="KR016"
*replace totalcostonreturn=totalcostonreturn2 if ventureid=="KR016"

*replace completedataonoutlays="with estimates" if ventureid=="KR016"
*replace completedataonreturns="with estimates" if ventureid=="KR016"

*drop totalgrossexp2 totaldisc2 totalgrossreturn2* totalcostonreturn2

* GENERATE ESTIMATES FOR TOTAL NET EXPENDITURE, TOTALNETRETURN AND PROFIT (AS THEY ARE SUMMED BY VENTURE, THESE WILL ALSO BE BY VENTURE)
gen totalnetexp=totalgrossexp-totaldisc
gen totalnetreturn=totalgrossreturn-totalcostonreturn

gen totalnetexp_silver=totalgrossexp_silver-totaldisc_silver
gen totalnetreturn_silver=totalgrossreturn_silver-totalcostonreturn_silver




*Move from a database by cashflow to database by venture
by ventureid: keep if _n==1
drop nbr_*


drop specification-specificationcategory typeofcashflow-timing remarks-transaction_year conv_in_silver
save "${output}Database for profit computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.dta", replace

end


* order of the profit hypotheses: OR VSDO VSDR VSDT VSRV VSRT INV INT

profit_computation_db 0.5 1 1 0 1 0 1 0 /*Baseline, right ?*/



profit_computation_db . 1 1 0 1 0 1 0

/*For test VSDT*/
profit_computation_db . 1 1 1 1 0 1 0



profit_computation_db 0 1 1 0 1 0 1 0

profit_computation_db 1 1 1 0 1 0 1 0



* FURTHER ROBUSTNESS TESTS
*assuming that no insurance was purchased if we have no positive proof that it was
profit_computation_db 0.5 1 1 0 1 0 0 0

* assuming a 50% higher value of the ship relative to cost of other outlays that we assume in baseline
profit_computation_db 0.5 1.5 1 0 1 0 1 0

* assuming that depreciation was only 10% rather than the 25% we assume in baseline.
profit_computation_db 0.5 1 0.83 0 1.2 0 1 0

* assuming that insurance was purchased on all ventures, even for the ones where the accounts we have seem to suggest total outlays.
profit_computation_db 0.5 1 1 0 1 0 1 1

* assuming that value of the ship was not included in the accounts where the accounts we have seem to suggest total outlays/returns
profit_computation_db 0.5 1 1 1 1 1 1 0

* assuming both of the above
profit_computation_db 0.5 1 1 1 1 1 1 1

