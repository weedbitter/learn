#!/bin/bash

#
# 导入测试字典数据
#

db2 connect to $DB_NAME user $DB_USER using $DB_PASS;
db2 set current schema $DB_SCHEMA;


for file in `ls *.del`; do
    name=`echo ${file##/*/}`;
    tbl=`echo ${name%%.*}`;
    db2 "import from $name of del replace into $tbl";
done;
