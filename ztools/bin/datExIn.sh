#!/bin/bash

#
#  environment variable needed
#
#
#

if [[ "x$DB_USER" == "x"  || "x$DB_PASS" == "x" || "x$DB_NAME" == "x" || "x$DB_SCHEMA" == "x" || "x$ZTOOLS_HOME" == "x" ]]; then
   echo "environment insufficient";
   exit -1;
fi
. $HOME/sqllib/db2profile

bakdir=$ZTOOLS_HOME/tmp/data;      #
dir=`date +%Y%m%d`;         #
#dir="20130527";         #
bdir=$bakdir/$dir;          #
fsta=$bdir/.export;         #
fseq=$bdir/seq.dat;         #
fdsta=$bdir/.download;      #
mkdir -p $bdir;
touch $fsta;
touch $fseq;
touch $fdsta;

#
#  1  : export failed
#  2  : export success
#
#
#  3 : import failed;
#  4 : import success;
#
#  5 : download failed;
#  

function export_all {

  stat=`cat $fsta`;
  if [ "x$stat" == 'x2' ]; then
     return 0; 
  fi;

  # 连接数据库
  db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
  if [ $? != 0 ]; then
     echo "1" > $fsta; 
     return 1;
  fi
  db2 set current schema $DB_SCHEMA > /dev/null 2>&1;

  echo "begin export tables...";
  export_table;
  if [ $? != 0  ]; then
     echo "1" > $fsta; 
     return 2;
  fi
  echo "end export tables succeeded";

  echo "begin export sequences";
  export_seq;
  if [ $? != 0  ]; then
     echo "end export sequences [$?]";
     echo "1" > $fsta; 
     return 3;
  fi
  echo "end export sequences succeeded";

  echo "begin export sum tables...";
  export_sum;
  if [ $? != 0  ]; then
     echo "1" > $fsta; 
     return 2;
  fi
  echo "end export sum tables succeeded";
 
  return 0;
}

function export_table {
  db2 list tables for schema $DB_SCHEMA  | egrep '\sT\s'  | awk '{ print $1; }' | 
  (
      db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
      db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
      while read tbl; do
        db2 "export to $bdir/$tbl.ixf of ixf lobs to $bdir select * from $tbl" > /dev/null 2>&1;
        if [ $? != 0 ]; then
           echo "export $tbl failed";
           exit -1;
        fi
      done;
  );

  return $?;
}

# 导出sum表(mqt)
function export_sum {
  db2 list tables for schema $DB_SCHEMA  | egrep '\sS\s'  | awk '{ print $1; }' | 
  (
      db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
      db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
      while read tbl; do
        db2 "export to $bdir/$tbl.ixf of ixf select * from $tbl" > /dev/null 2>&1;
        if [ $? != 0 ]; then
           echo "export $tbl failed";
           exit -1;
        fi
      done;
  );

  return $?;
}

function export_seq {

  declare -u up_schma;
  up_schma="$DB_SCHEMA";

  > $fseq;
   
  db2 -x "select seqname,seqtype from syscat.sequences where seqschema='$up_schma' and seqtype='S'" | awk '{ print $1 }' |
  ( 
      db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
      db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
      while read seq; do
        id=$(db2 -x "select nextval for $seq from sysibm.sysdummy1");
        echo "$seq  $id"  >> $fseq;
        if [ $? != 0 ]; then
           echo "export $seq failed";
           exit -1;
        fi
      done;
  );
  return $?;
}

function import_all {

  stat=`cat $fsta`;
  # 状态为4, 那么认为已经成功。
  if [ "x$stat" == 'x4' ]; then
    return 0;
  fi;
  # 状态不为2、3、4，那么认为失败
  if [[ "x$stat" != 'x2' && "x$stat" != 'x3' ]]; then
    return 1; 
  fi;

  # 连接数据库
  db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
  if [ $? != 0 ]; then
    echo "3" > $fsta; 
    return 1;
  fi
  db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
  if [ $? != 0 ]; then
    echo "3" > $fsta; 
    return 2;
  fi

  echo "beg import tables";
  import_table;
  if [ $? != 0 ]; then
    echo "3" > $fsta; 
    return 2;
  fi
  echo "end import tables succeeded";

  echo "beg import seq";
  import_seq;
  if [ $? != 0 ]; then
    echo "3" > $fsta; 
    return 3;
  fi
  echo "end import seq succeeded";

}


function import_table {
  # 删除mqt关联
  DBM.pl -t del_mqt;
  if [ $? != 0 ]; then
    echo "del mqt failed";
    return $?;
  fi
  echo "del mqt succeed";
  
  db2 list tables for schema $DB_SCHEMA  | egrep '\sT\s'  | awk '{ print $1; }' | 
  (
      db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
      db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
      while read tbl; do
        if [ ! -f $bdir/$tbl.ixf ]; then
          continue;
        fi;
        db2 "import from $bdir/$tbl.ixf of ixf lobs from $bdir replace into $tbl" > /dev/null 2>&1;
        if [ $? != 0 ]; then
           echo "import $tbl failed";
           exit -1;
        fi
      done;
  );
  ret=$?;
  # 重新关联mqt
  DBM.pl -t add_mqt;
  if [ $? != 0 ]; then
    echo "add mqt failed";
    return $?;
  fi
  echo "add mqt succeed";

  return $ret;
}



#function import_refresh_sum {
#    db2 list tables for schema $DB_SCHEMA | egrep '\sT\s' | egrep '^BOOK_' |
#    (
        
#    );
#}


function import_seq {
  declare -u up_schma;
  up_schma="$DB_SCHEMA";
   
  cat $fseq | (

     db2 connect to $DB_NAME user $DB_USER using $DB_PASS > /dev/null 2>&1;
     db2 set current schema $DB_SCHEMA > /dev/null 2>&1;
     
     while read line; do 
       name=`echo $line | awk '{ print $1; }'`;
       val=`echo $line  | awk '{ print $2; }'`;
       db2 "alter sequence $name restart with $val" > /dev/null 2>&1;
       if [ $? != 0 ]; then
         echo "alter sequence $name failed";
         exit -1;
       fi
    done
  )
  return $?
}

#  1 下载失败
#  2 下载成功
# 下载备份数据
function download {
  sta=`cat $fdsta`;
  if [ "x$sta" == "x2" ]; then
    return 0;
  fi;
  echo "beg download backup file";
  scp -P9000 -r acct@113.240.223.82:$bakdir/$dir  $bakdir
  return $?;
}

################################################################
#  main
################################################################

if [ "xexport" == "x$1" ]; then

  export_all;
  if [ $? != 0 ]; then
    echo "export failed";
    echo "1" > $fsta;
    exit -1; 
  fi
  echo "2" > $fsta; 
  echo "2" > $fdsta;
  echo "export succeeded";
  exit 0;

elif [ "ximport" == "x$1" ]; then
  sta=`cat $fdsta`;
  if [ "x$sta" != 'x2' ]; then
    echo "import failed, because download failed";
    echo "3" > $fsta;
    exit -1;
  fi;
  import_all;
  re=$?;
  if [ $re != 0 ]; then
    echo "import failed";
    echo "3" > $fsta; 
    exit -1;
  fi
  echo "3" > $fsta;
  echo "import succeeded"; 
  exit 0;

elif [ "xdownload" == "x$1" ]; then
  download;
  if [ $? != 0 ]; then
    echo "download failed";
    echo "1" > $fdsta;
    exit -1;
  fi
  echo "2" > $fdsta;
  echo "download succeeded";
  exit 0;
else
  echo "unsupported command";
  exit 0;
fi


