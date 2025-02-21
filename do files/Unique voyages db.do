clear


*Requires xfill to be installed
*See net from http://www.sealedenvelope.com/
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
keep ventureid voyageidintstd nameofoutfitter nameofthecaptain YEARAF_own /*
    */ numberofvoyages internalcrossref completedataonoutlays completedataonreturns numberofvoyages /*
    */ nationality datedepartureportofoutfitt_str

/*
foreach var of varlist voyageidintstd nameofthecaptain nameofoutfitter {
    replace `var'=subinstr(`var',"/"," / ",.)
    replace `var'=subinstr(`var',"  "," ",.)
    replace `var'=subinstr(`var',"//","/ /",.)
}
*/

split voyageidintstd , generate(voy) parse("/")
split nameofthecaptain , generate(cap) parse("/")
split nameofoutfitter , generate(out) parse("/")
split datedepartureportofoutfitt_str,generate(date) parse ("/")



forvalue i = 1/15 {
    capture replace voy`i' = strtrim(voy`i')
    capture replace cap`i' = strtrim(cap`i')
    capture replace out`i' = strtrim(out`i')

}

/*
    gen voy`i' =word(voyageidintstd,2*`i'-1)
    gen cap`i' =word(nameofthecaptain,2*`i'-1)
    gen out`i' =word(nameofoutfitter,2*`i'-1)
}
/*
gen voy2=word(voyageidintstd,3)
gen voy3=word(voyageidintstd,5)
gen voy4=word(voyageidintstd,7)
gen voy5=word(voyageidintstd,9)
gen voy6=word(voyageidintstd,11)
gen voy7=word(voyageidintstd,13)
*/
*/

reshape long voy cap out date, i(ventureid) j(voyagenumber)
drop if voyagenumber>numberofvoyages

rename voy VOYAGEID
gen year_dep = substr(date,1,4)
destring(year_dep), replace
replace VOYAGEID="" if strmatch(VOYAGEID," ?")==1
replace VOYAGEID="" if strmatch(VOYAGEID,"?")==1

*br if (VOYAGEID==""& internalcrossref!="")

/*Testing if there are left potentially duplicate voyages difficult to identify*/
/*This is the only case where it might happen*/
drop if ventureid=="KR016" & voyagenumber==14
assert (VOYAGEID!="" | ventureid=="KR014") if internalcrossref!=""
/*Following this, all duplicate voyages have a VoyageID (even if some non-duplicates ones do not)*/

replace VOYAGEID = "RDKRR"+ventureid if VOYAGEID==""
assert (internalcrossref=="" | ventureid=="KR014") if strmatch(VOYAGEID,"RDKRR*")==1

**We will only keep one observation VOYAGEID. But we need to make sure we have the best data on it
*from the other cross-references.

/*
duplicates tag VOYAGEID, generate(duplicate)
br if duplicate==2
*/

encode VOYAGEID, generate(voyageid_num)
xfill cap,i(voyageid_num)
xfill out,i(voyageid_num)
xfill YEARAF_own, i(voyageid_num)
br
replace YEARAF_own = year_dep+1 if  year_dep !=.

***Drop duplicates.
gen sample=0
replace sample=1 if completedataonoutlays!="no" & completedataonreturns!="no"
replace sample=2 if completedataonoutlays=="yes" & completedataonreturns!="yes"
bys VOYAGEID (sample): drop if _N != _n
tab sample

**Arrange variables
replace nameofthecaptain=cap
drop cap
replace nameofoutfitter=out
drop out

drop voyageidintstd completedataonoutlays completedataonreturns voyageid_num date year_dep

*Check that we have the years for "our" voyages in the sample

*br if YEARAF_own==. & sample !=0 & strmatch(VOYAGEID,"RDKRR*")==1
assert YEARAF_own!=. if (sample !=0 & strmatch(VOYAGEID,"RDKRR*"))==1


save "${output}voyages.dta", replace