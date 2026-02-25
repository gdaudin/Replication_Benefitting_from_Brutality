clear


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

*rename v1 year
rename value_of_livre convlivretournois
/*drop v5-v12 
drop v2 v3
drop if year=="Source:"
drop if year==""
drop if convlivretournois=="" */
replace convlivretournois = subinstr(convlivretournois,",",".",.)
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
