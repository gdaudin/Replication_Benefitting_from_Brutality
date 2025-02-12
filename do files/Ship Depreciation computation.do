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
	global output "~/Documents/Recherche/2019 Profits of slavery/Stata/"
}

else if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
}
clear
use "${output}Cash flow all.dta"

* guillaume-claire-judith 
replace timing="Outfitting" if typeofcashflow=="Expenditure" 


* ASSUMPTION ABOUT THE TIMING OF INSURANCE PAYMENTS FOR OBS WHERE EXACT TIMING IS UNKNONWN, I.E. THEY ARE NOW ASSUMED TO HAVE BEEN PAID ONLY AFTER THE VOYAGE

replace timing="Return" if timing=="Unknown" & specification=="Insurance" |  timing=="Unknown" & specification=="Assurances" | timing=="Unknown" & specification=="Insurance (Assurances)"

* MERGE CASH FLOW AND VENTURE-DATABASES INTO ONE

merge m:1 ventureid using "${output}Venture all.dta"
keep if missing(hypothesis)

keep if specificationcategory=="Ship"

keep typeofcashflow ventureid value nationality
collapse (sum) value, by(ventureid typeofcashflow nationality)

reshape wide value, i(ventureid nationality) j(typeofcashflow) string

gen ship_depreciation=(valueExpenditure-valueReturn)/valueExpenditure

drop if ship_depreciation ==. 

tab nationality

sum ship_depreciation, det

sum ship_depreciation if ship_depreciation >0, det
bys nationality : sum ship_depreciation if ship_depreciation >0, det



