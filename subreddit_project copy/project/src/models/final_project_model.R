


test_emb<-fread("project/volume/data/interim/test_emb.csv")

# Convert training embeddings to DMatrix
dtrain <- xgb.DMatrix(data = as.matrix(train_emb), label = label_encoded)
dtest <- xgb.DMatrix(data = as.matrix(test_emb))





# Define hyperparameters
params <- list(
  objective = "multi:softprob",   # Multi-class classification
  num_class = length(unique(label_encoded)),  # Number of classes
  eval_metric = "mlogloss",       # Evaluation metric
  eta = 0.1,                      # Learning rate
  max_depth = 6,                  # Maximum tree depth
  min_child_weight = 1,           # Minimum sum of instance weight (hessian) needed in a child
  gamma = 0,                      # Minimum loss reduction to split
  subsample = 0.8,                # Subsample ratio of training instances
  colsample_bytree = 0.8          # Subsample ratio of columns when constructing each tree
)



# Perform cross-validation to find the optimal number of boosting rounds
set.seed(123)
cv_results <- xgb.cv(
  params = params,
  data = dtrain,
  nrounds = 500,                  # Max number of boosting rounds
  nfold = 5,                      # 5-fold cross-validation
  early_stopping_rounds = 10,     # Stop if no improvement for 10 rounds
  verbose = 1
)

# Get the best number of rounds
best_nrounds <- cv_results$best_iteration

# Train final model with optimal number of boosting rounds
model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = best_nrounds,
  watchlist = list(train = dtrain),
  verbose = 1
)

# Predict on test data
test_preds <- predict(model, dtest)
test_preds_matrix <- matrix(test_preds, ncol = length(unique(label_encoded)), byrow = TRUE)

# Fill probabilities into the submission file
submission <- submission_template
submission[, 2:ncol(submission)] <- as.data.table(test_preds_matrix)

# Save the final submission
fwrite(submission, "project/volume/data/processed/final_submission_with_cv5.csv")

