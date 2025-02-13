
clear

 if lower(c(username)) == "guillaumedaudin" {
	global dir "~/Répertoires GIT/slaveprofits data and programs"
	cd "$dir"
	global output "~/Répertoires GIT/slaveprofits data and programs/output/"
	global tastdb "$dir/external data/"
}

 if lower(c(username)) == "xronkl" {
	global dir "S:\Personal Folders\Forskning - under arbete\Slave trade profits meta-study\GIT\slaveprofits"
	cd "$dir"
	global output "$dir\output\"
	global tastdb "$dir\external data\"
}







///////////////////////////////////////////////////////////////////////////////
////Captains and OUTFITTERs’ career.
/////1. Start with tstd.
//// 2. correct names in STDT
//// 3. Merge with our the information in our extra voyage
/////4. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD

*1. Make VOYAGEID string
* EDIT: This line have been moved to Get TSTD info do-file, as we link info there already.
*tostring(VOYAGEID), replace

use "${tastdb}tastdb-exp-2020.dta", clear

//2. Correct owner’s names TSDT

**We make the assumption the first owner is the outfitter in tsdt
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	//French data
	replace OWNER`letter' = "Chateaubriand" if strmatch(OWNER`letter', "*Chateaubriand*")==1
	replace OWNER`letter' = "Romanet, Adrien" if strmatch(OWNER`letter', "*Romanet*")==1
	replace OWNER`letter' = "Ballan (Aîné)" if strmatch(OWNER`letter',"*Ballan*né*")==1
	replace OWNER`letter' = "Bouteiller Père et Fils" if strmatch(OWNER`letter',"*Bouteiller*")==1
	replace OWNER`letter' = "Chaurand" if strmatch(OWNER`letter',"*Chaurand*")==1
	replace OWNER`letter' = "Darreche (Frères)" if strmatch(OWNER`letter',"*Darreche*")==1
	replace OWNER`letter' = "De Guer" if strmatch(OWNER`letter',"*Deguer*")==1
	replace OWNER`letter' = "Desclos Le Perley freres" if strmatch(OWNER`letter',"*Desclos*")==1
	replace OWNER`letter' = "Geslin" if strmatch(OWNER`letter',"*Geslin*")==1
	replace OWNER`letter' = "Jogues" if strmatch(OWNER`letter',"*Jogues*")==1
	replace OWNER`letter' = "Langevin" if strmatch(OWNER`letter',"*Langevin*")==1
	replace OWNER`letter' = "Arnou" if strmatch(OWNER`letter',"*Arnou*(*)*")==1
	replace OWNER`letter' = "Bertrand, Nicolas" if strmatch(OWNER`letter',"*Bertrand, Nicolas*")==1
	replace OWNER`letter' = "Castaing, François" if strmatch(OWNER`letter',"*Castaing*")==1 & strmatch(OWNER`letter',"*Castaing, Abel*")!=1

	//Dutch data
	replace OWNER`letter' = "Zitter, Jan de" if OWNER`letter' =="Zitter, Jan, de"
	replace OWNER`letter' = "Middelburgse Commercie Compagnie" if OWNER`letter' == "Middelburgsche Commercie Compagnie"

	//English data
	replace OWNER`letter' = "Tuohy, David" if strmatch(OWNER`letter',"*Tuohy*")==1
	replace OWNER`letter' = "Rogers, James" if strmatch(OWNER`letter',"*Rogers*,*James*")==1
	replace OWNER`letter' = "Lumley, Thomas" if strmatch(OWNER`letter',"*Lumley*")==1
	replace OWNER`letter' = "Davenport, William" if strmatch(OWNER`letter',"*Davenport, Wm*")==1

	//Dutch data
	replace OWNER`letter' = "Bargum Trading Society" if strmatch(OWNER`letter',"*Bargum Trading Society*")==1
}


