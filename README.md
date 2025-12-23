# Analysis and visualization Code for: Extracellular Vesicles in the Plastisphere: Emerging Hotspots for the Dissemination of Selected Antibiotic Resistance and Virulence Genes
This repository contains R scripts and shell pipelines used for data analysis and visualization in the manuscript.

## Data Availability

Due to file size limitations, the full raw datasets are not hosted in this repository.

- Raw Sequencing Data: Available at NCBI/ENA under Accession Number [PRJNA1176506].
- Source Data: The underlying data for all figures is provided in the Supplementary Materials of the manuscript.
- Demo Data: This repository contains demonstration files in the data folder to allow users to test the scripts.

## Directory Structure

- data: Contains demo datasets.
- scripts: Contains R and Shell scripts.

## Analysis Workflow

### 1. Visualization

Bubble Plot
- Script: scripts/Bubble_Plot.R
- Input: data/demo_data.csv
- Description: Visualizes relative abundance.

Global Map
- Script: scripts/Global_Map_Visualization.R
- Input: data/demo_map_data.csv
- Description: Maps sample distribution based on coordinates.

Venn Diagram
- Script: scripts/Venn.R
- Input: data/demo_venn data.xls
- Description: Visualizes the overlap of ARGs or taxa between different groups.

### 2. Statistical Analysis

Correlation Network
- Script: scripts/Network_Correlation_Analysis.R
- Input: data/demo_network_ARG.csv and data/demo_network_genus.csv
- Output: results/Pearson_correlation_matrix.csv
- Description: Calculates Pearson correlation between taxa and ARGs.

### 3. Bioinformatics Pipeline

Phylogenetic Tree
- Script: scripts/Phylogenetic_Tree_Construction.sh
- Description: A shell script for taxonomic classification and tree inference using GTDB-Tk.
- Note: This script requires genome bins (MAGs) as input. The binning process is described in the Methods section of the manuscript.

## Requirements

- R (v4.0+): ggplot2, reshape2, tidyverse, maps, psych
- Linux Environment: Conda, GTDB-Tk v2.1.1+

---
For questions, please contact the corresponding author.