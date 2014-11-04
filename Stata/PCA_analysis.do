clear
capture log close

* Read data from directory
import delimited U:\GlobalHealthIndicators\R\Datain\mptTargeting.csv
cd U:\GlobalHealthIndicators\

* Set path macros for saving graphs
global pathStata "U:/GlobalHealthIndicators/Stata/"
global gph "xline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) yline(0, lwidth(med) lpattern(tight_dot) lcolor(gs10)) ylab(, nogrid) graphregion(fcolor(white) lcolor(white))"

* Label variables for graphs
la var hiv_prev_w_15 "HIV Prevalence"
la var unmetneedmm "Unmet Need"
la var hsv2prevalence "HSV2 Prevalence"
la var hpvprevalence "HPV Prevalence"

* Fix Congo names for graph tidying.
replace countryname ="CONGO-Brazzaville" if countryname == "CONGO (Brazzaville)"
replace countryname ="CONGO-Kinshasa" if countryname == "CONGO (Kinshasa)"

*Set a global variable for the graphics schemes
global gcustom "mlabs(tiny) mlabc(maroon) mc(maroon)"

* Create position offsets so names do not overlap (note: keep changing these)
g pos = 12
replace pos = 6 if regexm(countryname, "(MALAWI|EQUATORIAL GUINEA|CONGO-Brazzaville|CHAD|RWANDA|JAMAICA|TRINIDAD & TOBAGO)")
replace pos = 3 if regexm(countryname, "(SOUTH SUDAN|CAMEROON|CONGO-Kinshasa|HONDURAS|NIGERIA|BAHAMAS|THE GRENADINES)")
replace pos = 9 if regexm(countryname, "(ETHIOPIA|SWAZILAND|ERITREA|SAINT LUCIA)")
replace pos = 7 if regexm(countryname, "(GUATEMALA)")
replace pos = 9 if regexm(countryname, "(ANGOLA)")
replace pos = 2 if regexm(countryname, "(CENTRAL AFRICAN REPUBLIC)")
replace pos = 4 if regexm(countryname, "(BURUNDI)")

*Replace missing values with sample averages
foreach x of varlist hiv_prev_w_15 unmetneedmm hsv2prevalence hpvprevalence {
	egen tmp = mean(`x')
	replace `x' = tmp if `x' ==.
	drop tmp
	}
*end

* Produce correlation matrix and save to excel file called "sti.csv"
eststo clear
estpost correlate unmetneedmm hiv_prev_w_15 hpvprevalence hsv2prevalence, matrix
esttab . using sti.csv, not unstack compress noobs replace

* Run PCA on the four key variables, predict PC1 & PC2
pca unmetneedmm hiv_prev_w_15 hpvprevalence hsv2prevalence 

* Predict the four principal components for mapping
predict PC1 PC2 PC3 PC4

* Plot the first two loadings to see how the variables cluster
* First factor loads heavily on the STIs and second on the unmet needs.
loadingplot, mlabs(small) mlabc(maroon) mc(maroon) 

* Create a plot of the scores based on the first two components
scoreplot, mlabel(countryname) $gcustom mlabv(pos) $gph

g byte f1 = (PC1>=0.5)
g byte f2 = (PC2>=0.5)
g byte filter = (f1==1 | f2==2)
* Now plot a subset of the data with PC1 > 1 and save to Stata folder. 
scoreplot if filter==1 , mlabel(countryname) $gcustom mlabv(pos) title("PCA scores greater than or equal to 0.5") $gph
graph save "$pathStata/pca_subset.gph", replace

* Export the data to a .csv and save in the Stata folder
export delimited using "$pathStata/mpt_pca_results.csv", replace
