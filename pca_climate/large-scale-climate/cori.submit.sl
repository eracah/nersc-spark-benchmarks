#!/bin/bash
#SBATCH -p regular 
#SBATCH -N 50
#SBATCH -t 5:00:00
#SBATCH --qos=premium 
#SBATCH --ccm
#SBATCH -o slurm-outputs/cori-spark-%j.out
#SBATCH -e slurm-outputs/cori-spark-%j.err

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
    -p|--partitions)
    PARTS=$2
    shift
    ;;
    --collectl)
    USE_COLLECTL=TRUE
    ;;
    -v|--spark-version)
    VERSION=$2
    shift
    ;;
    *)
            # unknown option
    ;;
esac
shift
done

def_rank=20
def_exmem=80G
def_total_cores=400
def_partitions=30000
def_version=1.5.1
exmem=${EXMEM:-$def_exmem}
rank=${RANK:-$def_rank}
total_cores=${CORES:-$def_total_cores}
nparts=${PARTS:-$def_partitions}
version=${VERSION:-$def_version}
echo "I was called with"  exmem $exmem rank $rank total_cores $total_cores npartitions $nparts version $version


module load spark/$version
export SPARK_LOCAL_DIRS="/tmp,/dev/shm"

echo SPARK_LOCAL_DIRS is $SPARK_LOCAL_DIRS


#/project/projectdirs/paralleldb/spark/benchmarks/pca_climate/large-scale-climate/tmp_checker.script &
start-all.sh
module load collectl
start-collectl.sh
INDIR=/project/projectdirs/paralleldb/spark/benchmarks/pca_climate/large-scale-climate

cd $INDIR
echo calling src/nersc.computeEOFs.sh $total_cores $nparts $exmem $rank $INDIR/target/scala-2.10/large-scale-climate-assembly-0.0.1.jar
src/nersc.computeEOFs.sh $total_cores $nparts $exmem $rank $INDIR/target/scala-2.10/large-scale-climate-assembly-0.0.1.jar

stop-all.sh

stop-collectl.sh

