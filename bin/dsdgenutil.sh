#!/bin/bash
word_dir=$1
cd $word_dir || exit

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