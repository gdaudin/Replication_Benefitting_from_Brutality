
clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}










////////////////////////////////////////////
//////////////////////////////////////////

* Start again from the merged dataset
use  "tastdb-exp-2020+own.dta", clear


replace YEARAF=YEARAF_own if YEARAF==.
decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
encode MAJMAJBYIMP, gen(MAJMAJBYIMP_num)
label var MAJMAJBYIMP "African region of trade"
label var MAJMAJBYIMP_num "African region of trade"



* MERGE OUR DATASET WITH Career DATASET (CAPTAIN)
generate CAPTAIN = ""
replace CAPTAIN = CAPTAINA
replace CAPTAIN = nameofthecaptain if CAPTAIN==""
replace CAPTAIN="" if CAPTAIN=="."
merge m:1 CAPTAIN YEARAF MAJMAJBYIMP using "${output}Captain.dta"
drop if _merge==2
*For debugging
*br CAPTAIN YEARAF ventureid VOYAGEID if _merge==1 & (CAPTAIN!="" & YEARAF !=.)
assert (CAPTAIN=="" | YEARAF ==.) if _merge==1 ///
	&  (completedataonoutlays=="yes" | completedataonoutlays=="with estimates") ///
	& (completedataonreturns=="yes" | completedataonreturns=="with estimates") 
	
drop _merge


* MERGE OUR DATASET WITH Career DATASET (OUTFITTER)
generate OUTFITTER = ""
replace OUTFITTER = nameofoutfitter
replace OUTFITTER = OWNERA if OUTFITTER==""
replace OUTFITTER="" if OUTFITTER=="."
merge m:1 OUTFITTER YEARAF MAJMAJBYIMP using "${output}OUTFITTER.dta"
drop if _merge==2
*For debugging
*br OUTFITTER YEARAF ventureid VOYAGEID if _merge==1 & (OUTFITTER!="" & YEARAF !=.)
assert (OUTFITTER=="" | YEARAF ==.) if _merge==1 ///
	&  (completedataonoutlays=="yes" | completedataonoutlays=="with estimates") ///
	& (completedataonreturns=="yes" | completedataonreturns=="with estimates") 




drop _merge




*erase "tastdb-exp-2020.dta"



save "${output}Venture all.dta", replace

* APPEND SLAVE PRICES
merge m:1 YEARAF using "${output}Prices.dta"
drop if _merge==2
drop _merge
gen pricemarkup=priceamerica/priceafrica
label var pricemarkup "Slave price markup between America and Africa"



*APPEND WARS
merge m:1 YEARAF nationality using "${output}European wars.dta"
drop if _merge==2
drop _merge

***APPEND NEUTRALITY
merge m:1 YEARAF nationality using  "${output}Neutrality.dta"
drop if _merge==2
drop _merge

save "${output}Venture all.dta", replace


*** COLLAPSE FATE-VARIABLE INTO FOUR CATEGORIES, DEPENDING ON WHETHER/WHEN SHIP WAS LOST
replace FATEcol=	1	if FATE==	1 & missing(FATEcol)
replace FATEcol=	2	if FATE==	2 & missing(FATEcol)
replace FATEcol=	2	if FATE==	3 & missing(FATEcol)
replace FATEcol=	3	if FATE==	4 & missing(FATEcol)
replace FATEcol=	2	if FATE==	11 & missing(FATEcol)
replace FATEcol=	3	if FATE==	12 & missing(FATEcol)
replace FATEcol=	2	if FATE==	23 & missing(FATEcol)
replace FATEcol=	3	if FATE==	29 & missing(FATEcol)
replace FATEcol=	4	if FATE==	30 & missing(FATEcol)
replace FATEcol=	4	if FATE==	40 & missing(FATEcol)
replace FATEcol=	2	if FATE==	44 & missing(FATEcol)
replace FATEcol=	3	if FATE==	49 & missing(FATEcol)
replace FATEcol=	2	if FATE==	50 & missing(FATEcol)
replace FATEcol=	2	if FATE==	51 & missing(FATEcol)
replace FATEcol=	3	if FATE==	54 & missing(FATEcol)
replace FATEcol=	4	if FATE==	59 & missing(FATEcol)
replace FATEcol=	3	if FATE==	68 & missing(FATEcol)
replace FATEcol=	2	if FATE==	69 & missing(FATEcol)
replace FATEcol=	4	if FATE==	70 & missing(FATEcol)
replace FATEcol=	2	if FATE==	71 & missing(FATEcol)
replace FATEcol=	2	if FATE==	74 & missing(FATEcol)
replace FATEcol=	4	if FATE==	77 & missing(FATEcol)
replace FATEcol=	3	if FATE==	78 & missing(FATEcol)
replace FATEcol=	3	if FATE==	92 & missing(FATEcol)
replace FATEcol=	3	if FATE==	95 & missing(FATEcol)
replace FATEcol=	3	if FATE==	97 & missing(FATEcol)
replace FATEcol=	3	if FATE==	122 & missing(FATEcol)
replace FATEcol=	2	if FATE==	161 & missing(FATEcol)
replace FATEcol=	4	if FATE==	172 & missing(FATEcol)

