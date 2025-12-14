#!/bin/bash
#SBATCH --job-name=yeast_rna_pipeline
#SBATCH --output=pipeline_%j.log
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition=msc_appbio

# 1. Setup Environment
source ~/.bashrc
conda activate /users/k25049595/.conda/envs/tophat_env

# 2. Define Variables
GTF="Saccharomyces_cerevisiae.R64-1-1.107.gtf"
INDEX="yeast_bowtie_index"
INPUT_DIR="fastq_gz"
OUT_TOPHAT="output_directory"
OUT_CUFF="cufflinks_output"

# Create output directories
mkdir -p $OUT_TOPHAT
mkdir -p $OUT_CUFF

# 3. Main Loop
for file in $INPUT_DIR/*.fastq.gz; do

    # Extract sample name
    sample_name=$(basename "$file" .fastq.gz)

    echo "Processing Sample: $sample_name"

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
