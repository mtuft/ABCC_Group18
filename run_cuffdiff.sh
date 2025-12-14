#!/bin/bash
#SBATCH --job-name=yeast_cuffdiff_UQ
#SBATCH --output=cuffdiff_UQ_%j.log
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --partition=msc_appbio

# 1. Setup Environment
source ~/.bashrc
conda activate /users/k25049595/.conda/envs/tophat_env

# 2. Define Files
GTF="Saccharomyces_cerevisiae.R64-1-1.107.gtf"
SDRF="E-MTAB-7657.sdrf.txt"

# 3. Generate the lists of BAM files for each time point
# Group 1: 6 Hours (Lag)
LIST_6H=$(awk -F'\t' '$30 == "6" {printf "output_directory/" $28 "/accepted_hits.bam,"}' $SDRF | sed 's/,$//')

# Group 2: 14 Hours (Exponential)
LIST_14H=$(awk -F'\t' '$30 == "14" {printf "output_directory/" $28 "/accepted_hits.bam,"}' $SDRF | sed 's/,$//')

# Group 3: 26 Hours (Diauxic)
LIST_26H=$(awk -F'\t' '$30 == "26" {printf "output_directory/" $28 "/accepted_hits.bam,"}' $SDRF | sed 's/,$//')

# 4. Run Cuffdiff with UQ Normalization

/users/k25049595/.conda/envs/tophat_env/bin/cuffdiff -p 4 \
  -N \
  -L Lag,Exponential,Diauxic \
  -o cuffdiff_results_UQ \
  $GTF \
  $LIST_6H $LIST_14H $LIST_26H
