
clear
*ssc install estout, replace
*ssc install outreg2, replace



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
