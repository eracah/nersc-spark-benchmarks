#!/bin/bash -l
#SBATCH -p debug
#SBATCH -N 32
#SBATCH -t 30
#SBATCH --ccm

module load spark

def_rank=16
def_exmem=80
exmem=${1:-def_exmem}
rank=${2:-def_rank}
SCRIPT_DIR=/project/projectdirs/paralleldb/spark/benchmarks/cx
$SCRIPT_DIR/runbig.sh 960 $rank 0 5 ""  $exmem $SCRIPT_DIR 
