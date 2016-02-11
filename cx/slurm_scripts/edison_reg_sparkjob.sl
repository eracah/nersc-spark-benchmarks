#!/bin/bash -l
#SBATCH -p regular
#SBATCH --qos=premium
#SBATCH -N 32
#SBATCH -c 32
#SBATCH -t 01:30:00
#SBATCH --ccm

exmem=$1
if [[ $exmem == '' ]];then exmem=50; fi
#try lowering memory to see if that stops dying
#if [[ $exmem == '' ]];then exmem=30; fi
# did not, but at least generated Java out of memory errors


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
