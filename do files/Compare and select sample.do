clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "$dir/output/"
	global graphs "$dir/graphs/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits data and programs"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}

use "${output}Venture all", clear
gen sample =  1 if completedataonoutlays!="no" & completedataonreturns!="no"
table nationality if sample==1

use "${output}voyages", clear

merge 1:1 VOYAGEID using "${tastdb}tastdb-exp-2020_corr.dta"
drop _merge
replace FATE4=4 if FATE4==.

codebook NATINIMP
label list labels18

/*NATINIMP coding in stdt
7     Great Britain
8     Netherlands
10    France
*/




replace NATINIMP=1 if nationality =="Spanish" & NATINIMP==.
replace NATINIMP=7 if nationality =="English" & NATINIMP==.
replace NATINIMP=8 if nationality =="Dutch" & NATINIMP==.
replace NATINIMP=10 if nationality =="French" & NATINIMP==.
replace NATINIMP=15 if nationality =="Danish" & NATINIMP==.

assert NATINIMP==10 if nationality=="French"


gen NATINIMP_tab3 = NATINIMP
replace NATINIMP_tab3=30 if NATINIMP ==2 | NATINIMP ==3 | (NATINIMP >=12  & NATINIMP !=. & NATINIMP==12)
replace NATINIMP_tab3=6 if NATINIMP==4 | NATINIMP==5
replace NATINIMP_tab3=3 if NATINIMP==1 | NATINIMP==3
replace NATINIMP_tab3=15 if NATINIMP==11 | NATINIMP==15
label value NATINIMP_tab3 labels18

gen sample =  1 if data==1 | data==2
replace sample=0 if sample==.
label define sample_l 0 "Whole TSTD" 1 "Our sample" 
label values sample sample_l

table (NATINIMP_tab3) (sample),  statistic (freq) statistic(percent, across(NATINIMP_tab3)) totals(sample)


