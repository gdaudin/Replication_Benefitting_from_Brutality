clear all
set more off

program main
    local ssc_packages "estout outreg2 rangestat"

    if !missing("`ssc_packages'") {
        foreach pkg in "`ssc_packages'" {
        * install using ssc, but avoid re-installing if already present
            capture which `pkg'
            if _rc == 111 {                 
               dis "Installing `pkg'"
               quietly ssc install `pkg', replace
               }
        }
    }

    * Install packages using net, but avoid re-installing if already present
    capture which xfill
       if _rc == 111 {
        quietly net from https://www.sealedenvelope.com/
        quietly cap ado uninstall xfill
        quietly net install xfill
       }

end

main