#!/bin/bash -l

exmem=$1
DES_LOG_DIR=$2
NCPUS=$3
if [ ! -d $DES_LOG_DIR ]; then
    mkdir $DES_LOG_DIR
fi

ls -l /var/shifterConfig.json


module load spark/1.5.1

#export SPARK_CONF_DIR=/project/projectdirs/paralleldb/spark/benchmarks/cx/log4j.properties

export SCRIPTDIR=/project/projectdirs/paralleldb/spark/benchmarks/cx
export LOGDIR=$SPARK_WORKER_DIR/sparklogs
mkdir -p $LOGDIR


#if [ -r  /var/shifterConfig.json ] ; then
bash $SCRIPTDIR/runbig.sh $NCPUS 16 0 5 ""   $LOGDIR $exmem $DES_LOG_DIR $SCRIPTDIR
#else
#    echo not in shifter image
#    module load shifter
#    shifter --image=local:/  $SCRIPTDIR/runbig.sh $NCPUS 16 0 5 ""   $LOGDIR $exmem $DES_LOG_DIR $SCRIPTDIR
#fi
