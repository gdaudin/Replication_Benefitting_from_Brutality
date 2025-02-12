
clear
*ssc install irr


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

do "$dir/do files/irrGD.do"

use "${output}Data_for_IRR_computation_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.dta", clear

**We keep only ventures with one voyage. 
/*After examination, we can do something with GD002 
GD013 GD015 GD016 GD017 GD019 GD027 GD038
GD039 GD041 GD042 GD141 (ie except GD042 where the sums are 
very small, they do not have outstanding returns)

GD038 et GD141 have been captured, so we only work 
with the others ?
GD013 has not TSTD equivalent

For the English ones, here is Klas’s opinion : 
I found the time to check now. There are no ships for which
we have full info for all transactions and full info on
 date of these transactions. There are, however, 
 five English obs where we have dates for all transactions
 known from the sources, but not for our hypothetical values.
 Potentially these could be use for IRR calcs,
 if you make assumptions that the dating of hypothetical
 transactions occurred around same time as known transactions?
 The five are:
DR001, DR006, DR009, DR010, DR053,
*/

local ventureid_list "GD002 GD015 GD016 GD017 GD019 GD027 GD039 GD041 GD042 DR001 DR006 DR009 DR010 DR053"
keep if strpos("`ventureid_list'",ventureid)!=0

**Profit computation
gen Investment = -Relative_flow if Relative_flow<0
egen Total_Investment=total(Investment), by(ventureid)
gen Return = Relative_flow if Relative_flow >0
egen Total_Return=total(Return), by(ventureid)
gen profit = Total_Return/Total_Investment -1
drop Total* Investment* Return*

save "${output}temp.dta", replace
keep ventureid profit
bys ventureid: keep if _n==1
save "${output}ReconstructedIRR.dta", replace

use "${output}temp.dta", clear
erase "${output}temp.dta"

***IRR computation
gen new=0
encode(ventureid), gen(ventureid_num)
xtset ventureid_num  relative_timing
tsfill, full
replace Relative_flow=0 if new
drop new
drop ventureid
decode(ventureid_num), gen(ventureid)
drop profit ventureid_num
levelsof ventureid, local(ventureid_list)


reshape wide Relative_flow, i(relative_timing) j(ventureid) string



*Check the sum of the relative flow is 1 for each venture
foreach i of local ventureid_list {
	gen Relative_rev`i' = max(0,Relative_flow`i')
	egen check_mean_rev`i'=total(Relative_rev`i')
	assert check_mean_rev`i'>=0.9999 & check_mean_rev`i'<=1.00000001
}


drop check_mean_rev* Relative_rev*
***Compute irr for sample ventures
gen ventureid = ""
gen irr =.

local j = 1
foreach i of local ventureid_list {
	display "`i'"
	capture irrGD(Relative_flow`i')
	replace ventureid = "`i'" if _n==`j'
	capture replace irr = (1+r(irr))^12-1 if _n==`j'
	local j = `j' + 1
}


***Computer irr for hypothetical ventures

egen mean_flowALL = rowmean(Relative_flow*)
egen mean_flowBR = rowmean(Relative_flowDR*)
egen mean_flowFR = rowmean(Relative_flowGD*)

foreach sample in ALL BR FR {
	gen mean_rev`sample'=max(0,mean_flow`sample')
	egen check_mean_rev`sample'=total(mean_rev`sample')
	assert check_mean_rev`sample'==1

	generate mean_exp`sample'=min(0,mean_flow`sample')
	egen exp`sample'=total(mean_exp`sample')
	gen share_exp`sample'=mean_exp`sample'/exp`sample'
}

drop check_mean_rev* mean_exp* exp*



local i = _N
graph twoway  (bar  mean_flowBR relative_timing in 6/`i') (bar  mean_flowFR relative_timing in 6/`i') ///
		(bar  mean_flowALL relative_timing in 6/`i')





gen profit=.

order ventureid irr profit
foreach sample in ALL FR BR {
	forvalues i = -0.9(0.05)1 {
		*local i = 0.1
		local i_nodot = `i'*100
		gen HYP`j'=mean_rev`sample'
		replace HYP`j'=-share_exp`sample'/(`i'+1) if HYP`j'==0
		irrGD(HYP`j')
		replace ventureid = "HYP`i'`sample'" if _n==`j'
		replace profit=`i' if _n==`j'
		replace irr = (1+r(irr))^12-1 if _n==`j'
		local j = `j' + 1
		display "`sample'" "`i'"
	}	
}



twoway (scatter irr profit if strpos(ventureid,"ALL")!=0)  (scatter irr profit if strpos(ventureid,"FR")!=0) ///
		(scatter irr profit if strpos(ventureid,"BR")!=0), legend(label(1 "ALL") label( 2 "FR") label( 3 "BR"))

reg irr profit if strpos(ventureid,"BR")==0 & strpos(ventureid,"FR")==0, noconstant
reg irr profit if strpos(ventureid,"FR")!=0, noconstant
reg irr profit if strpos(ventureid,"BR")!=0, noconstant


drop if ventureid==""
keep ventureid irr profit
merge 1:1 ventureid using "${output}ReconstructedIRR.dta", update
drop _merge

twoway (scatter irr profit if strpos(ventureid,"BR")==0 & strpos(ventureid,"FR")==0) ///
	   (scatter irr profit if strpos(ventureid,"FR")!=0 | strpos(ventureid,"GD")!=0) ///
	   (scatter irr profit if strpos(ventureid,"BR")!=0 | strpos(ventureid,"DR")!=0), legend(label(1 "ALL") label( 2 "FR") label( 3 "BR"))


reg irr profit if strpos(ventureid,"BR")==0 & strpos(ventureid,"FR")==0, noconstant
reg irr profit if strpos(ventureid,"FR")!=0 | strpos(ventureid,"GD")!=0, noconstant
reg irr profit if strpos(ventureid,"BR")!=0 | strpos(ventureid,"DR")!=0, noconstant


save "${output}ReconstructedIRR.dta", replace

merge 1:1 ventureid using "${output}irr_results_OR0.5_VSDO1_VSDR1_VSDT0_VSRV1_VSRT0_INV1_INT0.dta"
twoway (scatter irr profit if strpos(ventureid,"BR")==0 & strpos(ventureid,"FR")==0) ///
	   (scatter irr profit if strpos(ventureid,"FR")!=0 | strpos(ventureid,"GD")!=0) ///
	   (scatter irr profit if strpos(ventureid,"BR")!=0 | strpos(ventureid,"DR")!=0), legend(label(1 "ALL") label( 2 "FR") label( 3 "BR"))



*drop HYP*