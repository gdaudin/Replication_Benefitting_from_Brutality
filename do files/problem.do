* Do file to identify problem in profit rate 



* 0. PREAMBLE 
clear
if lower(c(username)) == "kraemer" {
	!subst X: /d
	!subst X:   "C:\Users\Kraemer\Documents"
	capture cd "X:\slaveprofits\"
	if _rc != 0 cd  "C:\Users\Kraemer\Documents\slaveprofits"
	global output "C:\Users\Kraemer\Documents\slaveprofits\script claire\output"
	global other "C:\Users\Kraemer\Documents\slaveprofits\script claire"
	global slaves "C:\Users\Kraemer\Documents\slaveprofits\script claire\slaves"
	global dofile "C:\Users\Kraemer\Documents\slaveprofits\script claire\do"

		}

else if lower(c(username)) == "claire" {
	!subst X: /d
	!subst X:   "/Users/claire/"
	capture cd "X:/slaveprofits/"
	if _rc != 0 cd  "/Users/claire/slaveprofits/"
	global output "/Users/claire/Desktop/temp"
	global other "/Users/claire/slaveprofits/script claire/"
	global slaves "/Users/claire/slaveprofits/script claire/slaves/"
	global dofile "/Users/claire/slaveprofits/script claire/do/"

}

else if lower(c(username)) == "guillaumedaudin" {
	set trace on
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global other "$dir/script claire/"
	global slaves "$dir/script claire/slaves/"
	global dofile "$dir/script claire/do/"

}


qui do "${dofile}Import data do-file.do" 
qui do "${dofile}Profits do-file.do" 


* 1. SELECTION 
use "${output}Problemid.dta", replace 
keep if strpos(ventureid, "GD") 


* 2.  MERGE WITH GUILLAUME RESULTS 
preserve 
tempfile tmp
import delimited "${other}Comparison JEH w Klas Stata code.csv", encoding(UTF-8) clear 
keep v2 tauxdeprofitglobal comment 
ren v2 ventureid
save `tmp'
restore
merge m:1 ventureid using `"`tmp'"', nogen 



* 3 PROBLEM IDENTIFICATION VARIABLE 
gen diffresuultprofit = abs(profit - tauxdeprofitglobal)

gen problem = "."
replace problem = "OK" if diffresuultprofit < 0.2 & diffresuultprofit != .
replace problem = "Substantial mismatch" if diffresuultprofit >= 0.2  & diffresuultprofit != .
bysort ventureid : replace problem = problem[_n-1] if problem == "." 
// substantial mismatch 

replace problem = "guillaume found it"  if profit == -1 & tauxdeprofitglobal != .
// guillaume found a profit 

replace problem = problem + " and data of returns displayed as no complete" if completedataonreturns == "no" & typeofcash =="Return"

replace problem = "NA" if profit == -1 & problem != "guillaume found it"
// no value in the literacy 

replace problem = "OK, new value" if profit != . & profit != -1 &  tauxdeprofitglobal == .
// new value computed 

gsort ventureid -problem
by ventureid: gen sort = problem[1] 
replace problem = sort if sort ==  "OK and data of returns displayed as no complete" | sort ==  "Substantial mismatch and data in returns displayed as no complete" | sort ==  "guillaume found it"  | sort ==  "NA" | sort ==   "OK, new value" 
// "no" expenditure complete  but expenditure item present 


* 4. AFTER MANUAL CHECK

replace problem = "Check OK but substantial mismatch" if ventureid == "GD004" 



drop sort
drop if profit == . 
keep venture-remarks  variousrem source profit diff tauxdepro comment problem 
drop typeofcashflow-currency remarks
rename tauxdeprofitglobal JEH2004
order venture profit JEH2004 diff comment  problem  variousrem
sort problem

export delimited using "${other}Problem-JEH2004-now", replace

