
clear
collect clear
*ssc install estout, replace
*ssc install outreg2, replace

if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tastdb "$dir/script guillaume-claire-judith/"
	global slaves "$dir/script guillaume-claire-judith/slaves/"
	global graphs "$dir/graphs"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
	global slaves "$dir\do files\script guillaume-claire-judith\slaves\"
	global graphs "$dir\graphs"
}


capture program drop profit_analysis_synchro
program define profit_analysis_synchro
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0" ///
	local hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0 IMP" ///
	local hyp="Imputed"

use "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear
keep if numberofvoyages==1
keep ventureid profit YEARAF nationality_num


bysort YEARAF : gen N=_N
bysort YEARAF nationality_num: gen N_nat=_N



preserve
bysort YEARAF : keep if _n==1
label var N "Number of single-voyage ventures (all nationalities)"
histogram N, width(1) ytitle(Number of years between 1730 and 1830) discrete freque start(0.5)


graph export  "$graphs/Syncro_hist.png", replace

restore
preserve
collapse (sd) sd_profit=profit (mean) mean_profit=profit (count) nbr_profit=profit, by(YEARAF)

graph twoway (bar  nbr_profit YEARAF if nbr_profit>=2, yaxis(1)) (scatter mean_profit  YEARAF if nbr_profit>=2, msymbol(square) yaxis(2)) ///
	(scatter  sd_profit YEARAF if nbr_profit>=2, yaxis(2)) , ///
	scheme(s1color) ///
	legend(label(1 "Number of profit observations (left axis)") label(2 "Mean profit (right axis)") label (3 "Standard deviation of profit (right axis)")) ///
	xtitle("") ytitle("") xscale(range(1725 1830)) xlabel(1750(25)1825)

graph export "$graphs/profit_dispersio_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png",as(png) replace

restore


reg profit i.YEARAF 
*testparm i.YEARAF

reg profit i.YEARAF ib3.nationality_num
*testparm i.YEARAF

foreach ynbr in 2 3 4 5 6 7 8 9 {

reg profit i.YEARAF ib3.nationality_num if N>=`ynbr'
testparm i.YEARAF
collect get, tags(ynbr[`ynbr'] reg[add]): reg profit i.YEARAF ib3.nationality_num if N>=`ynbr'
collect get, tags(ynbr[`ynbr'] reg[add]): testparm i.YEARAF

reg profit i.YEARAF#nationality_num if N_nat>=`ynbr'
testparm i.YEARAF#nationality_num
collect get, tags(ynbr[`ynbr'] reg[mul]): reg profit i.YEARAF#nationality_num if N_nat>=`ynbr'
collect get, tags(ynbr[`ynbr'] reg[mul]): testparm i.YEARAF#nationality_num
}

collect label levels reg add "Nationality shifter" mul "Nation-specific market return", replace
collect label levels ynbr 2 "At least 2 observations per year" 3 "At least 3 observations per year" 4 "At least 4 observations per year" 5 "At least 5 observations per year" 6 "At least 6 observations per year" 7 "At least 7 observations per year" 8 "At least 8 observations per year" 9 "At least 9 observations per year", replace
collect label levels result p "F-test for joint significance of years (p-stat)" N "Number of observations", replace
collect style cell result[r2 p], nformat(%3.2fc)
collect layout (ynbr#result[N r2 p]) (reg)

collect export "${output}Profit analysis survey synchronisation.docx", as(docx) replace
collect export "${output}Profit analysis survey synchronisation.txt", as(txt) replace


end

profit_analysis_synchro 0.5 1 1 0 1 0 1 0