////// Correct captain’s names TSDT
foreach letter in A B C {
	replace CAPTAIN`letter' = "Devigne, Et" if strmatch(CAPTAIN`letter', "*Devigne, E*")==1
	replace CAPTAIN`letter' = "Barkley, John" if strmatch(CAPTAIN`letter', "*Barkley,J*")==1
	replace CAPTAIN`letter' = "Berthomme, Nicolas" if strmatch(CAPTAIN`letter', "*Berthommé, Nicholas*")==1
	replace CAPTAIN`letter' = "Bodin Desplantes" if strmatch(CAPTAIN`letter', "*Bodin Desplantes*")==1
	replace CAPTAIN`letter' = "Brancker, Peter" if strmatch(CAPTAIN`letter', "*Brancker, P*")==1
	replace CAPTAIN`letter' = "Brettargh, William" if strmatch(CAPTAIN`letter', "*Brettargh, William*")==1
	replace CAPTAIN`letter' = "Callow, C" if strmatch(CAPTAIN`letter', "*Callow*")==1
	replace CAPTAIN`letter' = "Carus, Chris" if strmatch(CAPTAIN`letter', "*Carus, Chr*")==1
	replace CAPTAIN`letter' = "Chateaubriand du Plessis, Pierre-Anne-Marie" if strmatch(CAPTAIN`letter', "*Chateaubriand*")==1
	replace CAPTAIN`letter' = "Clark, William" if strmatch(CAPTAIN`letter', "*Clark, W*")==1
	replace CAPTAIN`letter' = "Clémenceau, Alexandre" if strmatch(CAPTAIN`letter', "*Cl*menceau, Al*")==1
	replace CAPTAIN`letter' = "Durocher-Sorin" if strmatch(CAPTAIN`letter', "Durocher")==1 // there are homonymes, but not around the same time//
	replace CAPTAIN`letter' = "Fowler, John" if strmatch(CAPTAIN`letter', "*Fowler, John*")==1
	replace CAPTAIN`letter' = "Guyot, Jean" if strmatch(CAPTAIN`letter', "Guyot, J")==1
	replace CAPTAIN`letter' = "La Causse, Bernard" if strmatch(CAPTAIN`letter', "*La Causse*")==1
	replace CAPTAIN`letter' = "Lawson, William" if strmatch(CAPTAIN`letter', "*Lawson, W*m*")==1
	replace CAPTAIN`letter' = "Le Sourd, J-Fr" if strmatch(CAPTAIN`letter', "*Le Sourd, J-F*")==1
	replace CAPTAIN`letter' = "Mary, Joseph" if strmatch(CAPTAIN`letter', "*Mary, Jos*")==1
	replace CAPTAIN`letter' = "Nicholson, Joseph" if strmatch(CAPTAIN`letter', "*Nicholson, Jos*")==1
	replace CAPTAIN`letter' = "Pacaud, Pierre" if strmatch(CAPTAIN`letter', "*Pacaud, P*")==1
	replace CAPTAIN`letter' = "Ringeard, Mathurin" if strmatch(CAPTAIN`letter', "*Ringeard*")==1
	replace CAPTAIN`letter' = "Smale, John" if strmatch(CAPTAIN`letter', "*Smale, Jno*")==1
	replace CAPTAIN`letter' = "Smith, John" if strmatch(CAPTAIN`letter', "*Smith, Jn*")==1
	replace CAPTAIN`letter' = "Stangeways, James" if strmatch(CAPTAIN`letter', "*Stangeways, Jas*")==1
	replace CAPTAIN`letter' = "Tanquerel, Julien-Edouard" if strmatch(CAPTAIN`letter', "*Tanquerel, J-E*")==1
	replace CAPTAIN`letter' = "Van Alstein, Pierre-Ignace-Lievin" if strmatch(CAPTAIN`letter', "*Alstein*Pierre*")==1
	replace CAPTAIN`letter' = "Vigneron, François" if strmatch(CAPTAIN`letter', "*Vigneron*")==1
	replace CAPTAIN`letter' = "Wotherspoon, Alex" if strmatch(CAPTAIN`letter', "*Wotherspoon, Alexander*")==1
}


save "${tastdb}tastdb-exp-2020_corr.dta", replace


//////3. merge with Venture all to get an extra 47 ventures + multiple voyages
***I assume the multiple voyages cannot help us
use "${output}Venture all+multiple.dta", clear
//To get an unique key
replace VOYAGEID = ventureid if voyageidintstd==""  |  voyageidintstd=="."
//This is only useful if we know the name of the captain or the outfitter
drop if nameofthecaptain=="" & nameofoutfitter==""
duplicates drop nameofthecaptain nameofoutfitter VOYAGEID, force
merge 1:1 VOYAGEID  using "${tastdb}tastdb-exp-2020_corr.dta"
drop _merge

****We transfer some data from "multiple voyages" into the STDT variables
replace VYMRTRAT=VYMRTRATrev if numberofvoyages>=2
replace MAJBYIMP=MAJBYIMPrev if numberofvoyages>=2
replace MJSELIMP=MJSELIMPrev if numberofvoyages>=2
replace SLAXIMP=SLAXIMPrev if numberofvoyages>=2
replace SLAMIMP=SLAMIMPrev if numberofvoyages>=2
replace CAPTAINA=CAPTAINArev if numberofvoyages>=2
replace OWNERA=OWNERArev if numberofvoyages>=2

drop *rev





//Here, we assume our data on outfitter is correct
replace OWNERA= nameofoutfitter if nameofoutfitter!=""
//Here, we assume stdt on captain is correct
replace CAPTAINA= nameofthecaptain if missing(CAPTAINA)
replace YEARAF = YEARAF_own if missing(YEARAF)
/*drop if strmatch(voyageidintstd,"*/*")==1
**I would like to avoid that line. Issues with DR051, KR014 (and probably not KR016) */
drop if YEARAF==.

decode MAJBYIMP, gen(MAJBYIMP_str)
gen MAJMAJBYIMP = "West" if MAJBYIMP_str==" Senegambia and offshore Atlantic" | MAJBYIMP_str==" Sierra Leone" | MAJBYIMP_str==" Windward Coast"
replace MAJMAJBYIMP = "Bight of Guinea" if MAJBYIMP_str==" Gold Coast" | MAJBYIMP_str==" Bight of Benin" | MAJBYIMP_str==" Bight of Biafra and Gulf of Guinea islands"
replace MAJMAJBYIMP = "South" if MAJBYIMP_str==" West Central Africa and St. Helena" | MAJBYIMP_str==" Southeast Africa and Indian Ocean islands "
label var MAJMAJBYIMP "African region of trade"



