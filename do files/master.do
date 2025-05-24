	
	if lower(c(username)) == "guillaumedaudin" {
		global dir "~/Répertoires GIT/slaveprofits data and programs"
		cd "$dir"
		global output "~/Répertoires GIT/slaveprofits data and programs/output/"
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



	*Preliminary 
	*IMPORT STDT DATASET
	* Currently not used section - if we want to import again, delete the old version of the TSTD.dta
	*unzipfile "${dir}/external data/tastdb-exp-2020.sav.zip", replace
	*import spss using "${dir}/external data/tastdb-exp-2020.sav", clear
	*erase "${dir}/external data/tastdb-exp-2020.sav"
	*tostring(VOYAGEID), replace
	*save "tastdb-exp-2020.dta", replace

	*Creating datasets
	do "${dir}/do files/Port shares computation.do"
	do "${dir}/do files/Import data.do" /*606 ventures 685 voyages*/
	do "${dir}/do files/Unique voyages db.do" /*This creates a db of voyages in the data*/
	do "${dir}/do files/For careers.do" /*Work on tsdt, enriched when possible with our data*/
	
	*Creating an enriched venture dataset
	do "${dir}/do files/Enrich voyages and save ventures.do"
	do "${dir}/do files/Enrich ventures db.do"
	do "${dir}/do files/Compare and select sample.do" //Table 3 & 4 BB//
	
	/*This introduces the cash flows*/
	do "${dir}/do files/Database for profit and IRR computation.do"
	do "${dir}/do files/Profit computation.do" /*387 ventures and 446 voyages*/
	
	do "${dir}/do files/Profit analysis - survey method.do" /// Appendix table
	blif
	do "${dir}/do files/Profit analysis - synchronisation.do" 
	
	
	********
	do "${dir}/do files/Descriptive statistics of profit.do" /*I believe the small table 6 .*/
		*/ Average profitability of the transatlantic slave trade, by nationality of trader, 1730-1830 */
		*/ comes from here. 
		///The stars in the column "Total" should be disregarded. They are just a consequence of the way I have programmed, but I do not seem to be able
		///to find an easy better way.
		///table 2 Average profitability BB///

	
	do "${dir}/do files/Profit graphs.do" /*Figures 2 and 3 and 4 in BB*/
	

	/*
	do "${dir}/do files/Profit analysis.do" ///***Explaining profits : GG**///
	do "${dir}/do files/Profit two parts regressions.do"
	do "${dir}/do files/Profit two parts regressions--various hypothesis.do"

	

	**For imputation
	do "${dir}/do files/Database for profit computation -- imputed.do"
	profit_computation 0.5 1 1 0 1 0 1 0 IMP 
	profit_computation 0.5 1 1 0 1 0 1 0 onlyIMP 

	profit_analysis 0.5 1 1 0 1 0 1 0 IMP
	profit_analysis 0.5 1 1 0 1 0 1 0 onlyIMP

	**Descriptive statistics, comparing different hypothesis


	do "${dir}/do files/Descriptive statistics of explaining variables.do"
	

*/
	**For IRR computations
	do "${dir}/do files/IRR computation.do"  /*uses do "${dir}/do files/irrGD.do"*/ 
	**To transform profits into IRR (this is long)
	***previous solution if you want to work with a limited number of ventures
	*do "${dir}/do files/Transforming profit into IRR.do" /*uses do "${dir}/do files/irrGD.do"*/ 
	*I think the idea of that program is to compute a typical chronolgy of returns and apply it to the profits of the ventures.
	*Maybe too complicated and not done finaly.?


	****Robustess	
	do "${dir}/do files/DS -- profit graphs -- profit analysis  -- Robustness.do" /*only calls different programs, but long*/
	**We are not using these tables (which fully reproduce the main analysis for each hypothesis)

	**Various 

	do "${dir}/do files/Length Europe-Europe computation (exploratory).do" /*Not the one we use : exploratory*/
	