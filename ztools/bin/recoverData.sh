#!/bin/bash

db2 connect to $DB_NAME user $DB_USER using $DB_PASS;
db2 set current schema $DB_SCHEMA;
tbl=`db2 connect to $DB_NAME user $DB_USER using $DB_PASS 1>/dev/null 2>&1;\
db2 set current schema $DB_SCHEMA 1>/dev/null 2>&1;\
db2 list tables for schema $DB_SCHEMA | egrep '\sT\s' | egrep '^BOOK_|^YSPZ_|JZPZ|TBL_CO_CERT' | awk '{print $1;}'`;

# 删除所有账薄，原始凭证，记账凭证，待审核记录表
for file in $tbl; do
    db2 "delete from $file";
    #echo $file;
done;


# 删除所有load_mission
db2 "delete from load_mission";

# 删除所有load_job
db2 "delete from load_job";

# 删除所有对账任务
db2 "delete from job_dz";


# 将所有sequence从1开始
declare -u up_schma;
up_schma="$DB_SCHEMA";
seq=`db2 connect to $DB_NAME user $DB_USER using $DB_PASS 1>/dev/null 2>&1;\
db2 set current schema $DB_SCHEMA 1>/dev/null 2>&1;\
db2 -x "select seqname,seqtype from syscat.sequences where seqschema='$up_schma' and seqtype='S'" | awk '{ print $1 }'`;

for f in $seq; do
    db2 "alter sequence $f restart with 1";
    #echo $f;
done;


# 删除所有批导文件
datdir="$ZIXAPP_HOME/data";
cd $datdir;
for dir in `ls $datdir`; do
    #echo $dir;
    rm -rf $dir;
done;

