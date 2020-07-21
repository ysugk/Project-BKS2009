clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

preserve
collapse (mean) byni_cashr = cashr, by(fyear neg_ni)
drop if missing(neg_ni)
reshape wide byni_cashr, i(fyear) j(neg_ni)
tempfile byni
save `byni'
restore

preserve
collapse (mean) bydiv_cashr = cashr, by(fyear div_dum)
drop if missing(div_dum)
reshape wide bydiv_cashr, i(fyear) j(div_dum)
tempfile bydiv
save `bydiv'
restore

gen ipo_dum = .
replace ipo_dum = 1 if cyear - year(ipodate2) >= 0 & cyear - year(ipodate2) <= 5
replace ipo_dum = 0 if cyear - year(ipodate2) > 5
collapse (mean) byipo_cashr = cashr, by(fyear ipo_dum)
drop if missing(ipo_dum)
reshape wide byipo_cashr, i(fyear) j(ipo_dum)
merge 1:1 fyear using `bydiv'
drop _merge
merge 1:1 fyear using `byni'
drop _merge

order fyear byipo_cashr1 byipo_cashr0 bydiv_cashr1 bydiv_cashr0 byni_cashr1 byni_cashr0

qui tostring byipo_cashr1 byipo_cashr0 bydiv_cashr0 bydiv_cashr1 byni_cashr0 byni_cashr1, force replace format ("%4.3f")

listtab * using "analysis/output/tab/tab2.tex", rstyle(tabular) replace ///
head("\begin{tabular}{l c c c c c c}" ///
"\toprule" ///
"& \multicolumn{2}{c}{New Issues} & \multicolumn{2}{c}{Dividend Status} & \multicolumn{2}{c}{Accounting Performance} \\" ///
"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}" ///
"Year & \multicolumn{1}{p{2cm}}{\centering IPO Firms} & \multicolumn{1}{p{2cm}}{\centering Non-IPO Firms} & \multicolumn{1}{p{2cm}}{\centering Dividend Payer} & \multicolumn{1}{p{2cm}}{\centering Nondividend Payer} & \multicolumn{1}{p{2cm}}{\centering Negative Net Income} & \multicolumn{1}{p{2cm}}{\centering Nonnegative Net Income}\\" ///
"\midrule") ///
foot("\bottomrule" "\end{tabular}")
