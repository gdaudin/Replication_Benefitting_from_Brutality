
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


global hyp_list 	OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR._VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR1_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1.5_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR0.83_VSDT0_VSRV1.2_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV0_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT1 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT1_VSRV1_VSRT1_INV1_INT1
*					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0IMP /// 
*					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0onlyIMP




global hyp_list_name `""Baseline" "Observations with outstanding claims excluded from analysis"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to not have been paid at all"'
global hyp_list_name `"$hyp_list_name" "Claims outstanding assumed to have been paid in full"'
global hyp_list_name `"$hyp_list_name" "Higher cost of hull relative to other outlays (25% instead of 17% in baseline)"'
global hyp_list_name `"$hyp_list_name" "Lower rate of depreciation (10% instead of baseline 25%)"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance not added to any voyages"'
global hyp_list_name `"$hyp_list_name" "Cost of insurance added to outlays, even in cases where accounts seem to suggest total outlays"'
global hyp_list_name `"$hyp_list_name" "Value of hull (outgoing/incoming) added to outlays/returns, even in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Both value of hull and cost of insurance added, in cases where accounts seem to suggest total outlays/returns"'
global hyp_list_name `"$hyp_list_name" "Baseline including imputed profits"'
global hyp_list_name `"$hyp_list_name" "Baseline including only imputed profits""'

global explaining "i.nationality_num war neutral i.period  i.MAJMAJBYIMP_num big_port ln_totalnetexp_silver_ship  TONMOD crowd OUTFITTER_experience_d captain_experience_d"
global proxy "investment_per_slave ln_SLAXIMP  MORTALITY pricemarkup ln_length_in_days i.FATEcol"

tokenize `"$hyp_list_name"'
local i 1

collect clear

foreach hyp of global hyp_list {
	use "${output}Ventures&profit_`hyp'.dta", clear
	generate hyp="``i''"

	drop if completedataonoutlays=="no" & completedataonreturns=="no"
	drop if profit ==.

	reg profit $explaining, vce(robust)
	if `i'==1 outreg2 using "$output/regv2exp_appendix.xls", label excel auto(2) replace
	if `i'!=1 outreg2 using "$output/regv2exp_appendix.xls", label excel auto(2)

	reg profit $proxy, vce(robust) 
	if `i'==1 outreg2 using "$output/regv2proxi_appendix.xls", label excel auto(2) replace
	if `i'!=1 outreg2 using "$output/regv2proxi_appendix.xls", label excel auto(2) 

	local i=`i'+1
}

global hyp_list 	OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0 ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0onlyIMP ///
					OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0IMP 
					

tokenize `"$hyp_list_name"'
local i 1

collect clear

foreach hyp of global hyp_list {
	use "${output}Ventures&profit_`hyp'.dta", clear
	generate hyp="``i''"

	drop if completedataonoutlays=="no" & completedataonreturns=="no"
	drop if profit ==.

	reg profit $explaining, vce(robust)
	if `i'==1 outreg2 using "$output/regv2exp_IMPappendix.xls", label excel auto(2) replace
	if `i'!=1 outreg2 using "$output/regv2exp_IMPappendix.xls", label excel auto(2)

	reg profit $proxy, vce(robust) 
	if `i'==1 outreg2 using "$output/regv2proxi_IMPappendix.xls", label excel auto(2) replace
	if `i'!=1 outreg2 using "$output/regv2proxi_IMPappendix.xls", label excel auto(2) 

	local i=`i'+1
}

