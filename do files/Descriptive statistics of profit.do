
clear
*ssc install estout, replace
*ssc install outreg2, replace

if lower(c(username)) == "kraemer" {
	!subst X: /d
	!subst X:   "C:\Users\Kraemer\Documents"
	capture cd "X:\slaveprofits\"
	if _rc != 0 cd  "C:\Users\Kraemer\Documents\slaveprofits"
	global output "C:\Users\Kraemer\Documents\slaveprofits\script guillaume-claire-judith\output"
	global tastdb "C:\Users\Kraemer\Documents\slaveprofits\script guillaume-claire-judith"
	global slaves "C:\Users\Kraemer\Documents\slaveprofits\script guillaume-claire-judith\slaves"

}

 if lower(c(username)) == "claire" {
	!subst X: /d
	!subst X:   "/Users/guillaume-claire-judith/"
	capture cd "X:/slaveprofits/"
	if _rc != 0 cd  "/Users/h-claire-judith/slaveprofits/"
	global output "/Users/guillaume-claire-judith/Desktop/temp"
	global tastdb "/Users/guillaume-claire-judith/slaveprofits/script guillaume-claire-judith/"
	global slaves "/Users/guillaume-claire-judith/slaveprofits/script guillaume-claire-judith/slaves/"

}

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


collect clear
**First work on the baseline
use "${output}Ventures&profit_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.dta", clear
keep ventureid nationality profit


