#!/bin/bash -l
#SBATCH -p debug
#SBATCH -N 31
#SBATCH -t 30
#SBATCH --ccm
#SBATCH -o /project/projectdirs/paralleldb/spark/benchmarks/cx/slurm_outputs/slurm_%A.out
#SBATCH -e /project/projectdirs/paralleldb/spark/benchmarks/cx/slurm_outputs/slurm_%A.out
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
    -b|--breeze)
    USE_BREEZE=TRUE
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
elif [ !  -z $USE_BREEZE ];
then
        module load breeze
	trace-program.sh -f $SPARK_WORKER_DIR/breeze_trace_log \
	$SCRIPT_DIR/bin/runbig.sh $total_cores $rank 0 5 ""  $exmem $SCRIPT_DIR
else
	$SCRIPT_DIR/bin/runbig.sh $total_cores $rank 0 5 ""  $exmem $SCRIPT_DIR
fi

