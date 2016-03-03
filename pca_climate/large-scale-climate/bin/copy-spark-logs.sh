#!/bin/bash -l
#This script goes through all unprocessed worker-dirs from finished  spark apps and copies over the event logs, executor logs and collectl logs to central location

export basedir=/project/projectdirs/paralleldb/spark/benchmarks/pca_climate/
for dir in $(cat $SCRATCH/spark/unproceesed_pca_worker_dirs.txt)
do
slurm_job_id=`basename $dir`
#copy event logs to one place
cp $dir/sparklogs/app* $basedir/event_logs

#tar up executor logs and put somewhere central 
cd $dir
tar -zcvf ./$slurm_job_id".tgz" ./app*/*/stderr
cp ./$slurm_job_id".tgz" $basedir/executor_logs
rm ./$slurm_job_id".tgz"

#tar up collectl logs and put somewhere central
tar -zcvf ./$slurm_job_id".tgz" ../$slurm_job_id/collectl_logs
cp ./$slurm_job_id".tgz"  $basedir/collectl_logs
done

#remove the worker_dirs text file b/c these are now processed
rm $SCRATCH/spark/unproceesed_pca_worker_dirs.txt
