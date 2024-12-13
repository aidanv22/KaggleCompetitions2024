library(data.table)
library(ggplot2)
library(caret)
library(ClusterR)
library(dplyr)
library(Rtsne)
library(xgboost)



submission_template <- fread("project/volume/data/raw/example_sub.csv")
kaggle_test <- fread("project/volume/data/raw/kaggle_test.csv")
train_data <- fread("project/volume/data/raw/kaggle_train.csv")
test_emb <- fread("project/volume/data/raw/test_emb.csv")
train_emb <- fread("project/volume/data/raw/train_emb.csv")

# Extract labels and encode as numeric
labels <- as.factor(train_data$reddit)  # Assuming 'reddit' is the label column
label_encoded <- as.numeric(labels) - 1  # XGBoost requires 0-based indexing


fwrite(test_emb,'./project/volume/data/interim/test_emb.csv')



