clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

gen nlev = lev - cashr

collapse (count) nobs = cashr ///
 (sum) agg_che = che agg_at = at ///
(mean) mean_cashr = cashr mean_lev = lev mean_nlev = nlev ///
(median) med_cashr = cashr med_lev = lev med_nlev = nlev, ///
by(fyear)

gen agg_cashr = agg_che / agg_at

keep fyear nobs agg_cashr mean_cashr med_cashr mean_lev med_lev mean_nlev med_nlev
order fyear nobs agg_cashr mean_cashr med_cashr mean_lev med_lev mean_nlev med_nlev

qui tostring nobs, force replace format ("%5.0fc")
qui tostring agg_cashr mean_cashr med_cashr mean_lev med_lev mean_nlev med_nlev, force replace format ("%4.3f")

listtab * using "analysis/output/tab/tab1.tex", rstyle(tabular) replace ///
head("\begin{tabular}{l c c c c c c c c}" ///
"\toprule" ///
"Year & \multicolumn{1}{c}{N} & \multicolumn{1}{p{1.5cm}}{\centering Aggregate\\Cash\\Ratio} & \multicolumn{1}{p{1.5cm}}{\centering Average\\Cash\\Ratio} & \multicolumn{1}{p{1.5cm}}{\centering Median\\Cash\\Ratio} & \multicolumn{1}{p{1.5cm}}{\centering Average\\Leverage} & \multicolumn{1}{p{1.5cm}}{\centering Median\\Leverage} & \multicolumn{1}{p{1.5cm}}{\centering Average\\Net\\Leverage} & \multicolumn{1}{p{1.5cm}}{\centering Median\\Net\\Leverage}\\" ///
"\midrule") ///
foot("\bottomrule" "\end{tabular}")
