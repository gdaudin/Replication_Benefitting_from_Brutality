	
	if lower(c(username)) == "guillaumedaudin" global dir "~/Répertoires GIT/Replication_Benefitting_from_Brutality"
	cd "$dir"
	global output "$dir/output/"
	global graphs "$dir/graphs"
	global tstddb "$dir/external data/"

	if lower(c(username)) == "xronkl"	global dir xxx

		*Preliminary 
	*IMPORT TSTD DATASET
	* Only do it once, then we will work with the dta file created here (tstddb-exp-2020.dta)
	import spss using "${tstddb}/tstddb-exp-2020.sav", clear
	tostring(VOYAGEID), replace
	save "tstddb-exp-2020.dta", replace



	*Creating datasets

	*do "${dir}/do files/Import external data.do" 
	do "${dir}/do files/Import own data.do" /*606 ventures 685 voyages*/ /*This works from the post-merged csv files*/
	do "${dir}/do files/Unique voyages db.do" /*This creates a db of voyages in the data*/
	
	*Creating an enriched venture dataset
	do "${dir}/do files/Enrich voyages and save ventures.do"
	do "${dir}/do files/Enrich ventures db.do"
	do "${dir}/do files/Compare and select sample.do" //Table 3 & 4 BB//
	
	/*This introduces the transactions to the venture dataset*/
	do "${dir}/do files/Database for profit and IRR computation.do"
	do "${dir}/do files/Profit computation.do" /*387 ventures and 446 voyages*/


		********
	do "${dir}/do files/Descriptive statistics of profit.do" /*Small table 2 BB Profit by flag for all sample.*/
		*/ Average profitability of the transatlantic slave trade, by nationality of trader, 1730-1830 */
		*/ comes from here. 
		///The stars in the column "Total" should be disregarded. They are just a consequence of the way I have programmed, but I do not seem to be able
		///to find an easy better way.
		///table 2 Average profitability BB///

	do "${dir}/do files/Profit graphs.do" /*Figures 2 and 3 and 4 in BB*/
	
	*****
	
	do "${dir}/do files/Profit analysis - survey method.do" /// Appendix table
	do "${dir}/do files/Profit analysis - synchronisation.do" 
	
	


	**For IRR computations
	do "${dir}/do files/IRR computation.do"  /*uses do "${dir}/do files/irrGD.do"*/ 
	**To transform profits into IRR (this is long)
	***previous solution if you want to work with a limited number of ventures