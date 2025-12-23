# ============================================================
# Script Name: Bubble_Plot_Generation.R
# Description: This script processes raw abundance data, performs normalization,
#              filters top abundant genera, and generates a bubble plot.
# Input:  'bubble data.csv' (CSV format)
# Output: 'aro_class_bubble2.pdf' (PDF figure)
# ============================================================

# Load required libraries
library(reshape2)
library(ggplot2)
library(RColorBrewer)

# Clear environment
rm(list=ls()) 
setwd("E:/rcode/bubble") 

# ============================================================
# 1. Data Loading and Pre-processing
# ============================================================

# Read data
# Note: 'check.names=F' preserves original sample names (e.g., "Soil-EV1")
df <- read.csv('bubble data.csv', header = T, stringsAsFactors = T, check.names = F)

# Standardize column names for downstream processing
colnames(df)[1:2] <- c('g', 'p') 

# [CRITICAL STEP] Normalization
# Calculate relative abundance by dividing each value by the total column sum
df[,-c(1:2)] <- sweep(df[,-c(1:2)], MARGIN = 2, colSums(df[,-c(1:2)]), '/') 

# ============================================================
# 2. Filtering and Sorting
# ============================================================

# Sort by total abundance across all samples
df <- df[order(rowSums(df[,-c(1:2)]), decreasing = T), ]

# Filter top 50 genera for visualization
df <- df[1:min(50, nrow(df)), ]

# Sort by group 'p' (Drug Class) to cluster similar types in the plot
df <- df[order(df$p), ]
df <- droplevels(df) 

# Save processed data for reference
write.table(df, 'filtered_aro_name.class.txt', row.names = F, sep = '\t', quote = F)

# ============================================================
# 3. Visualization Setup
# ============================================================

# Reshape data to long format
balloon_melted <- melt(df, id.vars = c('g', 'p'))

# Define color palette
mycol <- c('#A6CEE3','#1F78B4','#B2DF8A','#33A02C','#FB9A99',
           '#E31A1C','#FDBF6F','#FF7F00','#CAB2D6','#6A3D9A',
           '#FFFF99','#B15928')

# Map colors to 'Type' (p)
balloon_melted$cols <- mycol[as.numeric(as.factor(balloon_melted$p))]

# Create a mapping for Y-axis text colors
Lcolorset <- balloon_melted[, c('g', 'p', 'cols')]
Lcolorset <- Lcolorset[!duplicated(Lcolorset), ]

# Lock factor levels to ensure correct order in the plot
# Y-axis: match the sorted genus order
Lcolorset$g <- factor(Lcolorset$g, levels = unique(as.character(df$g))) 
balloon_melted$g <- factor(balloon_melted$g, levels = levels(Lcolorset$g))
# X-axis: maintain original sample order
balloon_melted$variable <- factor(balloon_melted$variable, levels = colnames(df)[-c(1,2)])

# ============================================================
# 4. Plotting
# ============================================================

p_plot <- ggplot(balloon_melted, aes(x = variable, y = g, fill = p)) +
  geom_point(aes(size = value), shape = 21) +
  theme(panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5)) +
  scale_size(range = c(1, 6)) +
  scale_fill_manual(values = mycol) +
  labs(x = "Sample", y = "Genus") +
  guides(fill = guide_legend(title = 'Type', override.aes = list(size = 5)),
         size = guide_legend(title = 'Normalized copy number\n(Copies per bacterial cell)', override.aes = list(shape = 21))) +
  theme(
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 60, hjust = 1, size = 10, color="black"),
    # Color Y-axis labels by group
    axis.text.y = element_text(colour = Lcolorset$cols, size = 10) 
  )

# Output PDF with adjusted width
ggsave('aro_class_bubble2.pdf', p_plot, width = 8, height = 9)