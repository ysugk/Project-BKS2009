clear all
set more off
set graphics off

cd "~/Projects/Replication/BKS2009"
use "analysis/temp/prepared", replace

keep if fyear - year(ipodate2) >= 5

gen ipocohort = .
replace ipocohort = 1960 if ipodate2 <= mdy(12, 31, 1969)
replace ipocohort = 1970 if mdy(1, 1, 1970) <= ipodate2 & ipodate2 <= mdy(12, 31, 1974)
replace ipocohort = 1975 if mdy(1, 1, 1975) <= ipodate2 & ipodate2 <= mdy(12, 31, 1979)
replace ipocohort = 1980 if mdy(1, 1, 1980) <= ipodate2 & ipodate2 <= mdy(12, 31, 1984)
replace ipocohort = 1985 if mdy(1, 1, 1985) <= ipodate2 & ipodate2 <= mdy(12, 31, 1989)
replace ipocohort = 1990 if mdy(1, 1, 1990) <= ipodate2 & ipodate2 <= mdy(12, 31, 1994)
replace ipocohort = 1995 if mdy(1, 1, 1995) <= ipodate2 & ipodate2 <= mdy(12, 31, 1999)
replace ipocohort = 2000 if mdy(1, 1, 2000) <= ipodate2 & ipodate2 < .

collapse (count) nobs = cashr (mean) mean_cashr = cashr, by(fyear ipocohort)
drop if missing(ipocohort)

twoway  ///
(scatter mean_cashr fyear if ipocohort == 1960, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1970, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1975, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1980, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1985, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1990, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 1995, con(l)) ///
(scatter mean_cashr fyear if ipocohort == 2000, con(l)), ///
legend(label(1 "1960s") label(2 "1970s") label(3 "1975s") label(4 "1980s") label(5 "1985s") label(6 "1990s") label(7 "1995s") label(8 "2000s") rows(2) pos(12) size(vsmall)) ///
legend(order(1 2 3 4 5 6 7 8)) ///
xtitle("Year") ytitle("cash/assets") ///
yscale(range(0 0.45)) ylabel(0(0.05)0.45) ///
xscale(range(1980 2006)) xlabel(1980(2)2006)

graph export "analysis/output/fig/fig3.pdf", replace
