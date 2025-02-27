
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
replace MORTALITY=VYMRTRAT if missing(MORTALITY)
label var MORTALITY "Enslaved person mortality rate"



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

encode MAJMAJBYIMP, gen(MAJMAJBYIMP_num)

gen big_port=0
replace big_port=1 if port_share>0.01 & !missing(port_share)
label var big_port "Big African slave-trading port"

save "${output}Enriched ventures.dta", replace
erase "${output}Ventures+TSTD variables.dta"

