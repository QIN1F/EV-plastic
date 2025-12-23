# ============================================================
# Script Name: Global_Map_Visualization.R
# Description: Visualizes the global distribution of EV-associated samples 
#              on a world map based on relative abundance.
# Input:  ../data/demo_map_data.csv (Originally EVdata.csv)
# Output: ../results/samples_site_35.pdf
# ============================================================

# Load necessary libraries
# install.packages(c("tidyverse", "maps", "ggsci"))
library(tidyverse)
library(maps)
library(ggsci)

# Clear environment
rm(list=ls())

# ============================================================
# 1. Configuration & Data Loading
# ============================================================

# Define file path (Relative path for reproducibility)
# By default, this points to the demo data in the repository
input_file <- "D:/科研工作/塑料片项目/代码整理/code/world code/EVdata.csv"

# Check if file exists
if (!file.exists(input_file)) {
  stop("Error: Input file not found. Please check the 'data' folder.")
}

# Load the dataset
df <- read.csv(input_file)

# Clean column names: Remove leading/trailing whitespace to avoid errors
colnames(df) <- trimws(colnames(df))

# specific check: Ensure the key column "Relative.abundance" exists
if (!"Relative.abundance" %in% colnames(df)) {
  stop("Error: Column 'Relative.abundance' not found in the input data.")
}

# Load world map data (provided by 'maps' package)
world <- map_data("world")

# ============================================================
# 2. Visualization
# ============================================================

p_map <- ggplot() +
  
  # Layer 1: Draw the world map background
  geom_polygon(data = world, 
               aes(x = long, y = lat, group = group), 
               fill = "#D7D7D7", 
               color = "#D7D7D7", 
               size = 0.1) +
  
  # Layer 2: Plot data points
  # Fill color and size are determined by 'Relative.abundance'
  geom_point(data = df, 
             aes(x = Longitude, 
                 y = Latitude, 
                 fill = Relative.abundance, 
                 size = Relative.abundance),
             shape = 21,       # Circle with border
             color = "black",  # Border color
             stroke = 0.2) +   # Border thickness
  
  # Layer 3: Scales and Styling
  # Set color gradient from light to dark blue
  scale_fill_gradient(low = "lightblue", high = "darkblue", name = "Relative Abundance") + 
  
  # Set the range for point sizes
  scale_size_continuous(range = c(1, 6), name = "Relative Abundance") + 
  
  # Ensure the map maintains the correct aspect ratio (prevents distortion)
  coord_fixed(1.3) +
  
  # Labels and Theme
  labs(x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(
    # Custom legend position inside the plot area
    legend.position = c(0.08, 0.4), 
    legend.background = element_blank(),
    panel.grid = element_blank(),      # Remove grid lines for a cleaner map look
    axis.text = element_text(color = "black")
  )

# Display the map
print(p_map)

# ============================================================
# 3. Export
# ============================================================

# Define output path
output_pdf <- "../results/samples_site_35.pdf"
output_png <- "../results/samples_site_35.png"

# Save map as PDF
ggsave(plot = p_map, 
       filename = output_pdf, 
       height = 96, 
       width = 190, 
       units = "mm")

# Save map as PNG
ggsave(plot = p_map, 
       filename = output_png, 
       height = 96, 
       width = 190, 
       units = "mm")

message(paste("Map saved to:", output_pdf))