#!/bin/bash

prefix=$1
suffix=$2
sbatch ./slurm_scripts/"$prefix"_spark"$suffix".sl
