if lower(c(username)) == "kraemer" {
	!subst X: /d
	!subst X:   "C:\Users\Kraemer\Documents"
	capture cd "X:\slaveprofits\"
	if _rc != 0 cd  "C:\Users\Kraemer\Documents\slaveprofits"
	global output "C:\Users\Kraemer\Documents\slaveprofits\script guillaume-claire-judith\output"

}


else if lower(c(username)) == "guillaumedaudin" {
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


capture program drop net_return_imputation
program net_return_imputation
args OR VSDO VSDR VSDT VSRV VSRT INV INT
use "${output}Database for profit computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.dta", clear




gen totalnetreturn_silver_perslave= totalnetreturn_silver/SLAMIMP/shareoftheship if completedataonreturns !="no"





**Compute the gross return of selling slaves according to STDT (in silver)
rename currency currency_of_venture
gen currency ="Pound sterling"
gen transaction_year= YEARAF
merge m:1 currency transaction_year using "${output}Exchange rates in silver.dta"
***8 unmatched from master : no year information on those
keep if _merge!=2
generate slave_price_silver=priceamerica * conv_in_silver
generate gross_slaves_sale_silver = slave_price_silver * SLAMIMP * shareoftheship
drop currency _merge
rename conv_in_silver pound_conv_in_silver
rename currency_of_venture currency




sort nationality ventureid

*We try different way. I like the last one better, because it removes the non-pertinent correlation due to the size of the venture
/*
bys nationality: correlate gross_slaves_sale_silver totalnetreturn_silver if completedataonreturns!="no"
bys nationality: reg totalnetreturn_silver gross_slaves_sale_silver if completedataonreturns!="no"
bys nationality: reg totalnetreturn_silver gross_slaves_sale_silver if completedataonreturns!="no", noconstant
bys nationality: reg totalnetreturn_silver gross_slaves_sale_silver totalgrossexp_silver if completedataonreturns!="no", noconstant
by nationality: reg totalnetreturn_silver_perslave slave_price_silver  if completedataonreturns!="no"
*/

foreach nat in French Dutch English Danish {
	
	graph twoway (scatter totalnetreturn_silver_perslave slave_price_silver if nationality=="`nat'", /*
		*/ mlabel(ventureid) ytitle("Net return per slave in silver grams") xtitle("Slave price in the English West Indies in silver grams") /*
		*/ title("`nat'") legend(off)) (lfit totalnetreturn_silver_perslave slave_price_silver if nationality=="`nat'"), scheme(s1mono)
	graph export "$graphs/PerSlaveImputationQuality_`nat'_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.png", as(png) replace
}



generate totalnetreturn_imp = .
generate totalnetreturn_silver_imp = .
generate totalnetreturn_silver_pers_imp = .

* To use if we regress total returns on total slave prices
/*
foreach nat in English French Dutch Danish {
	reg totalnetreturn_silver gross_slaves_sale_silver /*totalgrossexp_silver*/ if completedataonreturns!="no" & nationality == "`nat'" & SLAMIMP !=., noconstant
	***Restricting to "successful" voyages does not improve the situation much
	*reg totalnetreturn_silver gross_slaves_sale_silver if completedataonreturns!="no" & nationality == "English" & SLAMIMP !=. & FATE4==1
	predict blif if nationality == "`nat'" & SLAMIMP !=.
	replace totalneturn_silver_imp= blif if nationality == "`nat'" & SLAMIMP !=.
	drop blif
	replace totalnetreturn_imp = totalneturn_silver_imp/conv_in_silver if nationality == "`nat'" & SLAMIMP !=.
	replace totalnetreturn = totalnetreturn_imp if completedataonreturns=="no" & nationality == "`nat'" & SLAMIMP !=.
	replace completedataonreturns="imputed" if completedataonreturns=="no" & nationality == "`nat'" & SLAMIMP !=.
}
*/

label var slave_price_silver "Slave price in the British West Indies (in silver grams)"
label var totalnetreturn_silver_perslave ///
	"Total net returns per slave in Europe (in silver grams)"



capture erase "${output}Imputations.xls"
capture erase "${output}Imputations.txt"

foreach nat in English French Dutch Danish {
	display "`nat'"
	outreg2 using "${output}Imputations.xls", label auto(2) excel ctitle("`nat'"): ///
		reg totalnetreturn_silver_perslave slave_price_silver ///
		if completedataonreturns!="no" & nationality == "`nat'"
	reg totalnetreturn_silver_perslave slave_price_silver ///
		if completedataonreturns!="no" & nationality == "`nat'"
	predict blimp if nationality == "`nat'"
	replace totalnetreturn_silver_pers_imp=blimp  if nationality == "`nat'"
	drop blimp
}

replace totalnetreturn_silver_imp = totalnetreturn_silver_pers_imp*SLAMIMP*shareoftheship
replace totalnetreturn_imp = totalnetreturn_silver_imp/9.61 if  SLAMIMP !=. & nationality=="Dutch" /*Par*/
replace totalnetreturn_imp = totalnetreturn_silver_imp/105.5 if  SLAMIMP !=. & nationality=="English" /*Mean silver value between 1750 and 1790*/
replace totalnetreturn_imp = totalnetreturn_silver_imp/4.45 if  SLAMIMP !=. & nationality=="French" & YEARAF <=1787 /*Par -- we do not guess for the next ones*/
replace totalnetreturn = totalnetreturn_imp if completedataonreturns=="no" &  SLAMIMP !=.
replace completedataonreturns="imputed" if completedataonreturns=="no" & SLAMIMP !=.


by nationality: sum totalnetreturn totalnetreturn_imp if completedataonreturns!="imputed" & completedataonreturns!="no"
graph twoway (scatter  totalnetreturn totalnetreturn_imp if completedataonreturns!="imputed" & completedataonreturns!="no", mlabel(nationality))
graph export "$graphs/TotalReturnCurrencyImputationQuality_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.png", as(png) replace
graph twoway (scatter  totalnetreturn_silver totalnetreturn_silver_imp if completedataonreturns!="imputed" & completedataonreturns!="no", mlabel(nationality))
graph export "$graphs/TotalReturnSilverImputationQuality_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'.png", as(png) replace
by nationality: sum totalnetreturn if completedataonreturns=="imputed", det

save "${output}Database for profit computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'IMP.dta", replace
keep if completedataonreturns=="imputed"
save "${output}Database for profit computation_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'onlyIMP.dta", replace

end

**Only baseline
net_return_imputation 0.5 1 1 0 1 0 1 0





