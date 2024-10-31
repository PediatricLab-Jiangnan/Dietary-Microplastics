# ---------------------------
# 1. Load Necessary R Packages
# ---------------------------

# If 'pheatmap' is not installed, uncomment and run the following line:
# install.packages("pheatmap")

library(pheatmap)  # For creating heatmaps

# ---------------------------
# 2. Set Up Color Gradient
# ---------------------------

# Define a custom color gradient from blue to white to red
mycol <- colorRampPalette(c("#0da9ce", "white", "#e74a32"))(100)

# ---------------------------
# 3. Load and Prepare the Data
# ---------------------------

# Set the working directory using forward slashes to avoid escape character issues
setwd("C:/Users/Ruiandxiaozhongzhong/Desktop/Microplastics/humanblood")

# Read the gene expression data from a CSV file
dt <- read.csv('humanblood.csv', stringsAsFactors = FALSE)

# Remove any rows with missing values to ensure clean data
dt <- na.omit(dt)

# Set the first column as row names and remove it from the data frame
# Assumes the first column contains unique identifiers (e.g., gene names)
rownames(dt) <- dt[, 1]
df <- as.matrix(dt[, -1])

# ---------------------------
# 4. Normalize the Data
# ---------------------------

# Perform Z-score normalization for each row (gene)
# This standardizes the data to have a mean of 0 and standard deviation of 1
df <- t(scale(t(df)))

# ---------------------------
# 5. Add Group Information
# ---------------------------

# Define the group labels for the samples
# Here, 15 samples are labeled as "Con" (Control) and 15 as "Micro" (Treatment)
# Adjust the numbers based on your actual data
group_labels <- c(rep("Con", 15), rep("Micro", 15))

# Check if the number of group labels matches the number of columns in the data matrix
if (length(group_labels) != ncol(df)) {
  stop("The number of group labels does not match the number of samples.")
}

# Create a data frame for column annotations using the group labels
group <- data.frame(Type = group_labels)
rownames(group) <- colnames(df)  # Assign sample names to the annotation data frame

# ---------------------------
# 6. Set Group Colors
# ---------------------------

# Define specific colors for each group in the annotation
group_colors <- list(Type = c(Con = "#0da9ce", Micro = "#e74a32"))

# ---------------------------
# 7. Plot the Heatmap
# ---------------------------

# Generate the heatmap using pheatmap with the specified parameters
pheatmap(
  mat = df,                     # The normalized data matrix
  color = mycol,                # Apply the custom color gradient
  scale = 'none',               # Data is already normalized; no further scaling
  cluster_rows = FALSE,         # Do not perform clustering on rows
  cluster_cols = FALSE,         # Do not perform clustering on columns
  show_colnames = FALSE,        # Do not display column names (sample names)
  show_rownames = TRUE,         # Display row names (e.g., gene names)
  fontsize_row = 10,            # Font size for row labels
  cellheight = 25,              # Height of each cell in the heatmap
  border_color = "white",       # Color of the cell borders
  annotation_col = group,       # Add group annotations to the columns
  annotation_colors = group_colors, # Apply the defined group colors
  main = "Gene Expression Heatmap"  # Title of the heatmap (optional)
)
