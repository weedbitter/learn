export ZTOOLS_HOME=~/workspace/ztools
export ZIXAPP_HOME=~/workspace/zixapp
export PERL5LIB=$ZTOOLS_HOME/lib:PERL5LIB
export PATH=$ZTOOLS_HOME/bin:$ZTOOLS_HOME/libexec:$PATH
export ZTOOLS_DEBUG=1;

export DB_NAME=zdb_dev
export DB_USER=ypinst
export DB_PASS=ypinst
export DB_SCHEMA=ypinst

export ODB_NAME=zdb
export ODB_USER=ypinst
export ODB_PASS=ypinst
export ODB_SCHEMA=zdb_cain
alias dbc='db2 connect to $DB_NAME user $DB_USER using $DB_PASS'




