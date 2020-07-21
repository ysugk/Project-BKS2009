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

* Calculate predicted cash ratio
gen pcashr = 0.307 + 0.230 * ind_cfvol + 0.006 * mtb - 0.009 * size + 0.077 * ocf - 0.238 * nwc - 0.372 * capx_at - 0.360 * lev + 0.048 * rd - 0.024 * div_dum - 0.233 * aqc_at + 0.158 * nei + 0.190 * ndi

* Whole sample
foreach year of num 1990/2006 {
	qui ttest cashr == pcashr if fyear == `year'
	matrix temp`year' = (r(mu_2), r(mu_1) - r(mu_2), r(t))
	matrix rownames temp`year' = `year'
}

mat temp = temp1990

foreach year of num 1991/2006 {
	mat temp = temp \ temp`year'
}

mat coln temp = pred diff t

ereturn post
estadd matrix A = temp'
eststo whole

* S&P 500 Firms
foreach year of num 1990/2006 {
	qui ttest cashr == pcashr if fyear == `year' & sp500 == 1
	matrix temp`year' = (r(mu_2), r(mu_1) - r(mu_2), r(t))
	matrix rownames temp`year' = `year'
}

mat temp = temp1990

foreach year of num 1991/2006 {
	mat temp = temp \ temp`year'
}

mat coln temp = pred diff t

ereturn post
estadd matrix A = temp'
eststo sp

* Dividend
foreach year of num 1990/2006 {
	qui ttest cashr == pcashr if fyear == `year' & div_dum == 1
	matrix temp`year' = (r(mu_2), r(mu_1) - r(mu_2), r(t))
	matrix rownames temp`year' = `year'
}

mat temp = temp1990

foreach year of num 1991/2006 {
	mat temp = temp \ temp`year'
}

mat coln temp = pred diff t

ereturn post
estadd matrix A = temp'
eststo div

* Non-dividend
foreach year of num 1990/2006 {
	qui ttest cashr == pcashr if fyear == `year' & div_dum == 0
	matrix temp`year' = (r(mu_2), r(mu_1) - r(mu_2), r(t))
	matrix rownames temp`year' = `year'
}

mat temp = temp1990

foreach year of num 1991/2006 {
	mat temp = temp \ temp`year'
}

mat coln temp = pred diff t

ereturn post
estadd matrix A = temp'
eststo nodiv

esttab whole sp div nodiv using "analysis/output/tab/tab4.tex", replace booktabs cell((A["pred"](fmt(%4.3f)) A["diff"](fmt(%4.3f)) A["t"](fmt(%3.2f)))) noobs nomtitles msign("$-$") ///
mgroups("Whole Sample" "S\&P 500 Firms" "Firms Paying a Dividend" "Firms Not Paying a Dividend", pattern(1 1 1 1) ///
prefix(\multicolumn{@span}{c}{) suffix(}) ///
span erepeat("\cmidrule(lr){@span}")) ///
collabels("Predicted" "Actual $-$ \\ Predicted" "\textit{t}-statistic", ///
prefix("\multicolumn{@span}{p{1.5cm}}{\centering ") suffix("}")) ///
nonumbers
