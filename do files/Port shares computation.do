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
PLAC1TRA PLAC2TRA PLAC3TRA First, second and third place of purchase
YEARAF Year departed Africa (imputed)
TSLAVESP Total slave purchase
SLAXIMP Imputed total slaves embarked
NCAR13 NCAR15 NCAR17 Slaves carried from first, second, third port of purchase
Klas recommends using MAJBUYPT (place) MJBYPTIMP (imputed place), region, MAJBYIMP.
and SLAXIMP (imputed total slaves embarked)
*/


use "${tastdb}tastdb-exp-2020.dta", clear

keep YEARAF  MJBYPTIMP SLAXIMP
collapse (sum) SLAXIMP, by(MJBYPTIMP YEARAF)
xtset MJBYPTIMP YEARAF
rangestat (sum) totalslaves15y=SLAXIMP, interval(YEARAF -7 7)
label var totalslaves15y "Total slaves embarked (15 y. window)"
rangestat (sum) portslaves15y=SLAXIMP, interval(YEARAF -7 7) by(MJBYPTIMP)
label var portslaves15y "Total slaves embarked (15 y. window)"
gen port_share = portslaves15y/totalslaves15y
label var port_share "Share of slaves embarked (15 y. window)"

format SLAXIMP totalslaves15y portslaves15y %12.0gc
sort YEARAF

twoway (line  totalslaves15y YEARAF)

decode MJBYPTIMP, gen(MJBYPTIMP_str)
drop if strmatch(MJBYPTIMP_str,"*port unspecified*")==1

save "${output}port_shares.dta", replace

/*
twoway line  port_share YEARAF if MJBYPTIMP_str=="St. Paul de Loanda", title("Share of St. Paul de Loanda")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Senegal", title("Share of Senegal")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Costa da Mina", title("Share of Costa da Mina")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Whydah", title("Share of Whydah")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Bonny", title("Share of Bonny")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Calabar", title("Share of Calabar")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Benguela", title("Share of Benguela")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Cabinda", title("Share of Cabinda")
twoway line  port_share YEARAF if MJBYPTIMP_str=="Mozambique", title("Share of Mozambique")


