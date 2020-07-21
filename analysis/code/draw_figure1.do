clear all
set more off
set graphics off

cd "~/Projects/Replication/BKS2009"
use "analysis/temp/prepared", replace

bysort fyear: egen size_rank = rank(lag1_at)
bysort fyear: egen size_n = count(lag1_at)
gen size_pct = (size_rank - 1)/size_n
egen size_group = cut(size_pct), at(0 0.2 0.4 0.6 0.8 1) icodes
collapse (mean) mean_cashr = cashr, by(fyear size_group)

qui twoway  ///
(scatter mean_cashr fyear if size_group == 4, con(l)) ///
(scatter mean_cashr fyear if size_group == 3, con(l)) ///
(scatter mean_cashr fyear if size_group == 2, con(l)) ///
(scatter mean_cashr fyear if size_group == 1, con(l)) ///
(scatter mean_cashr fyear if size_group == 0, con(l)), ///
legend(label(1 "Q5: Largest") label(2 "Q4") label(3 "Q3") label(4 "Q2") label(5 "Q1: Smallest") rows(1) pos(12) size(vsmall)) ///
legend(order(5 4 3 2 1)) ///
xtitle("Year") ytitle("cash/assets") ///
yscale(range(0 0.4)) ylabel(0(0.05)0.4) ///
xscale(range(1980 2006)) xlabel(1980(2)2006)

graph export "analysis/output/fig/fig1.pdf", replace
