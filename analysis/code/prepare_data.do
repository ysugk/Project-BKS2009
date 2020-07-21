clear all
set more off

cd "~/Projects/Replication/BKS2009"

* Use raw data
use build/output/data
save analysis/input/data, replace

destring gvkey, replace
destring sic, replace

replace sic = sich if sich < .

duplicates drop gvkey fyear, force
tsset gvkey fyear

* Generate industry codes
gen sic2 = int(sic/100)
gen sic1 = .
replace sic1 = 1 if sic2>=1 & sic2<=9
replace sic1 = 2 if sic2>=10 & sic2<=14
replace sic1 = 3 if sic2>=15 & sic2<=17
replace sic1 = 4 if sic2>=20 & sic2<=39
replace sic1 = 5 if sic2>=40 & sic2<=49
replace sic1 = 6 if sic2>=50 & sic2<=51
replace sic1 = 7 if sic2>=52 & sic2<=59
replace sic1 = 8 if sic2>=70 & sic2<=89

* Basic filter
keep if at > 0
keep if sale > 0
keep if fic == "USA"

* Define variables
gen lag1_at = L.at
la var lag1_at "lag 1 total assets"
gen dt = dlc + dltt
la var dt "toal debt"
gen lev = dt/at
la var lev "Leverage"
gen cashr = che/at
la var cashr "cash ratio"
gen div_dum = .
replace div_dum = 1 if dvc > 0
replace div_dum = 0 if dvc == 0
la var div_dum "Dividend dummy"
gen neg_ni = ni < 0
la var neg_ni "negative net income"
gen mve = prcc_f * cshpri
la var mve "market value of equity"
gen mtb = (at - ceq + mve)/at
la var mtb "Market to book"
gen size = log(at / (gdpdeflator/100))
la var size "Real size"
gen ocf = (oibdp - xint - txt - dvc)/at
la var ocf "Cash flow/ assets"
gen nwc = (wcap - che)/at
la var nwc "NWC/ assets"
gen capx_at = capx/at
la var capx_at "Capex"
replace xrd = 0 if missing(xrd)
gen rd = xrd/sale
la var rd "R\&D/ sales"
gen aqc_at = aqc/at
la var aqc_at "Acquisition activity"
gen ndi = (dltis - dltr)/at
la var ndi "Net debt issuance"
gen nei = (sstk - prstkc)/at
la var nei "Net equity issuance"
gen ipodate2 = FR_ipodate
replace ipodate2 = begdat if missing(ipodate2)
la var ipodate2 "ipo date"
gen fromipo = datadate - ipodate2
la var fromipo "days from ipo"
gen cyear = year(datadate)
la var cyear "calender year"

* Generate cash flow volatility
tsset gvkey fyear
tsegen cfvol = rowsd(L(1/10).ocf, 3)
la var cfvol "cash flow volatility"

* Fill missing GIM index
replace gindex = gindex[_n - 1] if missing(gindex) & (gvkey == gvkey[_n - 1])
la var gindex "GIM index"

* Apply same filter
keep if fyear >= 1980 & fyear <= 2006

* Drop financial firms
drop if sic >= 6000 & sic <= 6999
* Drop utilities
drop if sic >= 4900 & sic <= 4999

* Tidy data
keep gvkey cyear fyear datadate ipodate2 at lag1_at dt lev che cashr div_dum neg_ni mve mtb size ocf nwc capx_at rd aqc_at cfvol gindex ndi nei sp500 sic2 fromipo tb3 creditspread ib xint txditc xrd dvc

* Save data
save analysis/temp/prepared, replace
