/*-------------------------------------------------------------------------------
# Name:		02_OHSprocessing
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

set more off
dir "$pathin\"
cd "$pathin\OHS\"
fs *.xlsx

import excel "$pathin\OHS\ohs_out_of_pocket_expenditures_wb_1995_2012.xlsx", sheet() firstrow clear

ds Year*
foreach x in `r(varlist)' {
	cap replace `x' = "." if `x'=="-"
	destring `x', replace
}
*
*Rename year variable for consistency
rename Year* Yr*

*Clean up missing lines
drop if Country==""

*Reshape the data into a panel
replace Statistic="OoP_Exp"
reshape long Yr@, i(Country) j(year)
local newname  = Statistic[1]
rename Yr `newname'
drop Statistic

replace Country = proper(Country)
rename *, lower
save "$pathin\OHS.dta", replace
clear

log close
