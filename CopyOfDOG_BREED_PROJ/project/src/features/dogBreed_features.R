library(data.table)
library(ggplot2)
library(caret)
library(ClusterR)
library(dplyr)
library(Rtsne)

data <- fread("./project/volume/data/raw/data.csv")
ex_sub <- fread("./project/volume/data/raw/example_sub.csv")


###### ***** USED THIS!!!
id <- data$id
data$id <- NULL

pca <- prcomp(data)

screeplot(pca)
summary(pca)
biplot(pca)

pca_dt <- data.table(unclass(pca)$x)

fwrite(pca_dt,"project/volume/data/interim/pca_dt.csv")



