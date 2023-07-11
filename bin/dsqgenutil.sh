#!/bin/bash
work_dir=$1
out_dir=$2
scale=$3

cd $work_dir || exit

for i in `seq 1 99`
do
  num=`printf "%02d\n" $i`
  ./dsqgen -DIRECTORY ../query_templates -TEMPLATE "query${i}.tpl" -DIALECT netezza -scale $scale -FILTER Y > "${out_dir}/query${num}.sql"
done
