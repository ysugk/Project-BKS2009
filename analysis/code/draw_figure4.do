clear all
set more off
set graphics off

cd "~/Projects/Replication/BKS2009"
use "analysis/temp/prepared", replace

drop if missing(gindex)
bysort fyear: egen gim_rank = rank(gindex)
bysort fyear: egen gim_n = count(gindex)
gen gim_pct = (gim_rank - 1)/gim_n
egen gim_group = cut(gim_pct), at(0 0.2 0.4 0.6 0.8 1) icodes

collapse (mean) mean_cashr = cashr, by(fyear gim_group) 

qui twoway  ///
(scatter mean_cashr fyear if gim_group == 4, con(l)) ///
(scatter mean_cashr fyear if gim_group == 3, con(l)) ///
(scatter mean_cashr fyear if gim_group == 2, con(l)) ///
(scatter mean_cashr fyear if gim_group == 1, con(l)) ///
(scatter mean_cashr fyear if gim_group == 0, con(l)), ///
legend(label(1 "Q5: Highest") label(2 "Q4") label(3 "Q3") label(4 "Q2") label(5 "Q1: Lowest") rows(1) pos(12) size(vsmall)) ///
legend(order(5 4 3 2 1)) ///
xtitle("Year") ytitle("cash/assets") ///
yscale(range(0 0.25)) ylabel(0(0.05)0.25) ///
xscale(range(1990 2006)) xlabel(1990(2)2006)

graph export "analysis/output/fig/fig4.pdf", replace
