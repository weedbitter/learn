#!/bin/bash

db2 connect to zdb user ypinst using ypinst;

for table in  `cat table.list`; do
    echo $table;
    db2 "export to $table.del of del select * from $table";
    mv $table.del ./$1
done
