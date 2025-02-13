clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "$dir/output/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits data and programs"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}

use "${output}Venture all.dta", clear
drop if numberofvoyages>=2
sort VOYAGEID ventureid
replace VOYAGEID="RDGRR"+string(_n) if VOYAGEID=="" | VOYAGEID=="." 
 drop if completedataonoutlays=="no" | completedataonreturns=="no"

merge 1:1 VOYAGEID using "${output}multiple voyages plus TSTD.dta"


