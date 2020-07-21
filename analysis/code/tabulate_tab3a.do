clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

tsset gvkey fyear

* Same winsorizing
replace lev = 1 if lev > 1
replace lev = 0 if lev < 0

winsor2 rd aqc_at capx_at, c(1 99) replace
winsor2 nwc ocf, c(1 100) replace
winsor2 mtb, c(0 99) replace

winsor2 cfvol, c(1 99) replace

* Generate industry sigma
preserve
collapse (mean) ind_cfvol = cfvol, by(sic2 fyear)
la var ind_cfvol "Industry sigma"
tempfile ind_cfvol
save `ind_cfvol'
restore

merge m:1 fyear sic2 using `ind_cfvol'

global control = "ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at"

* Column 1
qui reghdfe cashr $control, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col1
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 2
gen log_cashr = log(che/(at - che))
la var log_cashr "log cash over net assets"

qui reghdfe log_cashr $control, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col2
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 3
tsset gvkey fyear

gen lag_cash = L.cashr
la var lag_cash "Lag cash"
gen dcashr = D.cashr
gen lag_dcashr = L.dcashr
la var lag_dcashr "Lag dcash"

qui reghdfe dcashr lag_dcashr lag_cash $control, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col3
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 4
gen dum1990 = 0
replace dum1990 = 1 if inrange(fyear, 1990, 1999)
la var dum1990 "1990s dummy"
gen dum2000 = 0
replace dum2000 = 1 if fyear >= 2000
la var dum2000 "2000s dummy"

qui reghdfe cashr $control dum1990 dum2000, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col4
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 5
qui reghdfe log_cashr $control dum1990 dum2000, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col5
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 6
qui reghdfe dcashr lag_dcashr lag_cash $control dum1990 dum2000, noabsorb cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
eststo col6
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 7
qui xtfmb cashr $control if dum1990 == 0 & dum2000 == 0, lag(2)
local r2_ : di %4.3f e(r2)
eststo col7
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 8
qui xtfmb cashr $control if dum1990 == 1 | dum2000 == 1, lag(2)
local r2_ : di %4.3f e(r2)
eststo col8
estadd local r2_ "`r2_'"
estadd local yearfixed ""

* Column 9
qui reghdfe cashr $control if fyear - year(ipodate2) > 5, a(fyear) cl(gvkey fyear) nocon
local r2_ : di %4.3f e(r2_a)
eststo col9
estadd local r2_ "`r2_'"
estadd local yearfixed "Yes"

* Tabulate
esttab using "analysis/output/tab/tab3a.tex", replace p nostar order(_cons lag_dcashr lag_cash) label booktabs longtable b(3) p(3) nonotes constant msign("$-$") nomtitles nonumbers title("Regressions Estimating the Determinants of Cash Holdings \label{tab:3}") ///
posthead("\multicolumn{10}{c}{Panel A} \\" ///
"\midrule Model & OLS & OLS & Changes & OLS & OLS & Changes & F-M (1980s) & F-M (1990s) & FE \\" ///
"\midrule" "\multicolumn{1}{p{1.5cm}}{\centering Dependent Variables} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Log(Cash/ \\Net Assets)} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Log(Cash/ \\Net Assets)} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} & \multicolumn{1}{p{1.8cm}}{\centering Cash/Assets} \\" "\midrule") ///
prefoot("\\") ///
stats(yearfixed r2_ N, fmt("%10.0fc") labels("Year dummies" "Adjusted $ R^2$" "Obs."))
