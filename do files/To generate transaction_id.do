

***This script is a one-off : it generates transaction_id from the transaction 
***files merged by python

import delimited "/Users/guillaumedaudin/Répertoires Git/slaveprofits data and programs/python_merge/transactions.csv", stringcols(1 6 8) encoding(utf8) clear
sort ventureid line_number
bysort ventureid  : gen new_transaction_id = ventureid + "--T" + string(_n,"%03.0f")
drop transaction_id
rename new_transaction_id transaction_id 
drop line_number
order transaction_id
export delimited "/Users/guillaumedaudin/Répertoires Git/slaveprofits data and programs/data/transactions.csv", replace 


import delimited "/Users/guillaumedaudin/Répertoires Git/slaveprofits data and programs/python_merge/transactions_hypothetical.csv", encoding(utf8) stringcols(1 6 8) clear
sort ventureid line_number
bysort ventureid  : gen new_transaction_id = ventureid + "--H" + string(_n,"%03.0f")
drop transaction_id
rename new_transaction_id transaction_id 
drop line_number
order transaction_id
export delimited "/Users/guillaumedaudin/Répertoires Git/slaveprofits data and programs/data/transactions_hypothetical.csv", replace 

