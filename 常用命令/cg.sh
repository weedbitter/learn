#!bin/bash

for file in `ls *.dat`; do  cat $file | sed "s/0088/0111/g" > $file-da;done

for file in `ls *.dat-da`; do  mv $file `echo $file | sed "s/dat-da/dat/g"` ; done
