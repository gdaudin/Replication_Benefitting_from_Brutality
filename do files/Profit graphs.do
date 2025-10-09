
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


capture program drop profit_graphs
program define profit_graphs
args OR VSDO VSDR VSDT VSRV VSRT INV INT IMP
*eg profit_graphs 0.5 1 1 0 1 0 1 0 for the baseline
* eg profit_graphs 0.5 1 1 0 1 0 1 0 IMP for the baseline + imputed



use "${output}Ventures&profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.dta", clear

*keep if completedataonoutlays=="yes" & completedataonreturns=="yes"
drop if completedataonoutlays=="no" & completedataonreturns=="no"
drop if profit ==.

label var profit "(Net returns over net outlays) -1"


graph bar (count) profit [fweight=numberofvoyages], over(nationality) scheme(s1color)
graph export "$graphs/nbr_by_nationality_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png", as(png) replace

hist YEARAF [fweight=numberofvoyages], freq scheme(s1color) start(1720) width(5) xtitle(Year departed Africa (mean if multiple voyages)) ytitle(Frequency)
graph export "$graphs/hist_venture_by_year_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png",as(png) replace


quietly summarize profit
local m=r(mean)
hist profit, freq norm ///
	note(`"mean = `=string(`m',"%6.2f")'%"') ///
	scheme(s1color) name(All_nationalities, replace) title("All sample")

graph export "$graphs/hist_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png",as(png) replace
 
quietly summarize profit
local max=r(max)
display "`max'"

local natlist "Danish Dutch English French Spanish"
if "`IMP'"=="onlyIMP" local natlist "Dutch English French"


foreach nat in `natlist' {
	quietly summarize profit if nationality =="`nat'"
	local m=r(mean)
	hist profit [fweight=numberofvoyages] if nationality =="`nat'", width(0.15) freq norm ///
	note(`"mean = `=string(`m',"%6.2f")'%"') ///
	xscale(range(-1 `max')) xlabel(-1 (0.5) `max') ///
	scheme(s1color) title ("`nat'") name(`nat', replace)
}
graph combine `natlist' All_nationalities, scheme(s1color)
graph export "$graphs/hist_by_nationality_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png",as(png) replace

label var YEARAF "Year departed Africa"

twoway 	(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Danish", msymbol(dh) mcolor(green)) ///
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Dutch", msymbol(Oh) mcolor(orange)) ///		
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="English", msymbol(X) mcolor(purple)) ///
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="French", msymbol(plus) mcolor(blue)) ///
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Spanish", msymbol(th) mcolor(sand)), ///
		legend(label(1 "Danish") label(2 "Dutch") label(3 "English")  ///
		label(4 "French") label(5 "Spanish") rows(1)) scheme(s1color) ///
		xscale(range(1725 1835)) xlabel(1725 (25)1825) ytitle("") name(scatter_year_profit_all, replace)

twoway 	(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="English", msymbol(X) mcolor(purple)), ///
		title("English ventures") xscale(range(1725 1835)) xlabel(1725 (25)1825) xtitle("") yscale(range(-1 3)) ylabel(-1 (1) 3) ytitle("") ///
		scheme(s1color) name(scatter_year_profit_EN, replace)

twoway 	(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Dutch", msymbol(Oh) mcolor(orange)), ///
		title("Dutch ventures") xscale(range(1725 1835)) xlabel(1725 (25)1825) xtitle("") yscale(range(-1 3)) ylabel(-1 (1) 3)  ///
		scheme(s1color)  name(scatter_year_profit_ND, replace)

twoway 	(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Danish", msymbol(dh) mcolor (green)) ///
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="French", msymbol(plus) mcolor(blue)) ///
		(scatter profit YEARAF [fweight=numberofvoyages] if nationality=="Spanish", msymbol(th) mcolor(sand)), ///
		 xscale(range(1725 1835)) xlabel(1725 (25)1825) yscale(range(-1 3)) ylabel(-1 (1) 3)  ///
		legend(label(1 "Danish") label(2 "French") label(3 "Spanish") rows(1)) ///
		scheme(s1color) name(scatter_year_profit_3c, replace)

graph combine  scatter_year_profit_ND scatter_year_profit_EN  scatter_year_profit_3c scatter_year_profit_all, ///
		note("Marker size proportional to number of voyages") ycommon xcommon

graph export "$graphs/scatter_year_profit_OR`OR'_VSDO`VSDO'_VSDR`VSDR'_VSDT`VSDT'_VSRV`VSRV'_VSRT`VSRT'_INV`INV'_INT`INT'`IMP'.png",as(png) replace

end

profit_graphs 0.5 1 1 0 1 0 1 0
/*
profit_graphs 0.5 1 1 0 1 0 1 0 IMP
profit_graphs 0.5 1 1 0 1 0 1 0 onlyIMP	
