# ============================================
# Overall Correlation Analysis and Multicollinearity Removal
# ============================================

# -------------------------------
# Import Necessary Libraries
# -------------------------------
import os
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from statsmodels.stats.outliers_influence import variance_inflation_factor

# -------------------------------
# Set Working Directory
# -------------------------------
# Change this path to your specific working directory
os.chdir("C:\\Users\\xieandfan\\nhanes2023\\2017-2020")

# -------------------------------
# Load the Dataset
# -------------------------------
# Read the dataset from a CSV file
data = pd.read_csv('Logsitic.csv')

# Optional: Display the structure and first few rows of the dataset for verification
print("Dataset Structure:")
print(data.info())
print("\nFirst Few Rows:")
print(data.head())

# -------------------------------
# Prepare Predictor Variables
# -------------------------------
# Remove the target variable 'Group' to retain only predictor variables
predictor_vars = data.drop(columns=['Group']).columns.tolist()

# -------------------------------
# Calculate Correlation Matrix
# -------------------------------
# Compute the correlation matrix for predictor variables
corr_matrix = data[predictor_vars].corr()

# -------------------------------
# Print Correlation Matrix
# -------------------------------
print("\nOverall Correlation Matrix:\n", corr_matrix)

# -------------------------------
# Set Correlation Threshold for Annotation
# -------------------------------
# Define a threshold to annotate only strong correlations
threshold = 0.9

# -------------------------------
# Create Annotation Matrix
# -------------------------------
# Create an annotation matrix that only includes correlation coefficients above the threshold
annot = corr_matrix.where(corr_matrix.abs() >= threshold).round(2).astype(str)

# Replace NaN values in the annotation matrix with empty strings for better visualization
annot = annot.replace('nan', '')

# -------------------------------
# Plot Correlation Heatmap
# -------------------------------
plt.figure(figsize=(20, 18))
sns.heatmap(
    corr_matrix,
    annot=annot,
    fmt='',
    cmap='coolwarm',
    annot_kws={"size": 10},
    cbar_kws={'shrink': .8}
)
plt.title(f'Overall Correlation Matrix (|corr| >= {threshold} annotated)', fontsize=16)
plt.xticks(fontsize=12)
plt.yticks(fontsize=12)
plt.show()
