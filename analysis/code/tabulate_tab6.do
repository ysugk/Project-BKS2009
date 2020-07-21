clear all
set more off

cd ~/Projects/Replication/BKS2009
use analysis/temp/prepared, replace

gen dum1990 = 0
replace dum1990 = 1 if fyear >= 1990
la var dum1990 "1990s dummy"
gen dum2000 = 0
replace dum2000 = 1 if fyear >= 2000
la var dum2000 "2000s dummy"

g V = mve + dt
g E = ib + xint + txditc
g NA = at - che
g RD = xrd
replace RD = 0 if missing(RD)
g I = xint
g D = dvc
g L = che

tsset gvkey fyear

foreach v in V E NA RD I D L {
	g d_`v' = (`v' - L2.`v') / at
	g d2_`v' = (F2.`v' - `v') / at
	replace `v' = `v' / at
}

reghdfe V E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L c.L##dum1990##dum2000, noabs cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mata
b = st_matrix("b")
V = st_matrix("V")

V = V[selectindex(b :!= 0), selectindex(b :!= 0)]
b = b[1, selectindex(b :!= 0)]

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons
mat rownames V = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons
mat colnames V = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons

ereturn post b V, obs(`nobs')
eststo col1
estadd local r2_ "`r2_'"

preserve
keep if at > 100 & fyear == 2004
keep gvkey
tempfile subsample
save `subsample'
restore

merge m:1 gvkey using `subsample'
keep if _merge == 3

reghdfe V E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L c.L##dum1990##dum2000 if at > 100, noabs cl(gvkey fyear)
local r2_ : di %4.3f e(r2_a)
local nobs = e(N)
mat b = e(b)
mat V = e(V)

mata
b = st_matrix("b")
V = st_matrix("V")

V = V[selectindex(b :!= 0), selectindex(b :!= 0)]
b = b[1, selectindex(b :!= 0)]

st_matrix("b", b)
st_matrix("V", V)
end

mat colnames b = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons
mat rownames V = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons
mat colnames V = E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990 dum1990L dum2000 dum2000L _cons

ereturn post b V, obs(`nobs')
eststo col2
estadd local r2_ "`r2_'"

esttab col1 col2 using "analysis/output/tab/tab6.tex", replace booktabs longtable b(3) p(3) nostar msign("$-$") order(_cons E d_E d2_E d_NA d2_NA RD d_RD d2_RD I d_I d2_I D d_D d2_D d2_V L dum1990L dum2000L dum1990 dum2000) title("OLS Regression Results for the Market Value of the Firm \label{tab:6}") ///
nonotes nomtitles stat(r2_ N, fmt("%10.0fc") label("Adjusted $ R^{2}$" "Obs.")) ///
coeflabels(_cons "Intercept" E "$ E_{t}$" d_E "$ dE_{t}$" d2_E "$ dE_{t+2}$" d_NA "$ dNA_{t}$" ///
d2_NA "$ dNA_{t+2}$" RD "$ RD_{t}$" d_RD "$ dRD_{t}$" d2_RD "$ dRD_{t+2}$" I "$ I_{t}$" ///
d_I "$ dI_{t}$" d2_I "$ dI_{t+2}$" D "$ D_{t}$" d_D "$ dD_{t}$" d2_D "$ dD_{t+2}$" d2_V "$ dV_{t+2}$" L "$ L_{t}$" dum1990 "$ D90s$" dum2000 "$ D00s$" dum1990L "$ L_{t} * D90s$" dum2000L "$ L_{t} * D00s$") ///
prefoot("\\")

infix str l 1-500 using ///
	"analysis/output/tab/tab6.tex", clear
	replace l = subinstr(l,"\_","_",.)  
	// Replace
	outfile using ///
			"analysis/output/tab/tab6.tex", ///
			noquote replace


