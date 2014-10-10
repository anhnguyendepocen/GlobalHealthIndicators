clear
capture log close

* Read data from directory
import delimited U:\GlobalHealthIndicators\R\Datain\mptTargeting.csv

* Set path macros for saving graphs
global pathStata "U:/GlobalHealthIndicators/Stata/"

* Fix Congo names for graph tidying.
replace countryname ="CONGO-Brazzaville" if countryname == "CONGO (Brazzaville)"
replace countryname ="CONGO-Kinshasa" if countryname == "CONGO (Kinshasa)"

*Set a global variable for the graphics schemes
global gcustom "mlabs(tiny) mlabc(maroon) mc(maroon)"

* Create position offsets so names do not overlap
g pos = 12
replace pos = 6 if regexm(countryname, "(MALAWI|EQUATORIAL GUINEA|CONGO-Brazzaville|CHAD|RWANDA)")
replace pos = 3 if regexm(countryname, "(SOUTH SUDAN|CAMEROON|CONGO-Kinshasa)")
replace pos = 9 if regexm(countryname, "(ETHIOPIA|SWAZILAND|ERITREA)")
replace pos = 8 if regexm(countryname, "(ANGOLA)")
replace pos = 4 if regexm(countryname, "BURUNDI")

* Run PCA on the four key variables, predict PC1 & PC2
pca hiv_prev_w_15 unmetneedmm hsv2prevalence hpvprevalence

* Predict the four principal components for mapping
predict PC1 PC2 PC3 PC4

* Plot the first two loadings to see how the variables cluster
loadingplot, mlabs(small) mlabc(maroon) mc(maroon)

* Create a plot of the scores based on the first two components
scoreplot, mlabel(countryname) $gcustom mlabv(pos)

* Now plot a subset of the data with PC1 > 1 and save to Stata folder. 
scoreplot if PC1>=1, mlabel(countryname) $gcustom mlabv(pos) title("PCA Scores Greater than 1")
graph save "$pathStata/pca_subset.gph", replace

* Export the data to a .csv and save in the Stata folder
export delimited using "$pathStata/mpt_pca_results.csv", replace
