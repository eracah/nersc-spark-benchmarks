#!/bin/bash -l
#SBATCH -p debug
#SBATCH -N 31
#SBATCH -t 30
#SBATCH --ccm
#SBATCH -o slurm_outputs/slurm_$SLURM_JOB_ID.out
#SBATCH -e slurm_outputs/slurm_$SLURM_JOB_ID.out
while [[ $# > 0 ]]
do
key=$1

case $key in
    -r|--rank)
    RANK=$2
    shift
    ;;
    -e|--exmem)
    EXMEM=$2
    shift
    ;;
    -c|--cores)
    CORES=$2
    shift
    ;;	
    --collectl)
    USE_COLLECTL=TRUE
    ;;
    *)
            # unknown option
    ;;
esac
shift
done

def_rank=16
def_exmem=80
def_total_cores=960
exmem=${EXMEM:-$def_exmem}
rank=${RANK:-$def_rank}
total_cores=${CORES:-$def_total_cores}
SCRIPT_DIR=/project/projectdirs/paralleldb/spark/benchmarks/cx

module load spark
if [ !  -z $USE_COLLECTL ];
then
	module load collectl
	start-collectl.sh 
	$SCRIPT_DIR/bin/runbig.sh $total_cores $rank 0 5 ""  $exmem $SCRIPT_DIR
	stop-collectl.sh
else
	$SCRIPT_DIR/bin/runbig.sh $total_cores $rank 0 5 ""  $exmem $SCRIPT_DIR
fi

