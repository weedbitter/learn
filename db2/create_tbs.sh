#!/bin/bash
db2 connect to zdb_dev user db2inst using db2inst;
DMS="managed by database";  
STMP_TBSP="temporary tablespace";
UTMP_TBSP="user temporary tablespace";
LARG_TBSP="large tablespace";
NFSC="no file system caching";

db2 "create $LARG_TBSP tbs_dat pagesize 32k $DMS using(FILE '/db2tbsp/dat_1' 2048M) bufferpool bp32k $NFSC";
db2 "create $LARG_TBSP tbs_idx pagesize 32k $DMS using(FILE '/db2tbsp/idx_1' 1024M) bufferpool bp32k $NFSC";
db2 "create $STMP_TBSP tbs_tmp pagesize 32k $DMS using(FILE '/db2tbsp/tmp_1' 1024M) bufferpool bp32k $NFSC";
db2 "create $UTMP_TBSP tbs_utmp pagesize 32k $DMS using(FILE '/db2tbsp/utmp_1' 1024M) bufferpool bp32k $NFSC";
db2 "create $LARG_TBSP tbs_long pagesize 32k $DMS using(FILE '/db2tbsp/long_1' 1024M) bufferpool bp32k $NFSC"

