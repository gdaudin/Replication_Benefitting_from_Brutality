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

use "${output}voyages", clear

merge 1:1 VOYAGEID using "${tastdb}tastdb-exp-2020.dta"
drop _merge
replace FATE4=4 if FATE4==.

/*NATIONAL coding in stdt
7     Great Britain
8     Netherlands
10    France
*/

replace NATIONAL=7 if nationality =="English" & NATIONAL==.
replace NATIONAL=8 if nationality =="Dutch" & NATIONAL==.
replace NATIONAL=10 if nationality =="French" & NATIONAL==.

keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10

gen sample = 0
replace sample=1 if (data >=1 & !missing(data)) & (NATIONAL==7 | NATIONAL==8 | NATIONAL == 10)

save  "${output}STDT_enriched.dta", replace

expand 2 if sample==1,gen(dupindicator)

twoway (histogram YEARAF  if dupindicator==1 &  YEARAF>=1730 & YEARAF<=1815, frac start(1730) width(5) color(red%30)) ///
	 (histogram YEARAF  if dupindicator==0  &  YEARAF>=1730 & YEARAF<=1815,  frac start(1730) width(5) color(green%30)), ///
	 legend(order(1 "Sample" 2 "STDT (expanded)" )) 

***This convinces me that the right common support to look at is 1750-1795


replace sample=1 if (data >=1 & !missing(data)) & YEARAF >= 1750 & YEARAF <=1795 & (NATIONAL==7 | NATIONAL==8 | NATIONAL == 10)

gen weight = 2
replace weight=1 if sample==1 & YEARAF >= 1765 & YEARAF <=1775


ksmirnov YEARAF,by(dupindicator) 

twoway (histogram YEARAF [fweight=weight] if dupindicator==1 &  YEARAF>=1745 & YEARAF<=1795, frac start(1745) width(5) color(red%30)) ///
	 (histogram YEARAF [fweight=weight] if dupindicator==0  &  YEARAF>=1745 & YEARAF<=1795,  frac start(1745) width(5) color(green%30)), ///
	 legend(order(1 "Sample" 2 "STDT (expanded)" )) 



/*

gen sampleSTDT=0
replace sampleSTDT=1 if YEARAF >= 1750 & YEARAF <=1790 & (NATIONAL==7 | NATIONAL==8 | NATIONAL == 10)

preserve
keep if sampleSTDT==1

expand 2 if  sample==1,gen(dupindicator)

tab dupindicator NATIONAL, chi2

restore
*/

*Ok, let us try weight adjustement...
**https://www.stata.com/meeting/nordic-and-baltic18/slides/nordic-and-baltic18_Pitblado.pdf
**https://www.stata.com/meeting/canada21/slides/Canada21_Islam.pdf
**Ipfracking : https://journals.sagepub.com/doi/full/10.1177/1536867X19830912

*ssc install ipfraking
/*
Use raking when you have marginal totals for multiple variables but not their joint distribution.
Use post-stratification when you have complete joint distributions (e.g., cross-tabulated population totals).
And GREC for continuous auxiliary variable. (Does not exist...	)
*/

**** Post-stratification
**Issue : we have no French observation before 1763
use "${output}STDT_enriched.dta", clear

keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10
keep if YEARAF >= 1750 & YEARAF <=1795

table FATE4 NATIONAL
table FATE4 NATIONAL if sample==1

**This shows no instance in the sample of France / Original goal
***thwarted (human agency)
**So we concatenate the two "original goal thwarted"

gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3

tabulate NATIONAL FATE_3c, cell


gen strata = FATE_3c*100+NATIONAL
collapse (count) pop_size=NATIONAL, by(strata)
save "${output}pop_totals.dta", replace

use "${output}STDT_enriched.dta", clear

gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3
gen strata = FATE_3c*100+NATIONAL

merge m:1 strata using "${output}pop_totals.dta"
drop _merge
replace sample=1 if (data >=1 & !missing(data)) & (NATIONAL==7 | NATIONAL==8 | NATIONAL == 10)
keep if YEARAF >= 1750 & YEARAF <=1795
drop if sample==0
egen pop_size_sample=count(NATIONAL), by(strata)
gen post_wt=(pop_size/pop_size_sample)

tabulate NATIONAL FATE_3c [iweight=post_wt], cell

*******
keep VOYAGEID post_wt
save "${output}voy_weight.dta", replace

*****ipfraking
use "${output}STDT_enriched.dta", clear
merge 1:1 VOYAGEID using  "${output}voy_weight.dta"
drop _merge
keep if NATIONAL==7 | NATIONAL==8 | NATIONAL == 10
keep if YEARAF >= 1750 & YEARAF <=1795
gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3

gen period=1 if YEARAF<=1755
replace period=2 if YEARAF > 1756 & YEARAF<=1762
replace period=3 if YEARAF >1762 & YEARAF <=1777
replace period=4 if YEARAF >1777 & YEARAF <=1783
replace period=5 if YEARAF >1783 & YEARAF <=1792
replace period=6 if YEARAF >1792

gen pop = 1
version 14 : total pop, over(period, nolab)
matrix mat_period=e(b)
matrix rownames mat_period=period

version 14 : total pop, over(NATIONAL, nolab)
matrix mat_NATIONAL=e(b)
matrix rownames mat_NATIONAL=NATIONAL

version 14 : total pop, over(FATE_3c, nolab)
matrix mat_FATE_3c=e(b)
matrix rownames mat_FATE_3c=FATE_3c

keep if sample==1

ipfraking [pw=post_wt], /*
	*/ctotal(mat_period mat_NATIONAL mat_FATE_3c) generate (frak_post_wt)


tabulate NATIONAL FATE_3c [iweight=frak_post_wt], cell nofreq
tabulate NATIONAL FATE_3c [iweight=post_wt], cell nofreq

twoway (scatter post_wt frak_post_wt) (lfit post_wt frak_post_wt)

collapse (sum) post_wt frak_post_wt, by(ventureid)

save "${output}venture weight.dta"





/*

erase "${output}STDT_enriched.dta"





svystet 