save "tastdb-exp-2020+own.dta", replace

// * 4. PREPARE OUTFITTERS’ AND CAPTAINS’ TRACK RECORD

use "tastdb-exp-2020+own.dta", clear
keep CAPTAINA CAPTAINB CAPTAINC YEARAF VOYAGEID MAJMAJBYIMP

capture erase "${output}Captain.dta"
 
foreach captainletter in A B C {
	drop if CAPTAIN`captainletter' == ""
	preserve
	keep CAPTAIN`captainletter' YEARAF VOYAGEID MAJMAJBYIMP
	rename CAPTAIN`captainletter' CAPTAIN
	capture append using "${output}Captain.dta"
	duplicates report CAPTAIN VOYAGEID
	save "${output}Captain.dta", replace
	restore
}
//THERE IS AN ISSUE IN TSDT DATAT
use "${output}Captain.dta", clear
duplicates drop CAPTAIN VOYAGEID, force
save "${output}Captain.dta", replace
 
save "${output}Captain.dta", replace

use "tastdb-exp-2020+own.dta", clear

 keep OWNERA /*OWNERB OWNERC OWNERD /*
 */ OWNERE OWNERF OWNERG OWNERH OWNERI OWNERJ OWNERK OWNERL OWNERM OWNERN /* 
 */ OWNERO OWNERP*/ YEARAF VOYAGEID MAJMAJBYIMP

  
capture erase "${output}OUTFITTER.dta"
 
foreach letter in A /*B C D E F G H I J K L M O P*/ {
	drop if OWNER`letter' == ""
	preserve
	keep OWNER`letter' YEARAF VOYAGEID MAJMAJBYIMP
	rename OWNER`letter' OUTFITTER
	capture append using "${output}OUTFITTER.dta"
	save "${output}OUTFITTER.dta", replace
	restore
}

use "${output}OUTFITTER.dta", clear

//This command insures that when multiple members of the same family are listed as OUTFITTERs, they are not counted twice
bys OUTFITTER VOYAGEID YEARAF: keep if _n==1

save "${output}OUTFITTER.dta", replace

**COMPUTE EXPERIENCE TAKING INTO ACCOUNT HOMONYMES

use "${output}Captain.dta", clear
sort CAPTAIN YEARAF

sort CAPTAIN YEARAF 

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if CAPTAIN==CAPTAIN[_n-1] & homonyme[_n-1] ==`nbr'
}


sort CAPTAIN homonyme YEARAF 
bys CAPTAIN homonyme: generate captain_total_career = _N
bys CAPTAIN homonyme: generate captain_experience= _n-1

sort CAPTAIN homonyme  MAJMAJBYIMP YEARAF
bys CAPTAIN homonyme MAJMAJBYIMP : generate captain_regional_experience= _n-1 if MAJMAJBYIMP!=""

*For multiple voyages in a year (we take the max experience)
*First line workes if all the voyages in a specific year are to the same region
collapse (min) captain_experience captain_total_career captain_regional_experience (count) nbr_in_year=captain_experience, by(CAPTAIN YEARAF homonyme MAJMAJBYIMP)
egen temp_captain_experience = min(captain_experience), by(CAPTAIN YEARAF homonyme)
replace captain_experience=temp_captain_experience if captain_experience!=temp_captain_experience
drop temp_captain_experience
save "${output}Captain.dta", replace


//Idem for OUTFITTERs


use "${output}OUTFITTER.dta", clear
drop if OUTFITTER=="" | YEARAF==.
sort OUTFITTER YEARAF

sort OUTFITTER YEARAF

gen homonyme=0
foreach nbr of num 1(1)6 {
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'-1 & YEARAF-YEARAF[_n-1] >=20
replace homonyme = `nbr' if OUTFITTER==OUTFITTER[_n-1] & homonyme[_n-1] ==`nbr'
}


sort OUTFITTER homonyme OUTFITTER 
bys OUTFITTER homonyme: generate OUTFITTER_total_career = _N
bys OUTFITTER homonyme: generate OUTFITTER_experience= _n-1

sort OUTFITTER homonyme MAJMAJBYIMP YEARAF 
bys OUTFITTER homonyme MAJMAJBYIMP: generate OUTFITTER_regional_experience= _n-1 if MAJMAJBYIMP!=""


*First line workes if all the voyages in a specific year are to the same region
collapse (min) OUTFITTER_experience OUTFITTER_total_career OUTFITTER_regional_experience (count) nbr_in_year=OUTFITTER_experience, by(OUTFITTER YEARAF homonyme MAJMAJBYIMP)
egen temp_OUTFITTER_experience = min(OUTFITTER_experience), by(OUTFITTER YEARAF homonyme)
replace OUTFITTER_experience=temp_OUTFITTER_experience if OUTFITTER_experience!=temp_OUTFITTER_experience
drop temp_OUTFITTER_experience

save "${output}OUTFITTER.dta", replace