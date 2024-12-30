#!/bin/bash

# =========================================================================================================
#                              Pangenomics Pipeline Setup Script
# =========================================================================================================
#   Author: Jash Trivedi
#   Description: This script sets up a conda environment for the pangenomics pipeline, installs necessary 
#   dependencies including Snakemake, and configures CLARC for downstream analyses. It ensures all tools 
#   and resources are installed and ready for seamless pipeline execution.
# =========================================================================================================

# Exit immediately if a command exits with a non-zero status
set -euo pipefail

# Colors for output messages
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}Starting setup for the Pangenomics pipeline...${NC}"

# =========================================================================================================
# Step 1: Check for Conda Installation
# ---------------------------------------------------------------------------------------------------------
# Ensure that Conda is installed on the system before proceeding.
# If Conda is not installed, the script will terminate with an error message.
# =========================================================================================================
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Error: Conda is not installed. Please install Miniconda or Anaconda first.${NC}"
    exit 1
fi

# =========================================================================================================
# Step 2: Create and Configure Conda Environment
# ---------------------------------------------------------------------------------------------------------
# A dedicated conda environment will be created for the pangenomics pipeline to isolate dependencies.
# The script adds required channels for accessing bioinformatics tools.
# =========================================================================================================
echo -e "${YELLOW}Creating a conda environment for the Pangenomics pipeline...${NC}"

# Add necessary Conda channels
conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

# Create the environment and install dependencies using the provided YAML file
if [ ! -f "environments/pangenomics_pipeline.yaml" ]; then
    echo -e "${RED}Error: environments/pangenomics_pipeline.yaml file not found. Please ensure it exists before proceeding.${NC}"
    exit 1
fi

conda env create -f environments/pangenomics_pipeline.yaml

# Activate the environment
source activate pangenomics_pipeline

# =========================================================================================================
# Step 3: Verify Snakemake Installation
# ---------------------------------------------------------------------------------------------------------
# Ensure Snakemake has been successfully installed by checking its version.
# =========================================================================================================
echo -e "${YELLOW}Verifying Snakemake installation...${NC}"
if snakemake --version &> /dev/null; then
    echo -e "${GREEN}Snakemake installed successfully. Version: $(snakemake --version)${NC}"
else
    echo -e "${RED}Error: Snakemake installation failed. Please check the setup process.${NC}"
    exit 1
fi

# =========================================================================================================
# Step 4: Install and Configure CLARC
# ---------------------------------------------------------------------------------------------------------
# CLARC (Classification and Locus-based Analysis of Resistome Content) will be cloned and installed.
# This tool is essential for analyzing resistome and gene content in pangenome studies.
# =========================================================================================================
echo -e "${YELLOW}Installing and configuring CLARC...${NC}"

# Clone the CLARC repository
git clone https://github.com/IndraGonz/CLARC.git

# Navigate into the CLARC directory
cd CLARC

# Install CLARC
python setup.py install

# Return to the root directory
cd ..

echo -e "${GREEN}CLARC installed successfully.${NC}"

# =========================================================================================================
# Step 5: Final Setup
# ---------------------------------------------------------------------------------------------------------
# Print a success message with instructions for activating the environment.
# =========================================================================================================
echo -e "${GREEN}Setup complete! The environment is ready for the Pangenomics pipeline.${NC}"
echo -e "${YELLOW}To activate the environment, run:${NC} conda activate pangenomics_pipeline"
