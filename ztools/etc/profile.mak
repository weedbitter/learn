export ZTOOLS_HOME=~/workspace/ztools
export ZIXAPP_HOME=~/workspace/zixapp
export PERL5LIB=$ZTOOLS_HOME/lib:PERL5LIB
export PATH=$ZTOOLS_HOME/bin:$ZTOOLS_HOME/libexec:$PATH
export ZTOOLS_DEBUG=1;

export DB_NAME=zdb_dev
export DB_USER=db2inst
export DB_PASS=db2inst
export DB_SCHEMA=db2inst

export ODB_NAME=zdb
export ODB_USER=db2inst
export ODB_PASS=db2inst
export ODB_SCHEMA=zdb_dev
alias dbc='db2 connect to $DB_NAME user $DB_USER using $DB_PASS'




