# Plot the data and Components used in the PCA

remove(lists = ls())

library("ggplot2")
library("dplyr")
library("reshape")
library("RColorBrewer")
library("grid")
library("scales")
library("MVN")

wd <- c("C:/Users/tessam/Documents/GH_Manuscript")
setwd(wd)

file.name <- "mpt_pca_results.csv"
d <- read.csv(file.name)
d.sub <- d[,1:5]


# Reshape the data so each variable can be plotted as a histogram
d.melt <- d.sub
names(d.melt) <- c("Country", "HIV Prevalence", "Unmet Needs", "HSV Prevalence",
	"HPV Prevalence")

d.melt <- melt(d.melt, id = c("Country"))

# Determine colour palette to use for plots
brewer.pal(8, "Purples")
cust.colors <- brewer.pal(8, "Greys")[4:7]

# Create histogram of each variable
m <- ggplot(d.melt, aes(x = value, fill = variable))
p <- m + geom_histogram((aes(y = ..density..))) + facet_wrap(~variable) +
	scale_x_continuous(labels = percent) +  scale_fill_manual(values = cust.colors) +
	theme(legend.position = "none", legend.key = element_blank(), legend.title = element_blank(),
	panel.background = element_rect(fill = "gray93"), 
	axis.text.y = element_text(size = 10, colour = "#565A5C"),
	axis.text.x = element_text(hjust = 0.5, size = 10, colour = "#565A5C"), 
 	axis.title.y = element_text(size = 11, colour = "#565A5C"))+
	labs(x = "", y = "Count", title = "Distribution of indicators used in PCA \n")
png(filename = "PCA.distributions.png", width = 1200, height = 1200, pointsize = 12, res = 150)
p
dev.off()

# Now repeat for the PCA predicted components
d.sub2 <- d[, c(1, 7, 8)] 
names(d.sub2) <- c("Country", "PCA1", "PCA2")

d.melt2 <- melt(d.sub2, id = c("Country"))

m <- ggplot(d.melt2, aes(x = value, fill = variable))
p <- m + geom_histogram((aes(y = ..density..))) + facet_wrap(~variable) +
	scale_fill_manual(values = cust.colors) +
	theme(legend.position = "none", legend.key = element_blank(), legend.title = element_blank(),
	panel.background = element_rect(fill = "gray93"), 
	axis.text.y = element_text(size = 10, colour = "#565A5C"),
	axis.text.x = element_text(hjust = 0.5, size = 10, colour = "#565A5C"), 
 	axis.title.y = element_text(size = 11, colour = "#565A5C"))+
	labs(x = "Predicted value", y = "Count", title = "Distribution of predicted components (1 and 2) \n")
png(filename = "PCA.predictions.png", width = 1200, height = 1200, pointsize = 12, res = 150)
p
dev.off()
