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




use "${output}Venture all.dta", clear

***I check whether I indeed have one voyageidintstd for each voyage
gen test = 1+regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*/.*/.*")+regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*/.*") ///
+ regexm(voyageidintstd,".*/.*/.*/.*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*/.*/.*") ///
+ regexm(voyageidintstd,".*/.*/.*/.*") + regexm(voyageidintstd,".*/.*/.*") + regexm(voyageidintstd,".*/.*")

assert (numberofvoyages == test | ventureid=="KR016")
/*KR016 is grouping of 15 Danish voyages included in table 8 in Lauring*/
drop test