	
	if lower(c(username)) == "guillaumedaudin" global dir "~/Répertoires GIT/Replication_Benefitting_from_Brutality"
	cd "$dir"
	global output "$dir/output/"
	global graphs "$dir/graphs"
	global tstddb "$dir/external data/"

	if lower(c(username)) == "xronkl"	global dir xxx

		*Preliminary 
	*IMPORT TSTD DATASET
	* Currently not used section - if we want to import again, delete the old version of the TSTD.dta
	*unzipfile "${tstddb}/external data/tstddb-exp-2020.sav.zip", replace
	*import spss using "${tstddb}/external data/tstddb-exp-2020.sav", clear
	*erase "${tstddb}/external data/tstddb-exp-2020.sav"
	*tostring(VOYAGEID), replace
	*save "tstddb-exp-2020.dta", replace



	*Creating datasets
	do "${dir}/do files/Port shares computation.do"
	do "${dir}/do files/Import external data.do" 
	do "${dir}/do files/Import own data.do" /*606 ventures 685 voyages*/ /*This works from the post-merged csv files*/
	do "${dir}/do files/Unique voyages db.do" /*This creates a db of voyages in the data*/
	do "${dir}/do files/For careers.do" /*Work on tstd, enriched when possible with our data*/
	
	*Creating an enriched venture dataset
	do "${dir}/do files/Enrich voyages and save ventures.do"
	do "${dir}/do files/Enrich ventures db.do"
	do "${dir}/do files/Compare and select sample.do" //Table 3 & 4 BB//
	
	/*This introduces the transactions to the venture dataset*/
	do "${dir}/do files/Database for profit and IRR computation.do"
	do "${dir}/do files/Profit computation.do" /*387 ventures and 446 voyages*/
	
	
	do "${dir}/do files/Profit analysis - survey method.do" /// Appendix table
	do "${dir}/do files/Profit analysis - synchronisation.do" 
	
	
	********
	do "${dir}/do files/Descriptive statistics of profit.do" /*Small table 2 BB Profit by flag for all sample.*/
		*/ Average profitability of the transatlantic slave trade, by nationality of trader, 1730-1830 */
		*/ comes from here. 
		///The stars in the column "Total" should be disregarded. They are just a consequence of the way I have programmed, but I do not seem to be able
		///to find an easy better way.
		///table 2 Average profitability BB///

	
	do "${dir}/do files/Profit graphs.do" /*Figures 2 and 3 and 4 in BB*/
	

	**For IRR computations
	do "${dir}/do files/IRR computation.do"  /*uses do "${dir}/do files/irrGD.do"*/ 
	**To transform profits into IRR (this is long)
	***previous solution if you want to work with a limited number of ventures


/*
	****Robustess	
	do "${dir}/do files/DS -- profit graphs -- profit analysis  -- Robustness.do" /*only calls different programs, but long*/
	**We are not using these tables (which fully reproduce the main analysis for each hypothesis)