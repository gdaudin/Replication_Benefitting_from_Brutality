
clear
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
keep ventureid profit
merge 1:m ventureid using "${output}voyages.dta"
keep VOYAGEID profit
merge 1:1 VOYAGEID using "${output}STDT_enriched.dta"


reg profit i.YEARAF ib3.nationality_num
outreg2 using "$output/reg_synchro, label excel auto(2) replace 

end

capture erase "$output/Table6.xls"
capture erase "$output/Table6.txt"
capture erase "$output/Comparison between different assumptions.xls"
capture erase "$output/Comparison between different assumptions.txt"
capture erase "$output/TableBaseline-Imputed.xls"
capture erase "$output/TableBaseline-Imputed.txt"


profit_analysis_synchro 0.5 1 1 0 1 0 1 0

