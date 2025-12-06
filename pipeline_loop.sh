#!/bin/bash
#SBATCH --job-name=yeast_rna_pipeline
#SBATCH --output=pipeline_%j.log
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=msc_appbio

# 1. Setup Environment
# (Adjust this line if you usually load a module for conda, e.g., module load anaconda3)
source ~/.bashrc
conda activate /users/k25049595/.conda/envs/tophat_env

# 2. Define Variables
GTF="Saccharomyces_cerevisiae.R64-1-1.107.gtf"
INDEX="yeast_bowtie_index"
INPUT_DIR="fastq_gz"
OUT_TOPHAT="output_directory"
OUT_CUFF="cufflinks_output"

# Create output directories if they don't exist
mkdir -p $OUT_TOPHAT
mkdir -p $OUT_CUFF

# 3. The Main Loop
for file in $INPUT_DIR/*.fastq.gz; do

    # Extract the sample name (e.g., gets "ERR3148791" from "fastq_gz/ERR3148791.fastq.gz")
    sample_name=$(basename "$file" .fastq.gz)

    echo "=================================================="
    echo "Processing Sample: $sample_name"
    echo "Time: $(date)"
    echo "=================================================="

    # Run TopHat
    echo "Running TopHat..."
    tophat -p 4 \
        -G $GTF \
        -o $OUT_TOPHAT/$sample_name \
        $INDEX \
        $file

    # Run Cufflinks
    echo "Running Cufflinks..."
    cufflinks -p 4 \
        -G $GTF \
        -o $OUT_CUFF/$sample_name \
        $OUT_TOPHAT/$sample_name/accepted_hits.bam

    echo "Finished $sample_name"

done
