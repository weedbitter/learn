#!/bin/bash

date= $1;
db2 connect to $DB_NAME user $DB_USER using $DB_PASS;
db2 set current schema $DB_SCHEMA;



for table in  `cat table.list`; do
    echo $table;
    db2 "import from $date/$table.del of del replace into $table";
done
