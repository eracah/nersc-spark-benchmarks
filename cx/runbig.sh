#!/bin/bash -l

DIRNAME=`dirname $0`
SIZE="1T"

NCPUS=$1
RANK=$2
SLACK=$3
NITERS=$4
NPARTS=$5
LOGDIR=$6
EXMEM=$7
DES_LOG_DIR=$8
SCRIPT_DIR=$9
NUM_NODES=`cat /var/hostsfile | uniq | wc -l`

#if [ ! -d $DES_LOG_DIR ]
#then
#    mkdir $DES_LOG_DIR
#fi
#export SCRIPTDIR=/project/projectdirs/paralleldb/spark/benchmarks/cx
#export LOGDIR=$SPARK_WORKER_DIR/sparklogs
#mkdir -p $LOGDIR


if [ $NERSC_HOST == "edison" ]
then
MEMPERNODE=64
else
MEMPERNODE=120
fi

TOT_MEM=$((($NUM_NODES-1) * $MEMPERNODE ))
TOT_MEM="$TOT_MEM"G

#grab every directory in spark_local_dirs
n=`echo "$SPARK_LOCAL_DIRS" | sed 's/,/ /g' | wc -w`
extra_info=''
for i in `seq 1 $n`; do extra_info=$extra_info-`echo "$SPARK_LOCAL_DIRS" | sed 's/\// /g' | cut -d ',' -f $i | awk '{ print $1 }'` ; done

start-all.sh
LOGNAME=$NERSC_HOST-cx-$extra_info-$SIZE-$NCPUS-$RANK-$SLACK-$NITERS-$NPARTS-$EXMEM-$TOT_MEM-default.log
(time -p spark-submit --verbose \
  --name $EXMEM"G-executor-mem"$TOT_MEM"G-tot-mem" \
  --total-executor-cores $NCPUS\
  --conf spark.eventLog.enabled=true \
  --conf spark.eventLog.dir=$LOGDIR \
  --executor-memory $EXMEM'G' \
  --master $SPARKURL \
  --driver-memory 80G \
  --conf spark.driver.maxResultSize=32g \
  --conf spark.speculation=true \
  --conf spark.task.maxFailures=4 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  $SCRIPT_DIR/src/heromsi-assembly-0.0.1.jar \
  df \
  file://$SCRATCH/cx/data_1_stripe/Lewis_Dalisay_Peltatum_20131115_hexandrum_1_1-smoothed-mz=437.11407-sd=0.05.mat.df \
  0 0 \
  $LOGDIR/cx-out-$SIZE-$NCPUS-$RANK-$SLACK-$NITERS-$NPARTS-$EXMEM.json \
  $RANK $SLACK $NITERS $NPARTS ) 2>&1 | tee $LOGDIR/$LOGNAME

stop-all.sh

#get name of event log and change it to name of driver log, which was named properly
regex="app-[0-9]*-[0-9]*"
log_text=`head -300 $LOGDIR/$LOGNAME`
[[ $log_text =~ $regex ]]
name="${BASH_REMATCH[0]}"
echo $name
edited_name=`echo $LOGNAME | sed s/.log//g`
final_name=`echo "$edited_name-$name" | sed s/--/-/g`
mv $LOGDIR/$name $LOGDIR/$final_name
cp $LOGDIR/$final_name $DES_LOG_DIR


