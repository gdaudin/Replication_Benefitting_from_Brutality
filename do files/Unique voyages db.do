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


*This is to create a db of unique voyages in our venture data. There are (at least) three challenges :
* - deal with cross-references
* - deal with ventures with multiple voyages
* - make sure we have the maximum data possible per voyage

use "${output}Venture all.dta", clear

***I check whether I indeed have one voyageidintstd for each voyage
gen test = 1+regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*/.*/.*")+regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*/.*") ///
+ regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*/.*/.*") ///
+ regexm(voyageidintstd,".*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*") + regexm(voyageidintstd,".*/.*")

assert (numberofvoyages == test | ventureid=="KR016")
/*KR016 is grouping of 15 Danish voyages included in table 8 in Lauring*/
drop test

*********************Transform the ventures into voyages
keep ventureid voyageidintstd nameofoutfitter nameofthecaptain YEARAF_own numberofvoyages internalcrossref completedataonoutlays completedataonreturns numberofvoyages

replace voyageidintstd=subinstr(voyageidintstd,"/"," / ",.)
replace voyageidintstd=subinstr(voyageidintstd,"  "," ",.)
replace voyageidintstd=subinstr(voyageidintstd,"//","/ /",.)

forvalue i = 1/15 {
    
    gen voy`i' =word(voyageidintstd,2*`i'-1)
}
/*
gen voy2=word(voyageidintstd,3)
gen voy3=word(voyageidintstd,5)
gen voy4=word(voyageidintstd,7)
gen voy5=word(voyageidintstd,9)
gen voy6=word(voyageidintstd,11)
gen voy7=word(voyageidintstd,13)
*/


reshape long voy, i(ventureid) j(voyagenumber)
drop if voyagenumber>numberofvoyages

rename voy VOYAGEID
replace VOYAGEID="" if VOYAGEID=="?"
