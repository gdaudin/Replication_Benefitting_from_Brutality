*ssc install rangestat

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

/*
DATARR43 DATARR44 DATAR45  day / Month / year voyage completed (year missing for 24,708 voyages)
DATEEND Date when voyage completed 25,654 missing
DATEDEP Date voyage began 13,244 missing (DATEDEPA DATEDEPM DATEDEPC day Month year (year missing for 9,629 voyages))
Either DATEEND or DATEDEP is missing for 26,227 voyages
*/

use "${tastdb}tastdb-exp-2020.dta", clear

gen length_in_days=(DATEEND-DATEDEP)/1000/60/60/24
label var length_in_days "Length of voyage in days"

keep if length_in_days !=.
keep VOYAGEID length_in_days
save "${output}voyageslength.dta", replace

use "${output}Ventures&profit_Baseline.dta", clear
drop if VOYAGEID == ""
merge 1:1 VOYAGEID using "${output}voyageslength.dta"
hist length_in_days, percent
** Results : 13 with no VOYAGEID, 105 with no length, 270 with a length





