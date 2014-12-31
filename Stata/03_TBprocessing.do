/*-------------------------------------------------------------------------------
# Name:		03_TBprocessing
# Purpose:	Create series of folders in a selected directory for Global Health
# Author:	Tim Essam, Ph.D.
# Created:	07/05/2013
# Copyright:	USAID GeoCenter
# License:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	confirmdir, mvfiles, fs (ssc install confirmdir)
#-------------------------------------------------------------------------------
*/

log using "$pathlog\TBprocessing.log", replace

set more off
dir "$pathin\"
cd "$pathin\TB\"
fs *.xlsx

*Batch process the excel files into stata data
 foreach f in `r(files)' {
	import excel `f', sheet() firstrow clear
	display in yellow "`f'"
		cap ren CountryName Country
		cap ren COUNTRY Country
		rename Year* Yr*
		ds Yr*
		foreach x in `r(varlist)' {
			cap replace `x' = "." if `x'=="-"
			destring `x', replace
		}
		*Reshape data into panel
	reshape long Yr@, i(Country) j(year)
	cap drop if Yr==.
	*Rename the Vaccine variable to the code
	local newname  = Statistic[1]
	rename Yr `newname'
	cap sort Country year
	replace Country=proper(Country)
	rename *, lower
	compress
	*cap local F : subinstr local f ".xlsx" ""
	*cd "$pathin\"
	save `newname'.dta, replace
	*cd "$pathin\TB\"
}
*end

* Merge all the TB data together
cd "$pathin\TB\"
fs *.dta
local i=1
foreach x in `r(files)'{
	merge m:m country year using "`x'", gen(merge`i')
	cap drop statistic indicator_name
	local i=`i'+1
}
*end

sort country year
order country year, first
drop merge*

save "$pathin\TB.dta", replace
clear


use "$pathin\mchIndicatorsMerged.dta", clear

*Merge with the existing MCH data
merge m:m country year using "$pathin\OHS.dta", gen(merge1)
drop merge*
merge m:m country year using "$pathin\TB.dta", gen(merge2)
drop merge*

aorder
sort country year
order iso_alpha3 country year region, first

save "$pathin\MCH_OHS_TB_merged.dta", replace
capture log close

*Export to csv file
export delimited using "$pathgis\HealthIndicators.csv", replace
