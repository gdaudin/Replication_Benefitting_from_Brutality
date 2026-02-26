
clear
*ssc install estout, replace
*ssc install outreg2, replace

if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tstddb "$dir/script guillaume-claire-judith/"
	global slaves "$dir/script guillaume-claire-judith/slaves/"
	global graphs "$dir/graphs"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tstddb "$dir\external data\"
	global slaves "$dir\do files\script guillaume-claire-judith\slaves\"
	global graphs "$dir\graphs"
}
*"

capture program drop descriptive_stat
program define descriptive_stat
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP
*eg profit_analysis 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_analysis 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed



use "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear

if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0" ///
	local hyp="Baseline"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0 IMP" ///
	local hyp="Imputed"
if "`OR' `VSDO' `VSDR' `VSDT' `VSRV' `VSRT' `INV' `INT'`IMP'"=="0.5 1 1 0 1 0 1 0 onlyIMP" ///
	local hyp="Only imputed"



global varlist_o  YEARAF totalnetexp_silver_ship TONMOD crowd SLAXIMP MORTALITY investment_per_slave pricemarkup

table (var) (nationality_num), ///
	statistic(mean $varlist_o)  ///
	statistic(median $varlist_o)  ///
	statistic(sd $varlist_o)  ///
	statistic(max $varlist_o) ///
	statistic(min $varlist_o) ///
	statistic(count $varlist_o) ///
	name(DS_others) replace

global varlist_d war neutral big_port OUTFITTER_experience_d captain_experience_d

table (var) (nationality_num), ///
	statistic(mean $varlist_d)  ///
	statistic(median $varlist_d)  ///
	statistic(sd $varlist_d)  ///
	statistic(count $varlist_d) ///
	name(DS_dummies) replace


collect combine DS= DS_others DS_dummies, replace

global varlist_count  SLAXIMP totalnetexp_silver_ship investment_per_slave TONMOD

collect style cell var, nformat(%5.2fc)
collect style cell var[profit], nformat(%5.3f)
collect style cell var[YEARAF], nformat(%5.0f)
collect style cell var[$varlist_count], nformat(%12.0fc)
collect style cell result[count], nformat(%5.0f)
collect style cell var[$varlist_count]#result[max min], nformat(%12.0fc)


collect layout (var[war neutral big_port] # result[mean median sd count] ///
	var[totalnetexp_silver_ship TONMOD crowd] # result[mean median sd min max count] ///
	var[OUTFITTER_experience_d captain_experience_d] # result[mean median sd count]) (nationality_num) 

collect export "${output}DS_input_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_input_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.docx", as(docx) replace
collect style putpdf, title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_input_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.pdf", as(pdf) replace

if "`hyp'"=="Baseline"  | "`hyp'"=="Imputed"{
	collect export "${output}DS_input_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}DS_input_var_`hyp'.docx", as(docx) replace
	collect style putpdf, title ("`hyp'")
	collect export "${output}DS_input_var_`hyp'.pdf", as(pdf) replace
}

collect layout (var[SLAXIMP MORTALITY investment_per_slave pricemarkup] # result[mean median sd min max count]) (nationality_num) 

collect export "${output}DS_proxy_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_proxy_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.docx", as(docx) replace
collect style putpdf, title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_proxy_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.pdf", as(pdf) replace

if "`hyp'"=="Baseline"  | "`hyp'"=="Imputed"{
	collect export "${output}DS_proxy_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}DS_proxy_var_`hyp'.docx", as(docx) replace
	collect style putpdf, title ("`hyp'")
	collect export "${output}DS_proxy_var_`hyp'.pdf", as(pdf) replace
}

collect clear

table (period) (nationality_num)
table (MAJMAJBYIMP) (nationality_num), append
table (FATEcol) (nationality_num), append

collect layout (period MAJMAJBYIMP FATEcol) (nationality_num) 

collect export "${output}DS_cat_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.txt", as(txt) replace
collect style putdocx, layout(autofitcontents) title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_cat_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.docx", as(docx) replace
collect style putpdf, title ("OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'")
collect export "${output}DS_cat_var_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.pdf", as(pdf) replace

if "`hyp'"=="Baseline"  | "`hyp'"=="Imputed"{
	collect export "${output}DS_cat_var_`hyp'.txt", as(txt) replace
	collect style putdocx, layout(autofitcontents) title ("`hyp'")
	collect export "${output}DS_cat_var_`hyp'.docx", as(docx) replace
	collect style putpdf, title ("`hyp'")
	collect export "${output}DS_cat_var_`hyp'.pdf", as(pdf) replace
}




end


descriptive_stat 0.5 1 1 0 1 0 1 0
descriptive_stat 0.5 1 1 0 1 0 1 0 IMP
descriptive_stat 0.5 1 1 0 1 0 1 0 onlyIMP




global varlist_o  SLAXIMP YEARAF totalnetexp_silver_ship investment_per_slave TONMOD totalnetexp_silver_ship MORTALITY crowd



***Faire quelque chose pour la région 