# ============================================================
# Script Name: Network_Correlation_Analysis.R
# Description: Calculates Pearson correlation coefficients between 
#              Antibiotic Resistance Genes (ARGs) and Bacterial Genera.
#              Output can be used for network visualization (e.g., Gephi).
# Input:  ../data/Soil-ARG.csv
#         ../data/Soil-genus.csv
# Output: ../results/Pearson_correlation_matrix.csv
# ============================================================

# --- 1. Quietly Install and Load Packages ---
# Set CRAN mirror to avoid pop-up menus
options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!require("psych")) install.packages("psych", type = "binary", dependencies = TRUE)
if (!require("reshape2")) install.packages("reshape2", type = "binary", dependencies = TRUE)

library(psych)
library(reshape2)

# Clear environment
rm(list=ls())

# ============================================================
# 2. Configuration (Relative Paths)
# ============================================================

# [Path] Set the relative path to the data directory
# ".." moves one level up from the 'scripts' folder
data_dir <- "../data"

# [File Names] Define the input file names
arg_filename   <- "Soil-ARG.csv"
genus_filename <- "Soil-genus.csv"

# Check if the data directory exists
if (!dir.exists(data_dir)) {
  stop("Error: Data directory not found. Please ensure the working directory is set to the 'scripts' folder.")
}

# ============================================================
# 3. Data Loading
# ============================================================

message("Loading data...")

# Construct full file paths
arg_path   <- file.path(data_dir, arg_filename)
genus_path <- file.path(data_dir, genus_filename)

# Verify that files exist
if (!file.exists(arg_path) || !file.exists(genus_path)) {
  stop(paste("Error: Input files not found in", data_dir, "- Check filenames."))
}

# Read data (row.names = 1 sets the first column as row identifiers)
arg_df   <- read.csv(arg_path, row.names = 1, check.names = FALSE)
genus_df <- read.csv(genus_path, row.names = 1, check.names = FALSE)

# ============================================================
# 4. Data Pre-processing
# ============================================================

# (1) Filter out rows with zero sums to prevent calculation errors
arg_df   <- arg_df[rowSums(arg_df) != 0, ]
genus_df <- genus_df[rowSums(genus_df) != 0, ]

# (2) Transpose data: Correlation requires Rows = Samples, Columns = Variables
arg_t   <- t(arg_df)
genus_t <- t(genus_df)

# (3) Intersect Samples: Keep only samples present in both datasets
common_samples <- intersect(rownames(arg_t), rownames(genus_t))

if(length(common_samples) < 3) {
  stop("Error: Fewer than 3 common samples found. Cannot calculate correlation.")
}

message(paste("Number of common samples detected:", length(common_samples)))

# Subset data to include only common samples
arg_clean   <- arg_t[common_samples, ]
genus_clean <- genus_t[common_samples, ]

# ============================================================
# 5. Correlation Calculation
# ============================================================

message("Calculating Pearson correlation matrix...")

# Calculate Pearson correlation
# Adjust method to "spearman" if data is non-normal
cor_result <- corr.test(genus_clean, arg_clean, method = "pearson", adjust = "none")

# Extract Correlation Coefficients (R) and Significance Levels (P)
r_matrix <- cor_result$r
p_matrix <- cor_result$p

# ============================================================
# 6. Formatting & Export
# ============================================================

# Convert matrices to Long Format (Edge List)
df_r <- melt(r_matrix, value.name = "R")
df_p <- melt(p_matrix, value.name = "P")

# Merge R and P values
final_df <- df_r
final_df$P <- df_p$P
colnames(final_df) <- c("OTU_Genus", "ARG", "R", "P")

# Create results directory if it doesn't exist
if (!dir.exists("../results")) dir.create("../results")

# Define output file path
output_file <- "../results/Pearson_correlation_matrix.csv"

# Save the result
write.csv(final_df, output_file, row.names = FALSE, quote = FALSE)

message(paste("Success! Results saved to:", output_file))
print("Preview of the first 5 rows:")
print(head(final_df))