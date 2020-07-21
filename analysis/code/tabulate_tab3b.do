clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

* Same winsorizing
replace lev = 1 if lev > 1
replace lev = 0 if lev < 0
winsor2 rd aqc_at cfvol capx_at, c(1 99) replace
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

gen dum1990 = 0
replace dum1990 = 1 if fyear >= 1990
la var dum1990 "1990s dummy"
gen dum2000 = 0
replace dum2000 = 1 if fyear >= 2000
la var dum2000 "2000s dummy"

* Model 1
global control1 = "c.ind_cfvol c.mtb c.size c.ocf c.nwc c.capx_at c.lev c.rd i.div_dum c.aqc_at"

qui reghdfe cashr ($control1 )##i.dum1990##i.dum2000, noabsorb cl(gvkey fyear)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2_a)

mata
b = st_matrix("b")
V = st_matrix("V")
V = V[selectindex(b :!= 0), selectindex(b :!= 0)]
b = b[1, selectindex(b :!= 0)]

b1 = b[1, (33, 1..10)]
V1 = V[(33, 1..10), (33, 1..10)]

b2 = b[1, (11..21)]
V2 = V[(11..21), (11..21)]

b3 = b[1, (22..32)]
V3 = V[(22..32), (22..32)]

st_matrix("b1", b1)
st_matrix("b2", b2)
st_matrix("b3", b3)

st_matrix("V1", V1)
st_matrix("V2", V2)
st_matrix("V3", V3)
end

forvalues i = 1/3 {
	matrix colnames b`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix rownames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix colnames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
}

ereturn post b1 V1
ereturn display
eststo est1
estadd local r2_ "`r2_'"

ereturn post b2 V2
ereturn display
eststo est2

ereturn post b3 V3
ereturn display
eststo est3

* Model 2
gen ipoyear = fyear - year(ipodate2)
tabulate ipoyear if ipoyear >= 1 & ipoyear <= 5, generate(ipo)

foreach v in ipo1 ipo2 ipo3 ipo4 ipo5 {
	replace `v' = 0 if missing(`v')
}

la var nei "Net equity issuance"
la var ndi "Net debt issuance"
la var neg_ni "Loss dummy"
la var tb3 "T-bill"
la var creditspread "Credit spread"
la var ipo1 "IPO1"
la var ipo2 "IPO2"
la var ipo3 "IPO3"
la var ipo4 "IPO4"
la var ipo5 "IPO5"

global control1 = "c.ind_cfvol c.mtb c.size c.ocf c.nwc c.capx_at c.lev c.rd i.div_dum c.aqc_at"
global control2 = "nei ndi neg_ni tb3 creditspread ipo1 ipo2 ipo3 ipo4 ipo5"

qui reghdfe cashr ($control1 )##i.dum1990##i.dum2000 $control2, noabsorb cl(gvkey fyear)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2_a)

mata
b = st_matrix("b")
V = st_matrix("V")
V = V[selectindex(b :!= 0), selectindex(b :!= 0)]
b = b[1, selectindex(b :!= 0)]

b1 = b[1, (43, 1..10, 33..42)]
V1 = V[(43, 1..10, 33..42), (43, 1..10, 33..42)]

b2 = b[1, (11..21)]
V2 = V[(11..21), (11..21)]

b3 = b[1, (22..32)]
V3 = V[(22..32), (22..32)]

st_matrix("b1", b1)
st_matrix("b2", b2)
st_matrix("b3", b3)

st_matrix("V1", V1)
st_matrix("V2", V2)
st_matrix("V3", V3)
end

matrix colnames b1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2
matrix rownames V1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2
matrix colnames V1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2

forvalues i = 2/3 {
	matrix colnames b`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix rownames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix colnames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
}

ereturn post b1 V1
ereturn display
eststo est4
estadd local r2_ "`r2_'"

ereturn post b2 V2
ereturn display
eststo est5

ereturn post b3 V3
ereturn display
eststo est6

* Model 3
gen logcashr = log(che / (at - che))

global control1 = "c.ind_cfvol c.mtb c.size c.ocf c.nwc c.capx_at c.lev c.rd i.div_dum c.aqc_at"
global control2 = "nei ndi neg_ni tb3 creditspread ipo1 ipo2 ipo3 ipo4 ipo5"

qui reghdfe logcashr ($control1 )##i.dum1990##i.dum2000 $control2, noabsorb cl(gvkey fyear)
mat b = e(b)
mat V = e(V)
local r2_ : di %4.3f e(r2_a)

mata
b = st_matrix("b")
V = st_matrix("V")
V = V[selectindex(b :!= 0), selectindex(b :!= 0)]
b = b[1, selectindex(b :!= 0)]

b1 = b[1, (43, 1..10, 33..42)]
V1 = V[(43, 1..10, 33..42), (43, 1..10, 33..42)]

b2 = b[1, (11..21)]
V2 = V[(11..21), (11..21)]

b3 = b[1, (22..32)]
V3 = V[(22..32), (22..32)]

st_matrix("b1", b1)
st_matrix("b2", b2)
st_matrix("b3", b3)

st_matrix("V1", V1)
st_matrix("V2", V2)
st_matrix("V3", V3)
end

matrix colnames b1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2
matrix rownames V1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2
matrix colnames V1 = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at $control2

forvalues i = 2/3 {
	matrix colnames b`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix rownames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
	matrix colnames V`i' = Intercept ind_cfvol mtb size ocf nwc capx_at lev rd div_dum aqc_at
}

ereturn post b1 V1
ereturn display
eststo est7
estadd local r2_ "`r2_'"

ereturn post b2 V2
ereturn display
eststo est8

ereturn post b3 V3
ereturn display
eststo est9

* Tabulate
esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 using "analysis/output/tab/tab3b.tex", replace stats(r2_, label("Adjusted $ R^{2}$")) p nostar nonotes msign("$-$") label booktab longtable nonumbers nomtitles ///
b(3) p(3) ///
posthead("\multicolumn{10}{c}{Panel B} \\" ///
 "\midrule \multicolumn{1}{p{1.5cm}}{Model} & \multicolumn{3}{c}{Cash/Assets} & \multicolumn{3}{c}{Cash/Assets}  & \multicolumn{3}{c}{Log (Cash/Net Assets)} \\" "\cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10}" ///
"\multicolumn{1}{p{1.5cm}}{Dependent Variables} & \multicolumn{1}{p{1.8cm}}{\centering Estimate} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\1990s} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\2000s} & \multicolumn{1}{p{1.8cm}}{\centering Estimate} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\1990s} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\2000s} & \multicolumn{1}{p{1.8cm}}{\centering Estimate} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\1990s} & \multicolumn{1}{p{1.8cm}}{\centering Interaction \\2000s} \\" "\midrule") ///
prefoot("\\")
