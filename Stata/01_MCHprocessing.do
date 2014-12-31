/*-------------------------------------------------------------------------------
# Name:		01_MCHprocessing
# Purpose:	Create series of folders in a selected directory for Global Health
# Author:	Tim Essam, Ph.D.
# Created:	07/05/2013
# Copyright:	USAID GeoCenter
# License:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	confirmdir, mvfiles, fs (ssc install confirmdir)
#-------------------------------------------------------------------------------
*/
capture log close
log using "$pathlog\MCHprocessing.log", replace

*List files in the MCH folder using the fs command
set more off
dir "$pathin\"
cd "$pathin\MCH\"
fs *.xlsx

*Batch process the excel files into stata data
 cap foreach f in `r(files)' {
	import excel `f', sheet() firstrow clear
	display in yellow "`f'"
		cap ren CountryName Country
		cap ren COUNTRY Country
		ds Yr*
		foreach x in `r(varlist)' {
			cap replace `x' = "." if `x'=="-"
			destring `x', replace
		}
		*Reshape data into panel
	reshape long Yr@, i(Country) j(year)

	*Rename the Vaccine variable to the code
	local newname  = Statistic[1]
	rename Yr `newname'
	cap sort Country year
	compress
	cap local F : subinstr local f ".xlsx" ""
	*cd "$pathin\"
	save `newname'.dta, replace
		*cd "$pathin\MCH\"
}
*end

*Batch merge the files into a MasterData file
set more off
use "$pathin\MCH\bcg.dta", clear
fs *.dta
*local fList `r(files)'
*display "`fList'"
*local not bcg.dta
*local fList: list fList- not

local i=1
foreach x in `r(files)'{
	merge m:m Country year using "`x'", gen(merge`i')
	cap drop Statistic Quantile
	local i=`i'+1
}
*end

*Clean up
replace ISO_code = ISO_Code if ISO_code==""
drop ISO_Code Statistic

*Carry backward missing values
gen int negyear = -year
bysort Country (negyear): carryforward Region, gen(Region2) back 
replace Region = Region2 if Region==""
drop negyear Region2 merge*

*Rearrange the data list and clean up strings
sort Country year
order ISO* Country year, first
replace Country = proper(Country)

*Interpolate MMR
g maternalMortalityRateInt=.
levelsof(ISO_code), local(levels)
foreach x of local levels {
 qui ipolate maternalMortalityRate  year if year>=1990 & ISO_code=="`x'", gen(mmr`x') epolate
	replace maternalMortalityRateInt=mmr`x' if ISO_code=="`x'"
	drop mmr`x'
}
*


* Save first cut of data
save "$pathin\mchIndicators.dta", replace

*Load in messy DHS data
clear

dir
cd "$pathin\MCH\Unstandardized"
fs *.xlsx
 foreach f in `r(files)' {
	import excel `f', sheet() firstrow clear
	display in yellow "`f'"
		cap ren CountryName Country
		cap ren COUNTRY Country
		ds Yr*
		foreach x in `r(varlist)' {
			cap replace `x' = "." if `x'=="-"
			destring `x', replace
		}
	reshape long Yr@, i(Country) j(year)
	
	*Rename the Vaccine variable to the code
	local newname  = Statistic[1]
	rename Yr `newname'
	cap sort Country year
	replace Country = proper(Country)
	save `newname'.dta, replace
}
*

fs *.dta
local i=1
foreach x in `r(files)'{
	merge m:m Country year using "`x'", gen(merge`i')
	local i=`i'+1
}
*end	
drop merge*

*Merge the current file with the other one above
merge m:m Country year using "$pathin\mchIndicators.dta", gen(MCH)
drop Statistic MCH

* Save first cut of data
rename *, lower
ren iso_code iso_alpha3
aorder
order iso* country year region, first
sort country year
save "$pathin\mchIndicatorsMerged.dta", replace


log close
