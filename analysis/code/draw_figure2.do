clear all
set more off
set graphics off

cd "~/Projects/Replication/BKS2009"
use "analysis/temp/prepared", replace

* Calculate increase in cash flow risk
preserve
collapse (mean) ind_cfvol = cfvol, by (sic2 fyear)
keep if fyear == 1980 | fyear == 2006
tsset sic2 fyear
bysort sic2: gen Dind_cfvol = ind_cfvol - ind_cfvol[_n - 1] if sic2 == sic2[_n - 1]
bysort sic2: keep if _n == _N
egen cfvol_group = cut(Dind_cfvol), group(5)
keep sic2 cfvol_group
tempfile cfvol_group
save `cfvol_group'
restore

* Summarize mean cash ratio by group
merge m:1 sic2 using analysis/temp/cfvol_group
collapse (mean) mean_cashr = cashr, by(fyear cfvol_group)

* Draw plot
twoway  ///
(scatter mean_cashr fyear if cfvol_group == 4, con(l)) ///
(scatter mean_cashr fyear if cfvol_group == 3, con(l)) ///
(scatter mean_cashr fyear if cfvol_group == 2, con(l)) ///
(scatter mean_cashr fyear if cfvol_group == 1, con(l)) ///
(scatter mean_cashr fyear if cfvol_group == 0, con(l)), ///
legend(label(1 "Q5: Highest") label(2 "Q4") label(3 "Q3") label(4 "Q2") label(5 "Q1: Lowest") rows(1) pos(12) size(vsmall)) ///
legend(order(5 4 3 2 1)) ///
xtitle("Year") ytitle("cash/assets") ///
yscale(range(0 0.45)) ylabel(0(0.05)0.45) jens
xscale(range(1980 2006)) xlabel(1980(2)2006)

* Save plot
graph export "analysis/output/fig/fig2.pdf", replace
