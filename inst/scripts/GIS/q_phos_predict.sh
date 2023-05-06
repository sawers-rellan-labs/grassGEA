#!/bin/csh
#BSUB -J "prediction[1-25]" # Job name with array size
#BSUB -o output_%J_%I.log # Standard output filename with job ID and array index
#BSUB -e error_%J_%I.log # Standard error filename with job ID and array index
#BSUB -n 1 # Number of cores per job
#BSUB -M 4000 # Memory per job (in MB)
#BSUB -R "rusage[mem=4000]" # Memory resource
#BSUB -W 24:00 # Wall clock limit

# Load the necessary modules
module load R/4.1.1

# Set the working directory
cd /path/to/working/directory/

# Run the R script for the current array index
Rscript predict_Pvariable.R $LSB_JOBINDEX

# Wait for all jobs to finish
wait

# Concatenate the output CSV files into a single file
cat result_*.csv > final_result.csv