collect style header NATINIMP_tab3, title(hide)
collect style header sample, title(hide)
collect style cell result[percent], nformat (%3.0fc)
collect layout (NATINIMP_tab3[7 8 10 3 15 6 9 30 .m]) (sample[1 0]#result) 
**For table 3 "Representativity of our sample (flag)"":
tabi 239 11796 \  101 1606 \ 84 4141 \ 17 1911 \5 408 \ 0 11363 \ 0 2275 \ 0 16, chi2  
collect export "${output}Compare_Sample_Nationality.txt", as(txt) replace
collect export "${output}Compare_Sample_Nationality.docx", as(docx) replace


hist YEARAF if sample==1, freq scheme(s1color) start(1720) width(5) xtitle(Year departed Africa)
graph export "$graphs/hist_voyage_by_year_Baseline.png",as(png) replace

*keep if NATINIMP==7 | NATINIMP==8 | NATINIMP == 10
gen three_nat=0
replace three_nat=1 if (NATINIMP==7 | NATINIMP==8 | NATINIMP == 10)

twoway (histogram YEARAF  if (data >=1 & !missing(data)) &  three_nat==1 & YEARAF>=1730 & YEARAF<=1815, frac start(1730) width(5) color(red%30)) ///
	 (histogram YEARAF  if  three_nat==1 &  YEARAF>=1730 & YEARAF<=1815,  frac start(1730) width(5) color(green%30)), ///
	 legend(order(1 "Sample" 2 "TSTD (expanded)" )) 

***This convinces me that the right common support to look at is 1750-1795
replace sample=0 if YEARAF >1795 | YEARAF < 1750 | nationality =="Danish" | nationality =="Spanish"

gen support=0
replace support=1 if three_nat==1 & YEARAF >= 1750 & YEARAF <=1795

**Using war and peace for periods
gen period=1 if YEARAF<=1755
replace period=1 if YEARAF >1755 & YEARAF<=1762
replace period=2 if YEARAF >1762 & YEARAF <=1777
replace period=3 if YEARAF >1777 & YEARAF <=1783
replace period=4 if YEARAF >1783 & YEARAF <=1792
replace period=4 if YEARAF >1792 & !missing(YEARAF)
assert !missing(period) if sample==1

label define period_l 1 "1750-1762" 2 "1763-1778" 3 "1778-1783" 4 "1784-1795"
label values period period_l

collect clear
collect: table (NATINIMP_tab3) (period) if support==1,  statistic (freq) statistic(proportion)  nformat(%3.2f)
collect rename Table TSTD
collect : table (NATINIMP_tab3) (period) if sample==1,  statistic (freq) statistic(proportion)   nformat(%3.2f)
collect rename Table Sample
collect combine tab = TSTD Sample 
collect style header NATINIMP_tab3 collection period result, title(hide)
collect style header  result, level(hide)
collect style cell result[frequency], nformat (%5.0fc)
collect layout (NATINIMP_tab3#collection)(period#result)

collect export "${output}Compare_Sample_NationalityxPeriod.txt", as(txt) replace
collect export "${output}Compare_Sample_NationalityxPeriod.docx", as(docx) replace

table (FATE4) if sample==1
codebook FATE4 if sample==1

***Fate
bysort VOYAGEID: assert _N==1

merge m:1 ventureid using "${output}Venture all.dta"
assert _merge==3 if sample==1
***There are some missing sample
replace sample=1 if data==1 | data==2
replace sample=0 if sample==.
replace sample=0 if YEARAF >1795 | YEARAF < 1750 | nationality =="Danish" | nationality =="Spanish"
replace support=1 if sample==1


**In Venture all.dta we have some voyages that are duplicates (multiple sources of information of varying quality). We remove them and keep the best quality.
gsort VOYAGEID sample

by VOYAGEID: drop if _N != _n
bysort VOYAGEID: assert _N==1
drop _merge

save  "${output}TSTD_enriched.dta", replace

replace FATE4=4 if FATE4==.
table (FATE4) if sample==1
codebook FATE4 if sample==1


collect clear
collect: table (FATE4) if support==1,  statistic (freq) statistic(proportion)  nformat(%3.2f)
collect rename Table TSTD
collect: table (FATE4) if sample==1,  statistic (freq) statistic(proportion)  nformat(%3.2f)
collect rename Table Sample
collect combine tab = TSTD Sample 
collect style header FATE4 collection, title(hide)
collect style header result, level(hide)
collect style cell result[frequency], nformat (%5.0fc)
collect layout (FATE4)(collection#result)
tabi 337 6836 \  22 735 \ 12 549 \ 3 187, chi2  
collect export "${output}Compare_Sample_Fate.docx", as(docx) replace
collect export "${output}Compare_Sample_Fate.txt", as(txt) replace

***Quantitative outcome variables
**Mortality
gen MORTALITY=(SLAXIMP-SLAMIMP)/SLAXIMP
replace MORTALITY=VYMRTRAT if missing(MORTALITY)
label var MORTALITY "Enslaved person mortality rate during Middle Passage"

**Crowding
gen crowd=SLAXIMP/TONMOD
label var crowd "Number of embarked enslaved persons per ton"

**Disembarked slaves per ton
gen DisSlavePerTon=SLAMIMP/TONMOD
label var  DisSlavePerTon "Number of disembarked enslaved persons per ton"

save  "${output}TSTD_enriched.dta", replace


/*
**Look at the tonnage repartition
twoway (histogram TONMOD  if (data >=1 & !missing(data)) &  three_nat==1 & YEARAF>=1730 & YEARAF<=1815, frac color(red%30)) ///
 	(histogram TONMOD  if  three_nat==1 &  YEARAF>=1730 & YEARAF<=1815,  frac color(green%30)), ///
 	legend(order(1 "Sample" 2 "TSTD (expanded)" )) 

/*
gen weight = 2
replace weight=1 if sample==1 & YEARAF >= 1765 & YEARAF <=1775


ksmirnov YEARAF,by(dupindicator) 

twoway (histogram YEARAF [fweight=weight] if dupindicator==1 &  YEARAF>=1745 & YEARAF<=1795 & three_nat==1, frac start(1745) width(5) color(red%30)) ///
	 (histogram YEARAF [fweight=weight] if dupindicator==0  &  YEARAF>=1745 & YEARAF<=1795 & three_nat==1,  frac start(1745) width(5) color(green%30)), ///
	 legend(order(1 "Sample" 2 "TSTD (expanded)" )) 

*/
/*
replace nationality="French" if NATINIMP==10 & nationality==""
replace nationality="English" if NATINIMP==7 & nationality==""
replace nationality="Dutch" if NATINIMP==8 & nationality==""
*/


******Add variables of interest

****add port shares
merge m:1 YEARAF MJBYPTIMP using "${output}port_shares.dta", keep(1 3)
drop _merge

* APPEND SLAVE PRICES
merge m:1 YEARAF using "${output}Prices.dta"
drop if _merge==2
drop _merge
gen pricemarkup=priceamerica/priceafrica
label var pricemarkup "Slave price markup between America and Africa"
*APPEND WARS
merge m:1 YEARAF nationality using "${output}European wars.dta"
drop if _merge==2
drop _merge
***APPEND NEUTRALITY
merge m:1 YEARAF nationality using  "${output}Neutrality.dta"
drop if _merge==2
drop _merge
*****
gen big_port=0
replace big_port=1 if port_share>0.01 & !missing(port_share)
label var big_port "Big African slave-trading port"

***Simplify trading regions
decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
encode MAJMAJBYIMP, gen(MAJMAJBYIMP_num)
label var MAJMAJBYIMP "African region of trade"
label var MAJMAJBYIMP_num "African region of trade"


* MERGE WITH Career DATASET (CAPTAIN)
generate CAPTAIN = ""
replace CAPTAIN = CAPTAINA
*replace CAPTAIN = nameofthecaptain if CAPTAIN==""
replace CAPTAIN="" if CAPTAIN=="."
merge m:1 CAPTAIN YEARAF MAJMAJBYIMP using "${output}Captain.dta"
drop if _merge==2
*For debugging
*br CAPTAIN YEARAF ventureid VOYAGEID if _merge==1 & (CAPTAIN!="" & YEARAF !=.)
assert (CAPTAIN=="" | YEARAF ==.) if _merge==1 	&  data >=1
	
drop _merge


* MERGE WITH Career DATASET (OUTFITTER)
*We assume we are right with outfitters
replace OWNERA= nameofoutfitter if nameofoutfitter!=""
generate OUTFITTER = ""
replace OUTFITTER = OWNERA if OUTFITTER==""
replace OUTFITTER="" if OUTFITTER=="."
merge m:1 OUTFITTER YEARAF MAJMAJBYIMP using "${output}OUTFITTER.dta"
drop if _merge==2
*For debugging
*br OUTFITTER YEARAF ventureid VOYAGEID if _merge==1 & (OUTFITTER!="" & YEARAF !=.)
assert (OUTFITTER=="" | YEARAF ==. | MAJMAJBYIMP=="") if _merge==1 &  data >=1
drop _merge


gen captain_experience_d=0 if !missing(captain_experience)
replace captain_experience_d=1 if captain_experience>0 & !missing(captain_experience)
label var captain_experience_d "Not the first voyage of the captain"


gen captain_regional_experience_d=0 if !missing(captain_regional_experience)
replace captain_regional_experience_d=1 if captain_regional_experience>0 & !missing(captain_regional_experience)
label var captain_regional_experience_d "Not the first voyage of the captain in the region"

gen captain_total_career_d=0 if !missing(captain_total_career)
replace captain_total_career_d=1 if captain_total_career>1 & !missing(captain_total_career)


gen OUTFITTER_experience_d=0 if !missing(OUTFITTER_experience)
replace OUTFITTER_experience_d=1 if OUTFITTER_experience>0 & !missing(OUTFITTER_experience)
label var OUTFITTER_experience_d "Not the first voyage of the outfitter"

gen OUTFITTER_regional_experience_d=0 if !missing(OUTFITTER_regional_experience)
replace OUTFITTER_regional_experience_d=1 if OUTFITTER_regional_experience>0 & !missing(OUTFITTER_regional_experience)
label var OUTFITTER_regional_experience_d "Not the first voyage of the outfitter in the region"

gen OUTFITTER_total_career_d=0 if !missing(OUTFITTER_total_career)
replace OUTFITTER_total_career_d=1 if OUTFITTER_total_career>1 & !missing(OUTFITTER_total_career)

save  "${output}TSTD_enriched.dta", replace

*/
************Compare Full TSTD, Support TSTD, sample for some variables
expand 2 if support==1, gen(dupindicator_support)
expand 2 if sample==1 & dupindicator==1,gen(dupindicator_sample)

gen group = .
replace group = 0 if dupindicator_support==0
replace group = 1 if dupindicator_support==1 & dupindicator_sample==0
replace group = 2 if dupindicator_sample==1

label define group 0 "TSTD" 1 "TSTD-suport" 2 "sample"
label value group group




global varlist_o  /*YEARAF  TONMOD*/ crowd /*SLAXIMP*/ MORTALITY DisSlavePerTon /*  pricemarkup*/

table (var) group, ///
	statistic(mean $varlist_o)  ///
	statistic(median $varlist_o)  ///
	statistic(sd $varlist_o)  ///
	statistic(max $varlist_o) ///
	statistic(min $varlist_o) ///
	statistic(count $varlist_o) ///
	name(DS_Qvar) replace


/*
global varlist_d war neutral big_port captain_experience_d OUTFITTER_experience_d

table (var) group , ///
	statistic(mean $varlist_d)  ///
	statistic(median $varlist_d)  ///
	statistic(sd $varlist_d)  ///
	statistic(count $varlist_d) ///
	name(DS_Dvar) replace


collect combine DS= DS_Qvar DS_Dvar, replace



global varlist_count  SLAXIMP   TONMOD
*/
collect style cell var, nformat(%5.2fc)
collect style cell result[count], nformat(%5.0fc)
/*
collect style cell var[profit], nformat(%5.3f)
collect style cell var[YEARAF], nformat(%5.0f)
collect style cell var[$varlist_count], nformat(%12.0fc)
collect style cell var[$varlist_count]#result[max min], nformat(%12.0fc)
*/
/*
collect layout (var[war neutral big_port] # result[mean median sd count] ///
	var[TONMOD SLAXIMP crowd MORTALITY ] # result[mean median sd min max count] ///
	/*var[OUTFITTER_experience_d captain_experience_d] # result[mean median sd count]*/) (group [0 1 2]) 
*/

collect layout (var[crowd MORTALITY DisSlavePerTon] # result[mean median sd count]) (group [1 2])

collect export "${output}Compare TSTD__support__sample.docx", as(docx) replace
collect export "${output}Compare TSTD__support__sample.txt", as(txt) replace

/*
****K_Smirnov tests

gen ksmirnov_group = group
replace ksmirnov_group = . if group==0

collect clear

local labels

local i 1
foreach var of varlist $varlist_o {
	collect r(D) r(p): ksmirnov `var',by(ksmirnov_group)
	local labels  `labels' `i' "`var'"
	local i = `i'+1    

}

collect label levels cmdset `labels', modify
collect style cell result, nformat(%4.2fc)
collect layout (cmdset) (result)
collect title "KS test between TSTD (same support) and sample"
collect preview

collect clear
*/
****Ttests
replace group = . if group==0

local labels

local i 1

foreach var of varlist $varlist_o /*$varlist_d*/ {
	collect r(N_1) r(mu_1) r(sd_1) r(N_2) r(mu_2) r(sd_2) r(p):  ttest `var', by(group)
	local lab : variable label `var'
	local labels  `labels' `i' "`lab'"
	local i = `i'+1    
}
 macro list

collect remap result[N_1 mu_1 sd_1] = TSTD_same_support
collect remap result[N_2 mu_2 sd_2] = Sample
collect remap result[p] = Difference
collect style header TSTD_same_support Sample Difference, title(name)
collect style column, dups(center) width(asis)
collect label levels TSTD_same_support N_1 N mu_1 Mean sd_1 "St. dev"
collect label levels Sample N_2 N mu_2 Mean sd_2 "St. dev"
collect label levels Difference p p-value
collect style cell TSTD_same_support[mu_1 sd_1] Sample[mu_2 sd_2] Difference[p], nformat(%4.2fc)
collect style cell TSTD_same_support[N_1], nformat(%5.0fc)
collect style header cmdset, title(hide)
collect title "Ttest test between TSTD (same support) and sample"
collect label levels cmdset `labels', modify
collect layout (cmdset) (TSTD_same_support Sample Difference )


collect export "${output}Compare TSTD__support__sample_withTTest.docx", as(docx) replace
collect export "${output}Compare TSTD__support__sample_withTTest.txt", as(txt) replace



/*

gen sampleTSTD=0
replace sampleTSTD=1 if YEARAF >= 1750 & YEARAF <=1790 & (NATINIMP==7 | NATINIMP==8 | NATINIMP == 10)

preserve
keep if sampleTSTD==1

expand 2 if  sample==1,gen(dupindicator)

tab dupindicator NATINIMP, chi2

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


**** Post-stratification
**Issue : we have no French observation before 1763
use "${output}TSTD_enriched.dta", clear


keep if NATINIMP==7 | NATINIMP==8 | NATINIMP == 10
keep if YEARAF >= 1750 & YEARAF <=1795

table FATE4 NATINIMP
table FATE4 NATINIMP if sample==1

**This shows no instance in the sample of France / Original goal
***thwarted (human agency)
**So we concatenate the two "original goal thwarted"

gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3

tabulate NATINIMP FATE_3c, cell


gen strata = FATE_3c*100+NATINIMP
collapse (count) pop_size=NATINIMP, by(strata)
save "${output}pop_totals.dta", replace

use "${output}TSTD_enriched.dta", clear

gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3
gen strata = FATE_3c*100+NATINIMP

merge m:1 strata using "${output}pop_totals.dta"
drop _merge
replace sample=1 if (data >=1 & !missing(data)) & (NATINIMP==7 | NATINIMP==8 | NATINIMP == 10)
keep if YEARAF >= 1750 & YEARAF <=1795
drop if sample==0
egen pop_size_sample=count(NATINIMP), by(strata)
gen post_wt=(pop_size/pop_size_sample)

tabulate NATINIMP FATE_3c [iweight=post_wt], cell

*******
keep VOYAGEID post_wt
save "${output}voy_weight.dta", replace

*****ipfraking
use "${output}TSTD_enriched.dta", clear
merge 1:1 VOYAGEID using  "${output}voy_weight.dta"
drop _merge
keep if NATINIMP==7 | NATINIMP==8 | NATINIMP == 10
keep if YEARAF >= 1750 & YEARAF <=1795
gen FATE_3c = FATE4
replace FATE_3c= 2 if FATE4 ==3



**Using quartiles for tonnage
summarize TONMOD if support==1, det

gen tonnage=1 if TONMOD <=136
replace tonnage=2 if TONMOD > 136 & TONMOD<=183
replace tonnage=3 if TONMOD > 183 & TONMOD<=272
replace tonnage=4 if TONMOD > 272 & !missing(TONMOD)

tab tonnage if support==1
tab tonnage if sample==1
replace tonnage=. if support ==0



gen pop = 1
version 14 : total pop, over(period, nolab)
matrix mat_period=e(b)
matrix rownames mat_period=period

version 14 : total pop, over(NATINIMP, nolab)
matrix mat_NATINIMP=e(b)
matrix rownames mat_NATINIMP=NATINIMP

version 14 : total pop, over(FATE_3c, nolab)
matrix mat_FATE_3c=e(b)
matrix rownames mat_FATE_3c=FATE_3c

version 14 : total pop, over(tonnage, nolab)
matrix mat_tonnage=e(b)
matrix rownames mat_tonnage=tonnage


keep if sample==1


ipfraking [pw=post_wt], /*
	*/ctotal(mat_period mat_NATINIMP mat_FATE_3c) generate (frak_post_wt)
	
ipfraking [pw=post_wt] if tonnage !=., /*
	*/ctotal(mat_period mat_NATINIMP mat_FATE_3c mat_tonnage) generate (frak2_post_wt)


tabulate NATINIMP FATE_3c  [iweight=frak_post_wt], cell nofreq
tabulate NATINIMP FATE_3c  [iweight=post_wt], cell nofreq

tabulate NATINIMP tonnage  [iweight=frak2_post_wt], cell nofreq
tabulate NATINIMP tonnage  [iweight=post_wt], cell nofreq

twoway (scatter post_wt frak_post_wt) (lfit post_wt frak_post_wt)
twoway (scatter frak2_post_wt frak_post_wt) (lfit frak2_post_wt frak_post_wt)

save "${output}voy_weight.dta", replace

collapse (sum) post_wt frak_post_wt frak2_post_wt, by(ventureid)

*To treat the missiong values
replace frak2_post_wt = . if frak2_post_wt ==0

merge 1:1 ventureid using "${output}Enriched ventures.dta", nogen

save "${output}Enriched ventures.dta", replace


















