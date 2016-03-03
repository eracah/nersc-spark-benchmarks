#!/bin/bash
#SBATCH -p debug 
#SBATCH -N 10
#SBATCH -t 0:30:00
#SBATCH --image=docker:lgerhardt/spark-1.5.1:v3
#SBATCH --volume=/global/cscratch1/sd/lgerhard:/srv
#SBATCH -o slurm-outputs/image-cori-spark-%j.out
#SBATCH -e slurm-outputs/image-cori-spark-%j.err

module load shifter

shifter image_helper.script