gen twosidedpvalue=.
foreach v in Danish Dutch English French Spanish { 
        gen `v' = strpos(nationality, "`v'") > 0 
		ttest profit, by(`v') unequal
		replace twosidedpvalue=r(p) if `v'==1
	}





table (nationality), ///
	statistic(mean profit)  ///
	command(r(lb) r(ub): ci means profit) ///
	statistic(first twosidedpvalue)  ///
	statistic(median profit)  ///
	statistic(sd profit)  ///
	statistic(max profit) ///
	statistic(min profit) ///
	statistic(count profit) ///
	name(Hyp_table) replace ///
	nformat (%5.3f)

*collect label levels result first "Mean equality t-test p_stat", modify
*collect stars first 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   " 
///, attach(mean)
*collect layout (result[mean stars ub lb first median sd max min]) (nationality)
collect stars first 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(mean) dimension
/*collect layout (result[mean ub lb median sd max min]) (nationality#stars) /// Old version */
collect label levels result count "N" lb "ci lb" ub "ci up", modify
collect layout (nationality#stars) (result[count mean median lb ub ]) 
collect style cell result[count], nformat(%5.0f)

collect preview


collect export "${output}Profits_bynatio_baseline.txt", as(txt) replace
collect export "${output}Profits_bynatio_baseline.docx", as(docx) replace
collect export "${output}Profits_bynatio_baseline.pdf", as(pdf) replace

** For the table Average profitability of the transatlantic slave trade, by nationality of trader, 1730-1830


collect clear

global hyp_list 	OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR._VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR1_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1.5_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR0.83_VSDT0_VSRV1.2_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV0_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT1 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT1 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0IMP /// 
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0onlyIMP





global hyp_list_name `""Baseline" "Observations with outstanding claims excluded from analysis"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to not have been paid at all"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to have been paid in full"'
global hyp_list_name `"$hyp_list_name" "Higher cost of hull relative to other outlays (25% instead of 17% in baseline)"'
global hyp_list_name `"$hyp_list_name" "Lower rate of depreciation (10% instead of baseline 25%"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance not added to any voyages"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays"'
global hyp_list_name `"$hyp_list_name" "Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Baseline including imputed profits"'
global hyp_list_name `"$hyp_list_name" "Baseline including only imputed profits""'

tokenize `"$hyp_list_name"'
local i 1

foreach hyp of global hyp_list {
	use "${output}Ventures&profit_`hyp'.dta", clear
	keep ventureid nationality profit
	generate hyp="``i''"
	gen twosidedpvalue=.
	foreach v in Danish Dutch English French Spanish { 
        gen `v' = strpos(nationality, "`v'") > 0 
		capture ttest profit, by(`v') unequal  
		replace twosidedpvalue=r(p) if `v'==1 & hyp=="``i''"
	}
	if `i'!=1 append using "${output}For_hyp_table.dta"
	save "${output}For_hyp_table.dta", replace
	local i =`i'+1
}

*display "$hyp_list_name"

label var hyp "Hypothesis"


table (hyp[$hyp_list_name]) (nationality), ///
	statistic(mean profit)  ///
	command(r(lb) r(ub): ci means profit) ///
	statistic(first twosidedpvalue)  ///
	statistic(median profit)  ///
	statistic(sd profit)  ///
	statistic(max profit) ///
	statistic(min profit) ///
	statistic(count profit) ///
	name(Hyp_table) replace ///
	nformat (%5.3f)
 

global hyp_list_nameb `""Claims outstanding assumed to not have been paid at all"'
global hyp_list_nameb `"$hyp_list_nameb" "Claims outstanding assumed to have been paid in full"'
global hyp_list_nameb `"$hyp_list_nameb" "Higher cost of hull relative to other outlays (25% instead of 17% in baseline)"'
global hyp_list_nameb `"$hyp_list_nameb" "Lower rate of depreciation (10% instead of baseline 25%)"'
global hyp_list_nameb `"$hyp_list_nameb" "Cost of insurance not added to any voyages"'
global hyp_list_nameb `"$hyp_list_nameb" "Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays"'
global hyp_list_nameb `"$hyp_list_nameb" "Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_nameb `"$hyp_list_nameb" "Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns""'

collect stars first 0.01 "***" 0.05 "** " 0.1 "*  " 1 "   ", attach(mean) dimension
collect layout (hyp[Baseline `"Observations with outstanding claims excluded from analysis"'] # result[mean first ub lb median sd max min count] hyp[$hyp_list_nameb ] # result[mean ub lb median sd max min]) (nationality#stars)
collect style cell result[count], nformat(%5.0f)
collect preview

*without the stars
*collect layout (hyp[Baseline `"Observations with outstanding claims excluded from analysis"'] # result[mean first ub lb median sd max min count] hyp[$hyp_list_nameb ] # result[mean ub lb median sd max min]) (nationality)


collect export "${output}Profits&HypothesisFull.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("Profits under various hypotheses")
collect export "${output}Profits&HypothesisFull.docx", as(docx) replace
collect style putpdf, title ("Profits under various hypotheses")
collect export "${output}Profits&HypothesisFull.pdf", as(pdf) replace

collect layout (hyp[Baseline `"Observations with outstanding claims excluded from analysis"'] # result[mean ub lb count] hyp[$hyp_list_nameb ] # result[mean ub lb]) (nationality#stars)
collect style cell result[count], nformat(%5.0f)

collect preview
*To check
*Blif



collect export "${output}Profits&Hypothesis.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("Profits under various hypotheses")
collect export "${output}Profits&Hypothesis.docx", as(docx) replace
collect style putpdf, title ("Profits under various hypotheses")
collect export "${output}Profits&Hypothesis.pdf", as(pdf) replace




collect layout (hyp[Baseline `"Baseline including only imputed profits"' `"Baseline including imputed profits"'] # result) (nationality#stars)
collect style cell result[count], nformat(%5.0f)

collect export "${output}Profits&Imputation.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("Profits imputed or not")
collect export "${output}Profits&Imputation.docx", as(docx) replace
collect style putpdf, title ("Profits under various hypotheses")
collect export "${output}Profits&Imputation.pdf", as(pdf) replace


collect preview
*To check
*Blif
///The stars in the column "Total" should be disregarded. They are just a consequence of the way I have programmed, but I do not seem to be able
///to find an easy better way.


erase "${output}For_hyp_table.dta"
collect clear