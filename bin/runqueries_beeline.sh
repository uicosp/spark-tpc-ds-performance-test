#!/bin/bash

current_dir=$(dirname "$0")

BEELINE=$1
OUTPUT_DIR=$2
TPCDS_DBNAME=$3
SPARK_HISTORY_SERVER=$4
RM_HTTP_ADDRESS=$5
CONTINUE_I=$6

beeline=${BEELINE/\/default\;/\/${TPCDS_DBNAME}\;}

divider===============================
divider=$divider$divider$divider$divider$divider
header="\n %-10s %11s %11s %11s %11s %11s %12s %10s %10s\n"
format=" %-10s %11.2f %11.2f %11.2f %11.2f %11.2f %12d %10d %10d\n"
width=106
if [ -z "$CONTINUE_I" ]; then
  printf "$header" "Query" "Time(secs)" "Read(secs)" "Write(secs)" "Read(GB)" "Write(GB)" "Memory" "Vcore" "Rows"> ${OUTPUT_DIR}/run_summary.txt
  printf "%$width.${width}s\n" "$divider" >> ${OUTPUT_DIR}/run_summary.txt
fi
for i in `cat ${OUTPUT_DIR}/runlist.txt`;
do
  if [ -n "$CONTINUE_I" ] && [ "$i" -lt "$CONTINUE_I" ]; then
    continue
  fi
  num=`printf "%02d\n" $i`
  $beeline -f ${OUTPUT_DIR}/query${num}.sql > ${OUTPUT_DIR}/query${num}.res 2>&1
  app_id_row=`cat ${OUTPUT_DIR}/query${num}.res | grep 'application ID' -m 1`
  app_id=`echo $app_id_row | tr -s " " " " | cut -d " " -f3`
  echo "query${num} app_id=${app_id}"
  result=`python ${current_dir}/spark_metrics.py $SPARK_HISTORY_SERVER $RM_HTTP_ADDRESS $app_id`
  lines=`cat ${OUTPUT_DIR}/query${num}.res | grep -E "row(s)? selected" | tail -n 1`
  echo "$lines" | while read -r line;
  do
    time=`echo $result | tr -s " " " " | cut -d " " -f1`
    shuffle_read_time=`echo $result | tr -s " " " " | cut -d " " -f2`
    shuffle_write_time=`echo $result | tr -s " " " " | cut -d " " -f3`
    shuffle_read_gb=`echo $result | tr -s " " " " | cut -d " " -f4`
    shuffle_write_gb=`echo $result | tr -s " " " " | cut -d " " -f5`
    memory=`echo $result | tr -s " " " " | cut -d " " -f6`
    vcore=`echo $result | tr -s " " " " | cut -d " " -f7`
    num_rows=`echo $line | tr -s " " " " | cut -d " " -f1`
    num_rows=${num_rows//,/} # remove ","
    printf "$format" \
       query${num} \
       $time \
       $shuffle_read_time \
       $shuffle_write_time \
       $shuffle_read_gb \
       $shuffle_write_gb \
       $memory \
       $vcore \
       $num_rows >> ${OUTPUT_DIR}/run_summary.txt
  done

done
touch ${OUTPUT_DIR}/queryfinal.res