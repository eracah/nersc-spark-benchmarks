#!/bin/bash -l
#SBATCH -p debug
#SBATCH -N 32
#SBATCH -t 30
#SBATCH --ccm

exmem=$1
if [[ $exmem == '' ]];then exmem=100; fi


DES_LOG_DIR=$SCRATCH/cx/spark-1.5.1-defaults-30N
SCRIPT_DIR=/project/projectdirs/paralleldb/spark/benchmarks/cx


if [ -r  /var/shifterConfig.json ] ; then
#    module load spark/1.5.1
    $SCRIPT_DIR/runspark.sh  $exmem $DES_LOG_DIR 960
else
    echo not in shifter image
    module load shifter
    shifter --image=local:/ $SCRIPT_DIR/runspark.sh  $exmem $DES_LOG_DIR 960
fi
