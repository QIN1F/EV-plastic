# ==============================================================================
# Project: Venn/Euler Diagram Analysis for Manuscript (One Earth Submission)
# Script Purpose: Generate area-proportional Euler diagrams with percentage labels
# Directory Structure: 
#   - Repository/
#     - data/ (Input CSV files)
#     - scripts/ (This script)
#     - results/ (Output figures - will be created automatically)
# ==============================================================================

# --- 1. Environment Setup ---
# Check and install required packages automatically
required_packages <- c("tidyverse", "eulerr", "gridExtra")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(eulerr)
library(gridExtra)

# --- 2. Path Configuration ---
# Using relative paths for GitHub compatibility
# Assuming the script is run from the 'scripts' directory or the project root
input_file <- "../data/your_data_filename.csv" # Change this to your actual filename
output_dir <- "../results"

# Create results directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
output_file <- file.path(output_dir, "Figure_Venn_Proportional.pdf")

# --- 3. Functional Modules ---

#' Extract species set present in a specific group
#' @param df Dataframe containing abundance data
#' @param prefix Column name prefix for the replicates (e.g., "S_")
#' @return A character vector of species names present in at least one replicate
get_species_set <- function(df, prefix) {
  cols <- grep(paste0("^", prefix), colnames(df))
  if (length(cols) == 0) {
    warning(paste("Warning: No columns found for prefix:", prefix))
    return(character(0))
  }
  # Logical: Present if abundance > 0 in any replicate
  present_rows <- rownames(df)[rowSums(df[, cols, drop = FALSE]) > 0]
  return(present_rows)
}

#' Draw area-proportional Euler diagram
#' @param set_a Set A (Left)
#' @param set_b Set B (Right)
#' @param labels Character vector of length 2 for set names
#' @return An eulerr plot object
plot_custom_euler <- function(set_a, set_b, labels) {
  # Calculate intersection and unique elements
  fit_data <- c(
    "A" = length(setdiff(set_a, set_b)),
    "B" = length(setdiff(set_b, set_a)),
    "A&B" = length(intersect(set_a, set_b))
  )
  
  # Calculate percentage: (Intersection / Total of Set B) * 100
  inter_size <- length(intersect(set_a, set_b))
  perc <- if(length(set_b) > 0) round((inter_size / length(set_b)) * 100, 1) else 0
  
  # Fit Euler diagram
  fit <- euler(fit_data)
  
  # Plotting aesthetics compatible with One Earth / Cell Press standards
  p <- plot(fit,
            quantities = list(type = "counts", fontsize = 8),
            labels = list(labels = labels, fontsize = 10, fontface = "bold"),
            fills = list(fill = c("#99cc99", "#ffccff"), alpha = 0.6), # Green and Pink
            edges = list(lwd = 1.2, col = "black"),
            main = list(label = paste0(perc, "%"), fontsize = 14, fontface = "bold"))
  return(p)
}

# --- 4. Main Pipeline ---

# 4.1 Data Loading
if (!file.exists(input_file)) {
  stop(paste("Error: File not found at", input_file, ". Please check your data folder."))
}
raw_data <- read.csv(input_file, row.names = 1, check.names = FALSE)
raw_data[is.na(raw_data)] <- 0

# 4.2 Extracting all sets based on prefixes
sets <- list(
  S      = get_species_set(raw_data, "S_"),
  EVS    = get_species_set(raw_data, "EVS_"),
  W      = get_species_set(raw_data, "W_"),
  EVW    = get_species_set(raw_data, "EVW_"),
  PETS   = get_species_set(raw_data, "PETS_"),
  PETEVS = get_species_set(raw_data, "PETEVS_"),
  PETEVW = get_species_set(raw_data, "PETEVW_"),
  PETW   = get_species_set(raw_data, "PETW_")
)

# 4.3 Generate individual panels
p1 <- plot_custom_euler(sets$S,      sets$EVS,    c("S", "EVS"))
p2 <- plot_custom_euler(sets$W,      sets$EVW,    c("W", "EVW"))
p3 <- plot_custom_euler(sets$PETS,   sets$PETEVS, c("PETS", "PETEVS"))
p4 <- plot_custom_euler(sets$PETEVW, sets$PETW,   c("PETEVW", "PETW"))

# --- 5. Export ---

# Save as high-resolution PDF
pdf(output_file, width = 16, height = 4.5)
grid.arrange(p1, p2, p3, p4, ncol = 4)
invisible(dev.off())

cat("\nDone! Proportional Euler diagrams saved to:", output_file, "\n")
# sessionInfo() # Optional: display session info for reproducibility