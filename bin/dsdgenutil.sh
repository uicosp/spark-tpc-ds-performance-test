#!/bin/bash

function move() {
    dats=$(ls -lh | grep '.dat')

    echo 'moving .dat files...'
    echo "$dats" | while read -r line;
    do
      file_name=$(echo $line | tr -s " " " " | cut -d " " -f9)
      dir_name=${file_name%.dat}
      mkdir $dir_name
      mv $file_name $dir_name
      echo "mv ${file_name} to ${dir_name}"
    done
    echo 'done'
}

function generate() {
  dir=$1
  scale=$2
  parallel=$3

  for num in `seq 1 $parallel`
  do
    nohup ./dsdgen -scale ${scale} -dir ${dir} -parallel ${parallel} -child ${num} > child_${num}.out 2>&1 &
  done
}

function main() {
  word_dir=$1
  mode=$2
  shift
  shift
  cd $word_dir || exit
  case "$mode" in
    "move")  move ;;
    "generate")  generate "$@" ;;
     * )  echo "invalid option" ;;
  esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"