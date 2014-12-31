/*-------------------------------------------------------------------------------
# Name:		00_SetupFolderGlobals
# Purpose:	Create series of folders in a selected directory for Global Health
# Author:	Tim Essam, Ph.D.
# Created:	07/05/2013
# Copyright:	USAID GeoCenter
# License:	<Tim Essam Consulting/OakStream Systems, LLC>
# Ado(s):	confirmdir, mvfiles, fs (ssc install confirmdir)
#-------------------------------------------------------------------------------
*/
set more off
*Make directories for the study*
*install the confirm directory ado if not already installed
/*Notes: scheme-burd scheme-mrc scheme_rbn1mono also used, but not checked */
local required_ados confirmdir mvfiles fs spatgsa variog adolist labellist
foreach x of local required_ados { 
	capture findfile `x'.ado
		if _rc==601 {
			cap ssc install `x'
		}
		else disp in yellow "`x' currently installed."
	}
*end

*Install list of adofiles needed for program
*To be completed

*Determine path for the study (needs to be modified)
global projectpath "C:\Users\t\Box Sync\"
cd "$projectpath"

*Run a macro to set up study folder (needs to be modified)
local pFolder GlobalHealthIndicators
foreach dir in `pFolder' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
		mkdir "`dir'"
		display in yellow "Project directory named: `dir' created"
		}
	else disp as error "`dir' already exists, not created."
	cd "$projectpath\`dir'"
	}
*end

*Run initially to set up folder structure
*Choose your folders to set up as the local macro `folders'
local folders Rawdata Dofiles Datain Log Output Dataout Excel PDF Word Graph GIS Export R
foreach dir in `folders' {
	confirmdir "`dir'"
	if `r(confirmdir)'==170 {
			mkdir "`dir'"
			disp in yellow "`dir' successfully created."
		}
	else disp as error "`dir' already exists. Skipped to next folder."
}
*end

/*---------------------------------
# Set Globals based on path above #
-----------------------------------*/
global date $S_DATE
local dir `c(pwd)'
global path "`dir'"
global pathdo "`dir'\Dofiles"
global pathlog  "`dir'\Log"
global pathin "`dir'\Datain"
global pathout "`dir'\Dataout"
global pathgraph "`dir'\Graph"
global pathxls "`dir'\Excel"
global pathreg "`dir'\Output"
global pathgis "`dir'\GIS"
global pathraw "`dir'\Rawdata"
global pathexport "`dir'\Export"
global pathR "`dir'\R"
macro list 

/*------------------------------------------------------------
# Manually copy/download data into Datain or Rawdata Folder #



