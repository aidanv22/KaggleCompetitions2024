prepared_data <- readRDS("./project/volume/data/interim/RDS_model.rds")

X_train <- prepared_data$X_train
Y_train <- prepared_data$Y_train
X_test <- prepared_data$X_test
test_data <- prepared_data$test_data
overall_mean_ic50 <- prepared_data$overall_ic50

# Train Ridge regression model using cross-validation
set.seed(123) # For reproducibility
cv_ridge <- cv.glmnet(X_train, Y_train, alpha = 0)  # Ridge regression (alpha = 0)
best_lambda <- cv_ridge$lambda.min

# Refit model with optimal lambda and save it
ridge_model <- glmnet(X_train, Y_train, alpha = 0, lambda = best_lambda)
saveRDS(ridge_model, "project/volume/models/ridge_model.rds")

# Make predictions on training data
train_predictions_ridge <- predict(ridge_model, newx = X_train)

# Calculate RMSE and R-squared for training predictions
rmse_ridge <- sqrt(mean((Y_train - train_predictions_ridge)^2))
r_squared_ridge <- 1 - (sum((Y_train - train_predictions_ridge)^2) / sum((Y_train - mean(Y_train))^2))

# Print evaluation metrics
cat("Ridge - Training RMSE:", rmse_ridge, "\n")
cat("Ridge - Training R-squared:", r_squared_ridge, "\n")

# Make predictions on the test data
test_predictions_ridge <- predict(ridge_model, newx = X_test)

# DEBUG: Check row count of test_predictions_ridge
cat("Test predictions count:", length(test_predictions_ridge), "\n")  # Should be 10,000

# Calculate the mean of the test predictions
test_mean_ic50_ridge <- mean(test_predictions_ridge)
cat("Ridge - Test mean ic50_Omicron:", test_mean_ic50_ridge, "\n")

# Check if the test mean is close to the overall training mean
if (abs(test_mean_ic50_ridge - overall_mean_ic50) > 1) {
  cat("Warning: Ridge Test mean ic50_Omicron is far from the training mean! Mean:", test_mean_ic50_ridge, "\n")
}

# Prepare the final submission data frame
final_submission_ridge <- data.frame(
  sample_id = test$sample_id,
  ic50_Omicron = as.numeric(test_predictions_ridge)
)

# DEBUG: Check final row count of submission
cat("Final submission rows:", nrow(final_submission_ridge), "\n")  # Should be 10,000

# Save the final submission file
fwrite(final_submission_ridge, "project/volume/data/processed/submit_new.csv")



#####
