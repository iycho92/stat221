#!/bin/bash
#SBATCH -J script-testing # name for job array
#SBATCH -o all.out #Standard output
#SBATCH -e all.err #Standard error
#SBATCH -p general #Partition
#SBATCH -t 06:00:00 #Running time of 6 hours.
#SBATCH --mem-per-cpu 3000 #Memory request
#SBATCH -n 1 #Number of cores
#SBATCH -N 1 #All cores on one machine

# first arg = numThetadraws: e.g. 20
# second arg = numYdraws: e.g. 20
# third arg = job id

mkdir odyssey

module load centos6/R-3.1.1

Rscript task3_odyssey.R 20 25 $SLURM_ARRAY_TASK_ID