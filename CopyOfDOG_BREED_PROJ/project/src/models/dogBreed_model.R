
#####################################

pca_dt <- fread("project/volume/data/interim/pca_dt.csv")

# Apply t-SNE on PCA-transformed data
set.seed(42)  # For reproducibility
tsne_result <- Rtsne(
  as.matrix(pca_dt), # Use the first 4 PCA dimensions
  dims = 2,                 # Reduce to 2 dimensions (not neccesarily needed)
  perplexity = 100,          # Adjust based on dataset size
  verbose = TRUE,           # Show progress
  check_duplicates = FALSE            
)

# Convert t-SNE results into a data.table
tsne_dt <- data.table(
  id = id,                               # Add 'id' column
  tsne_dim1 = tsne_result$Y[, 1],        # First t-SNE dimension
  tsne_dim2 = tsne_result$Y[, 2]         # Second t-SNE dimension
)

#make a plot using ggplot using tsne output
ggplot(tsne_dt,aes(x=tsne_dim1,y=tsne_dim2))+geom_point()
# Save t-SNE results
fwrite(tsne_dt, "project/volume/data/interim/tsne_dt.csv")

####??
# this fits a gmm to the data for all k=1 to k= max_clusters, we then look for a major change in likelihood between k values



###???
opt_num_clus <- 4

# Update Gaussian Mixture Model (GMM) to use t-SNE results
gmm_data <- GMM(
  tsne_dt[, .(tsne_dim1, tsne_dim2)],    # Use t-SNE dimensions
  opt_num_clus,
)

####??
l_clust<-gmm_data$Log_likelihood^3

l_clust<-data.table(l_clust)

net_lh<-apply(l_clust,1,FUN=function(x){sum(1/x)})

cluster_prob<-1/l_clust/net_lh

# we can now plot to see what cluster 1 looks like

tsne_dt$Cluster_1_prob<-cluster_prob$V1

ggplot(tsne_dt,aes(x=tsne_dim1,y=tsne_dim2,col=Cluster_1_prob))+geom_point()

####??

# Predict cluster probabilities using t-SNE dimensions
prob_cluster_tsne <- predict_GMM(
  tsne_dt[, .(tsne_dim1, tsne_dim2)], 
  gmm_data$centroids,
  gmm_data$covariance_matrices,
  gmm_data$weights
)

# Convert to data.table
probabilities_tsne <- data.table(prob_cluster_tsne$cluster_prob)

# Add 'id' column
probabilities_tsne[, id := id]

# Assign clusters based on highest probability
probabilities_tsne[, cluster := max.col(.SD, ties.method = "first"), .SDcols = paste0("V", 1:opt_num_clus)]

# Save probabilities with t-SNE
fwrite(probabilities_tsne, "project/volume/data/processed/tsne_cluster_probabilities.csv")

data <- probabilities_tsne[, .(id, V1, V2, V3, V4)]  # Reorder columns and exclude 'cluster'

# CHECK THIS BEFORE EACH SUBMISSION
data <- data %>%
  rename(
    breed_1 = V1,
    breed_2 = V2,
    breed_3 = V4,
    breed_4 = V3
  )

data <- data[, .(id, breed_1, breed_2, breed_3, breed_4)]

# Save the reordered dataset

# Save the modified table to a new file
fwrite(data, "project/volume/data/processed/reordered_data8.csv")

