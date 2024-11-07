# Load necessary libraries
library(randomForest)
library(ggplot2)
library(ggthemes)

# 1. Set file paths (avoid using setwd for better portability)
data_file <- "C:/Users/RuiRui/Desktop/Microplastics/Count.csv"
output_dir <- "C:/Users/RuiRui/Desktop/Microplastics/Output"

# Create output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# 2. Read the dataset
# Read the CSV file, setting the first column as row names
data <- read.csv(data_file, header = TRUE, row.names = 1)

# Optional: Apply log2(X + 1) transformation to all columns except 'group'
# Uncomment the following line if transformation is needed
# data[ , setdiff(names(data), "group")] <- log2(data[ , setdiff(names(data), "group")] + 1)

# Display the dimensions of the dataset to verify successful loading
print(paste("Data dimensions:", paste(dim(data), collapse = " x ")))

# 3. Data Preprocessing

# Convert the 'group' column to a factor for classification
data$group <- factor(data$group)

# Verify the conversion by checking the structure of the data
str(data)

# 4. Build the Random Forest Model

# Set a seed for reproducibility
set.seed(999)

# Train the Random Forest model with 'group' as the response variable
rf_model <- randomForest(group ~ ., data = data, importance = TRUE)

# Display the model summary
print(rf_model)

# Plot the error rates of the Random Forest model
plot(rf_model, main = "Random Forest Error Rates")

# 5. Perform Cross-Validation

# Set a different seed for cross-validation reproducibility
set.seed(647)

# Conduct recursive feature elimination with cross-validation
cv_results <- rfcv(
  trainx = data[ , setdiff(names(data), "group")],
  trainy = data$group,
  cv.fold = 5,
  step = 0.75  # Adjust the step size as needed for feature reduction
)

# Display the number of variables and corresponding cross-validation error rates
print("Number of Variables:")
print(cv_results$n.var)
print("Cross-Validation Error Rates:")
print(cv_results$error.cv)

# 6. Visualize Cross-Validation Results
# Create a base R plot for cross-validation error rates
plot(
  cv_results$n.var, cv_results$error.cv,
  type = "o",
  lwd = 2,
  col = "steelblue",
  pch = 16,
  xlab = "Number of Variables",
  ylab = "Cross-validation Error Rate",
  main = "Cross-validation Error Rate vs. Number of Variables",
  xlim = c(1, max(cv_results$n.var)),
  ylim = c(0, max(cv_results$error.cv) + 0.05)
)

# Add grid lines for better readability
grid()

# Add a horizontal reference line at y = 0
abline(h = 0, col = "gray", lty = 2)

# Add a legend to the plot
legend(
  "topright",
  legend = "Error Rate",
  col = "steelblue",
  lty = 1,
  lwd = 2,
  bty = "n"
)

# Annotate the plot with the minimum error rate
min_error <- min(cv_results$error.cv)
min_vars <- cv_results$n.var[which.min(cv_results$error.cv)]
text(
  x = max(cv_results$n.var),
  y = max(cv_results$error.cv),
  labels = paste("Minimum Error:", round(min_error, 4)),
  pos = 3
)


# 7. Extract and Visualize Important Genes

# Extract variable importance from the Random Forest model
importance_df <- as.data.frame(importance(rf_model))
importance_df$Gene <- rownames(importance_df)

# Order the dataframe by MeanDecreaseGini in descending order
importance_df <- importance_df[order(importance_df$MeanDecreaseGini, decreasing = TRUE), ]

# Select the top 50 important genes (adjust as needed)
top_genes <- importance_df[1:50, ]

# Display the top genes
print("Top Important Genes:")
print(top_genes)

# Define a color gradient from dark purple to light purple
color_gradient <- c("#8B008B", "#D8BFD8")

# Create a horizontal bar plot for gene importance using ggplot2
gene_importance_plot <- ggplot(top_genes, aes(x = reorder(Gene, MeanDecreaseGini), y = MeanDecreaseGini)) +
  geom_bar(stat = "identity", aes(fill = MeanDecreaseGini), width = 0.7) +
  geom_text(
    aes(label = round(MeanDecreaseGini, 2)),
    hjust = -0.1,
    size = 4,
    color = "black"
  ) +
  scale_fill_gradient(low = color_gradient[1], high = color_gradient[2]) +
  coord_flip() +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 12),
    axis.title = element_text(size = 14)
  ) +
  labs(
    title = "Top 50 Important Genes in Prediction Model",
    x = "Gene",
    y = "Mean Decrease Gini"
  ) +
  ylim(0, max(top_genes$MeanDecreaseGini) * 1.1)  # Ensure labels are not cut off

# Display the gene importance plot
print(gene_importance_plot)

# Save the gene importance plot as a PDF in the output directory
ggsave(
  filename = file.path(output_dir, "top_genes_importance_plot.pdf"),
  plot = gene_importance_plot,
  width = 10,
  height = 8
)