replace FATEcol=3 if FATE4>1 & !missing(FATEcol) & numberofvoyages>1

replace FATE4=1 if FATEcol==1

label var FATEcol "Fate of venture"
label define fate 1 "Voyage completed as intended" 2 "Original goal thwarted before disembarking slaves" 3 "Original goal thwarted after disembarking slaves" 4 "Unspecified/unknown"
label values FATEcol fate

replace FATEcol=4 if missing(FATEcol)
replace FATE4=4 if missing(FATE4)

****add port shares
merge m:1 YEARAF MJBYPTIMP using "${output}port_shares.dta", keep(1 3)
drop _merge


***some more variables
encode nationality, generate(nationality_num)
gen ln_SLAXIMP = ln(SLAXIMP)
label var ln_SLAXIMP "Enslaved persons emparked (ln)"

gen MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP
replace MORTALITY=VYMRTRAT if missing(MORTALITY)
label var MORTALITY "Enslaved person mortality rate"

gen crowd=SLAXIMP/TONMOD
label var crowd "Number of embarked enslaved persons per ton"

gen captain_experience_d=0 if !missing(captain_experience)
replace captain_experience_d=1 if captain_experience>0 & !missing(captain_experience)
label var captain_experience_d "Not the first voyage of the captain"


gen captain_regional_experience_d=0 if !missing(captain_regional_experience)
replace captain_regional_experience_d=1 if captain_regional_experience>0 & !missing(captain_regional_experience)
label var captain_regional_experience_d "Not the first voyage of the captain in the region"



gen captain_total_career_d=0 if !missing(captain_total_career)
replace captain_total_career_d=1 if captain_total_career>1 & !missing(captain_total_career)


gen OUTFITTER_experience_d=0 if !missing(OUTFITTER_experience)
replace OUTFITTER_experience_d=1 if OUTFITTER_experience>0 & !missing(OUTFITTER_experience)
label var OUTFITTER_experience_d "Not the first voyage of the outfitter"

gen OUTFITTER_regional_experience_d=0 if !missing(OUTFITTER_regional_experience)
replace OUTFITTER_regional_experience_d=1 if OUTFITTER_regional_experience>0 & !missing(OUTFITTER_regional_experience)
label var OUTFITTER_regional_experience_d "Not the first voyage of the outfitter in the region"

gen OUTFITTER_total_career_d=0 if !missing(OUTFITTER_total_career)
replace OUTFITTER_total_career_d=1 if OUTFITTER_total_career>1 & !missing(OUTFITTER_total_career)

encode perspectiveofsource, generate(perspective)

gen yearsq=YEARAF*YEARAF
gen ln_year=ln(YEARAF)

gen period=1 if YEARAF<1751
replace period=2 if YEARAF>1750 & YEARAF<1776
replace period=3 if YEARAF>1775 & YEARAF<1801
replace period=4 if YEARAF>1800 & !missing(YEARAF)
label define lab_period 1 "pre-1750" 2 "1751-1775" 3 "1776-1800" 4 "post-1800"
label values period lab_period
label var period "Period"

gen blif = (DATEEND-DATEDEP)/1000/60/60/24
replace length_in_days=blif if blif!=.
drop blif


gen big_port=0
replace big_port=1 if port_share>0.01 & !missing(port_share)
label var big_port "Big African slave-trading port"



save "${output}Venture all.dta", replace

