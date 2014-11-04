# title: "PCA.Analysis.Global.Health"
# author: "Tim Essam, GeoCenter"
# date: "Thursday, September 25, 2014"
# output: htlm_document
# ===

# Clear workspace and load libraries for analysis.
remove(list=ls())  

# Check that libraries exist, if not install them (Can be sourced as well).
# If the ggbiplot will not install, it may be necessary to do a github install.
required_lib =c("ggplot2","grid", "devtools", "ggbiplot")

lib_check<-function(){
  for(i in 1:length(required_lib)){
    if(required_lib[i] %in% rownames(installed.packages()) == FALSE)
    {install.packages(required_lib[i])}
  }
}
lib_check()
lapply(required_lib, require, character.only=T)

# Define lab colors (TODO: Source this)
# Lab RGB colors
redL   	<- c("#B71234")
dredL 	<- c("#822443")
dgrayL 	<- c("#565A5C")
lblueL 	<- c("#7090B7")
dblueL 	<- c("#003359")
lgrayL	<- c("#CECFCB")

# Set working directory
setwd("U:/GlobalHealthIndicators/R/Datain")
d <- read.csv("mptTargeting.csv", sep=",", header=TRUE, stringsAsFactors=FALSE)

# Convert countries to row.names for ease in using the prcomp function and following the example found here.
df <- d[,-1]
rownames(df) <- d[,1]

dimnames(df)

# First, have a look at the means then the variances. Recall that PCA relies only on the variance, 
# so we want to ensure that the variances are of similar size and no single variable is dominating.

apply(df,2,function(x){
    mean(x[!is.na(x)])
    })  
apply(df,2,function(x){
  var(x[!is.na(x)])
}) 

# Use prcomp and set scale = TRUE to ensure that variables are standardized. 
# Using the na.omit() function to allow for missing values in the data.
pca.out = prcomp(na.omit((df)), scale=TRUE)
pca.out

names(pca.out)
# Create x & y axis labels

biplot((pca.out), var.axes = TRUE, scale = 0, cex = c(0.40, 1), col = c(lblueL , dredL))
par( font = .75)
title("Principal Components Analysis for\n Multipurpose prevention technologies", cex.main = 1, 
	col.main = dredL)

# Try ggplot2 to make graph a little cleaner?
scores = as.data.frame(pca.out$x)
ggplot(data = scores, aes(x = PC1, y = PC2, label = rownames(scores))) +
  geom_hline(yintercept = 0, colour = "gray65") +
  geom_vline(xintercept = 0, colour = "gray65") +
  geom_text(colour = "tomato", alpha = 0.8, size = 4) +
  ggtitle("PCA plot of MPT Targeting Indicators ")
