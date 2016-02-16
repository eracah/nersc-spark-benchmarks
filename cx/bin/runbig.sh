#!/bin/bash -l

DIRNAME=`dirname $0`
SIZE="1T"

NCPUS=$1
RANK=$2
SLACK=$3
NITERS=$4
NPARTS=$5
EXMEM=$6
SCRIPT_DIR=$7 
#NUM_NODiES=`cat /var/hostsfile | uniq | wc -l`

UNCP_SPARK_DIRS_FILE=$SCRATCH/spark/unproceesed_worker_dirs.txt

#write the setting of spark_local_dirs to file b/c this info is usually lost
#echo $SPARK_LOCAL_DIRS > $SPARK_LOG_DIR/spark_local_dirs.txt


start-all.sh
spark-submit --verbose \
  --name "CX" \
  --total-executor-cores $NCPUS\
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=$SPARK_LOG_DIR \
  --executor-memory $EXMEM'G' \
  --master $SPARKURL \
  --driver-memory $EXMEM'G' \
  --conf spark.driver.maxResultSize=32g \
  --conf spark.speculation=true \
  --conf spark.task.maxFailures=4 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  $SCRIPT_DIR/src/heromsi-assembly-0.0.1.jar \
  df \
  file://$SCRATCH/cx/data_1_stripe/Lewis_Dalisay_Peltatum_20131115_hexandrum_1_1-smoothed-mz=437.11407-sd=0.05.mat.df \
  0 0 \
  $LOGDIR/cx-out-$SIZE-$NCPUS-$RANK-$SLACK-$NITERS-$NPARTS-$EXMEM.json \
  $RANK $SLACK $NITERS $NPARTS  2>&1 | tee $LOGDIR/$LOGNAME

stop-all.sh

#add to list of unprocessed spark dirs
echo $SPARK_WORKER_DIR >> $UNCP_SPARK_DIRS_FILE 
