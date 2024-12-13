library(data.table)
library(dplyr)
library(glmnet)
library(caret)

covar<- fread("./project/volume/data/raw/covar_data.csv")
test<- fread("./project/volume/data/raw/Stat_380_test.csv")
ex_sub<- fread("./project/volume/data/raw/Example_Sub.csv")
train<- fread("./project/volume/data/raw/Stat_380_train.csv")

# **********************************************

age_groups <- c(0,10,30,50,70,90, Inf)
age_range<- c("0-10", "11-30", "31-50", "51-70","71-90", "90+")
train[, age_break := cut(age, breaks = age_groups, labels = age_range, right = FALSE)]
test[, age_break := cut(age, breaks = age_groups, labels = age_range, right = FALSE)]

train[dose_3 == "", dose_3 := "None"]
test[dose_3 == "", dose_3 := "None"]

categorical_switch <- c("age_break", "sex", "centre", "dose_2", "dose_3", "priorSxAtFirstVisit", "posTest_beforeVisit")

train[, (categorical_switch) := lapply(.SD, factor), .SDcols = categorical_switch]
test[, (categorical_switch) := lapply(.SD, factor), .SDcols = categorical_switch]

for (col in categorical_switch) {
  set(test, j = col, value = factor(test[[col]], levels = levels(train[[col]])))
}

group_variables <- setdiff(categorical_switch, "centre")

avg_ic50 <- train[, .(ic50_Omicron_mean = mean(ic50_Omicron, na.rm = TRUE)), by = group_variables]

train <- merge(train, avg_ic50, by = group_variables, all.x = TRUE)
test <- merge(test, avg_ic50, by = group_variables, all.x = TRUE)


overall_ic50 <- mean(train$ic50_Omicron, na.rm = TRUE)
train[is.na(ic50_Omicron_mean), ic50_Omicron_mean := overall_ic50]
test[is.na(ic50_Omicron_mean), ic50_Omicron_mean := overall_ic50]


predictor_variables <- c("ic50_Omicron_mean", "dose_2", "dose_3", "sex", "age_break","priorSxAtFirstVisit", "posTest_beforeVisit" )

X_train <- model.matrix(~ ., data = train[, ..predictor_variables])[, -1]
Y_train <- train$ic50_Omicron
X_test <-  model.matrix(~ ., data = test[, ..predictor_variables])[, -1]

saveRDS(list(X_train = X_train, Y_train = Y_train, X_test = X_test, test = test, overall_ic50 = overall_ic50), "./project/volume/data/interim/RDS_model.rds")
























