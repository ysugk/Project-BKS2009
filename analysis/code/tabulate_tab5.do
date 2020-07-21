clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

* Same winsorizing
replace lev = 1 if lev > 1
replace lev = 0 if lev < 0
winsor2 rd aqc_at capx_at, c(1 99) replace
winsor2 nwc ocf, c(1 100) replace
winsor2 mtb, c(0 99) replace

winsor2 cfvol, c(1 99) replace

* Generate industry sigma
preserve
collapse (mean) ind_cfvol = cfvol, by(fyear sic2)
la var ind_cfvol "Industry sigma"
tempfile ind_cfvol
save `ind_cfvol'
restore

merge m:1 fyear sic2 using `ind_cfvol'

gen treat = .
replace treat = 0 if fyear >= 1980 & fyear <= 1989
replace treat = 1 if fyear >= 2000 & fyear <= 2006

drop if missing(treat)

* Calculate predicted cash ratio
gen pcashr = 0.307 + 0.230 * ind_cfvol + 0.006 * mtb - 0.009 * size + 0.077 * ocf - 0.238 * nwc - 0.372 * capx_at - 0.360 * lev + 0.048 * rd - 0.024 * div_dum - 0.233 * aqc_at + 0.158 * nei + 0.190 * ndi

mat scaler = (0.230, 0.006, -0.009, 0.077, -0.238, -0.372, -0.360, 0.048, -0.024, -0.233, 0.158, 0.190)

* Whole sample
foreach v in ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	qui ttest `v', by(treat)
	matrix mat_`v' = (r(mu_2) - r(mu_1), r(se))
}

mat temp = mat_ind_cfvol

foreach v in mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	mat temp = temp \ mat_`v'
}

forvalue i = 1/12 {
	mat temp[`i', 1] = temp[`i', 1] * scaler[1, `i']
	mat temp[`i', 2] = (temp[`i', 2] * scaler[1, `i'])^2
}

mata
temp = st_matrix("temp")
b = temp[1..12, 1]'
V = diag(temp[1..12, 2])

st_matrix("b", b)
st_matrix("V", V)
end

mat coln b = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
mat rown V = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
mat coln V = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi

ereturn post b V
eststo whole

* Non-dividend

foreach v in ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	qui ttest `v' if div_dum == 0, by(treat)
	matrix mat_`v' = (r(mu_2) - r(mu_1), r(se))
}

mat temp1 = mat_ind_cfvol

foreach v in mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	mat temp1 = temp1 \ mat_`v'
}

forvalue i = 1/12 {
	mat temp1[`i', 1] = temp1[`i', 1] * scaler[1, `i']
	mat temp1[`i', 2] = (temp1[`i', 2] * scaler[1, `i'])^2
}

* Dividend

foreach v in ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	qui ttest `v' if div_dum == 1, by(treat)
	matrix mat_`v' = (r(mu_2) - r(mu_1), r(se))
}

mat temp2 = mat_ind_cfvol

foreach v in mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	mat temp2 = temp2 \ mat_`v'
}

forvalue i = 1/12 {
	mat temp2[`i', 1] = temp2[`i', 1] * scaler[1, `i']
	mat temp2[`i', 2] = (temp2[`i', 2] * scaler[1, `i'])^2
}

mata
temp1 = st_matrix("temp1")
temp2 = st_matrix("temp2")

b1 = temp1[1..12, 1]'
V1 = diag(temp1[1..12, 2])

b2 = temp2[1..12, 1]'
V2 = diag(temp2[1..12, 2])

b3 = b1 - b2

st_matrix("b1", b1)
st_matrix("V1", V1)

st_matrix("b2", b2)
st_matrix("V2", V2)

st_matrix("b3", b3)
end

forvalue i = 1/2 {
	mat coln b`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
	mat rown V`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
	mat coln V`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
}

mat coln b3 = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi

ereturn post b1 V1
eststo nondiv

ereturn post b2 V2
eststo div

ereturn post b3
eststo divdiff

* Non-S&P 500

foreach v in ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	qui ttest `v' if sp500 == 0, by(treat)
	matrix mat_`v' = (r(mu_2) - r(mu_1), r(se))
}

mat temp1 = mat_ind_cfvol

foreach v in mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	mat temp1 = temp1 \ mat_`v'
}

forvalue i = 1/12 {
	mat temp1[`i', 1] = temp1[`i', 1] * scaler[1, `i']
	mat temp1[`i', 2] = (temp1[`i', 2] * scaler[1, `i'])^2
}

* S&P 500

foreach v in ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	qui ttest `v' if sp500 == 1, by(treat)
	matrix mat_`v' = (r(mu_2) - r(mu_1), r(se))
}

mat temp2 = mat_ind_cfvol

foreach v in mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi {
	mat temp2 = temp2 \ mat_`v'
}

forvalue i = 1/12 {
	mat temp2[`i', 1] = temp2[`i', 1] * scaler[1, `i']
	mat temp2[`i', 2] = (temp2[`i', 2] * scaler[1, `i'])^2
}

mata
temp1 = st_matrix("temp1")
temp2 = st_matrix("temp2")

b1 = temp1[1..12, 1]'
V1 = diag(temp1[1..12, 2])

b2 = temp2[1..12, 1]'
V2 = diag(temp2[1..12, 2])

b3 = b1 - b2

st_matrix("b1", b1)
st_matrix("V1", V1)

st_matrix("b2", b2)
st_matrix("V2", V2)

st_matrix("b3", b3)
end

forvalue i = 1/2 {
	mat coln b`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
	mat rown V`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
	mat coln V`i' = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi
}

mat coln b3 = ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at nei ndi

ereturn post b1 V1
eststo nonsp

ereturn post b2 V2
eststo sp

ereturn post b3
eststo spdiff

* Tabulate

esttab whole nondiv div divdiff nonsp sp spdiff using "analysis/output/tab/tab5.tex", replace booktabs nomtitles nonumbers msign("$-$") nostar nonotes noobs b(3) se(4) label ////
mgroups("Whole Sample" "Nondividend Paying Firms" "Dividend Paying Firms" "Difference" "Non-S\&P 500 Firms" "S\&P 500 Firms" "Difference", ///
pattern(1 1 1 1 1 1 1) ///
prefix("\multicolumn{@span}{p{2cm}}{\centering ") suffix("}"))
