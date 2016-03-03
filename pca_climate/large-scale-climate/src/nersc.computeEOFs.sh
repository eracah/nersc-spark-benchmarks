#!/bin/bash
# Computes the 3D EOFs using CSFR dataset
# You need to change the memory setting and location of the data for different platforms

NCPUS=$1
NPARTS=$2
EXMEM=$3
NUMEOFS=$4

DIR="$(cd "`dirname "$0"`"/..; pwd)"
LOGDIR="$DIR/eventLogs"
DATADIR="$DIR/data"
JARNAME=$5


INSOURCE=$SCRATCH/CFSROparquet

NUMROWS=46715
NUMCOLS=6349676
PREPROCESS="centerOverAllObservations"

JOBNAME="eofs-$PREPROCESS-$NUMEOFS"
OUTDEST="$DATADIR/$JOBNAME.bin"
LOGNAME="$JOBNAME.log"

UNCP_SPARK_DIRS_FILE=$SCRATCH/spark/unproceesed_pca_worker_dirs.txt
[ -e $OUTDEST ] && (echo "Job already run successfully, stopping"; exit 1)


spark-submit --verbose \
  --master $SPARKURL \
  --driver-memory 70G \
  --executor-memory $EXMEM \
  --total-executor-cores $NCPUS \
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=$SPARK_LOG_DIR \
  --conf spark.driver.maxResultSize=30G \
  --conf spark.task.maxFailures=4 \
  --conf spark.worker.timeout=1200000 \
  --conf spark.network.timeout=1200000 \
  --conf spark.default.parallelism=$NPARTS \
  --conf spark.speculation=true \
  --jars $JARNAME \
  --class org.apache.spark.mllib.climate.computeEOFs \
  $JARNAME \
  $INSOURCE $NUMROWS $NUMCOLS $PREPROCESS $NUMEOFS $OUTDEST \
  2>&1 | tee $LOGNAME

event_log_name=`ls $SPARK_LOG_DIR | grep "app"`
ln -s $SPARK_LOG_DIR/$event_log_name $LOGDIR/$event_log_name
echo $SPARK_WORKER_DIR >> $UNCP_SPARK_DIRS_FILE
