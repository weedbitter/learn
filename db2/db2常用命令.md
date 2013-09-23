DB2常用命令汇总之一 

db2 -tvf my.sql

db2level 显示db2的版本号

显示SQL出错信息
db2 "? sql6031"

db2mtrk

管理DAS
产生：root运行－dascrt -u dasuser1
删除：root运行－dasdrop
启动：dasusr1运行－db2admin start
停止：dasusr1运行－db2admin stop

db2_kill
ipclean

db2start dbpartitionnum 9 restart

AIX启动控制中心：
db2cc

DB2用户管理：
  db2 use os to manage users.You can use following steps to add a db2 user:
  1,add a user on os.
  2,grant rights to user.
    GRANT  CREATETAB,CONNECT ON DATABASE  TO USER FUJIE;
    grant select, update, delete on table employee to user john with grant option

一，实例

产生
db2icrt -a AuthType(SERVER,CLIENT,SERVER_ENCRYPT) -p PORT_NAME
表空间PREFETCHSIZE的设置，EXTENTSIZE的关系，缓冲池的监控，页清除程序的多少。
   临时表空间页面大小与其他表空间页面大小的设置，临时表空间与缓冲池的设置。
example:db2icrt db2 -s ese -p d:/db2 -u Administrator

注意：在UNIX 上产生实例时需要产生一个和实例名称相同的用户名，和fencedid 用户。
  如：db2icrt -s ese -u db2fenc2 db2inst2 将在db2inst2用户中产生实例db2inst2.

缺省创建32位实例，创建64位实例：db2icrt -s ese -w 64 -u db2fenc2 db2inst2
  
删除
db2idrop instance-name
启动
db2start
停止
db2stop force
连接
db2 attach to testdb2
db2 detach
列出实例
db2ilist
设置当前实例
set db2instance=<instance-name>
得到当前实例
db2 get instance
设置实例自动重启动UNIX
db2iauto -on <instance-name>
db2iauto -off <instance-name>

获取实例的配置参数
db2 get dbm cfg
修改配置参数
例如:db2 update dbm cfg using authentication server_encrypt
     db2stop and db2start
    
二,声明注册表和环境变量
db2set   注意：设置完成后需要退出用户，再注册进入才能生效。
列出所有受支持的变量
db2set -lr
列出当前实例所有已定义的变量
db2set
要列出概要文件注册表中所有定义的注册表变量
db2set -all
列出单个变量
db2set registry_variable_name
更改变量
db2set registry_variable_name=new_value
变量复位为缺省值
db2set -r registry_variable_name

db2set DB2CODEPAGE=819

db2set DB2CODEPAGE=1386

db2 -tvf my_sql.sql

三,创建节点配置文件
db2nodes.cfg

UNIX 格式:dbpartitionnum(0-999) hostname [logical-port [netname]]
WIN  格式:nodenumber hostname computername logical_port netname

四,管理服务器
<配置助手,控制中心,开发中心> 通过DAS来进行工作
创建DAS
db2admin create (windows)
dascrt -u <DASUser>  需要root权限
启动和停止
db2admin start
db2admin stop
列出
db2admin
配置DAS
db2 get admin cfg
db2 update admin cfg using
db2 reset admin cfg
最好stop再start
五,配置多个逻辑节点
可以用两个方法来配置多个逻辑节点:
* 在db2nodes.cfg文件中配置逻辑节点(数据库分区).然后,可使用db2start启动所有逻辑和远程节点.
    对于windows nt,若系统中没有数据库,则必须使用db2ncrt来添加节点,否则,若一个或多个数据库,
    则应使用db2start addnode 命令.在nt 中,不能手工编辑db2nodes.cfg文件.
   db2ncrt /n:1 /u:administrator,yhnu0987 /m:fujie /p:1 /h:fujie
   db2start addnode nodenum 1 hostname guosd port 1 computer GUOSD user db2admin password db2admin

* 在另一个处理器上重新启动一个逻辑节点,其他逻辑数据库分区(节点)已在该处理器上运行.这允许覆盖
  在db2nodes.cfg中为逻辑数据库分区指定的主机名和端口号.
 

在WIN中添加逻辑节点
  db2ncrt /n:1 /u:Administrator,<pwd> /i:db2 /m:FUJIE /p:1
 
#删除逻辑节点
db2ndrop
有数据库的时候使用db2stop drop nodenum
#改变逻辑节点
db2nchg


DB2常用命令汇总之二

六,创建数据库
创建数据库时,完成如下任务:
* 设置数据库所需的所有系统目录表
* 分配数据库恢复日志
* 创建数据库配置文件,设置缺省值
* 将数据库实用程序与数据库绑定

初始数据库分区组的定义
当最初创建数据库时,会为所有在db2nodes.cfg文件中指定的分区创建数据库分区.可以用
add dbpartitionnum 和 drop dbpartitionnum verify 命令来添加或除去其他分区.
定义了三个数据库分区组:
         * 用于容纳syscatspace表空间的ibmcatgroup, 保存系统目录表
         * 用于容纳tempspaces1表空间的ibmtempgroup,保存系统临时表
* 用于容纳userspace1表空间的ibmdefaultgroup,缺省保存用户表和索引

(创建新的数据库后最好重新启动db2clp)

EXAMPLE:
CREATE DATABASE PERSONL
   CATALOG TABLESPACE
     MANAGED BY SYSTEM USING (path 'D:/PCATALOG','E:/PCATALOG')
     EXTENTSIZE 16 PREFETCHSIZE 32
   USER TABLESPACE
     MANAGED BY DATABASE USING (FILE 'D:/DB2DATA/PERSION1' 5000,
                                FILE 'D:/DB2DATA/PERSION2' 5000)
     EXTENSIZE 32 PREFETCHSIZE 64
   TEMPORARY TABLESPACE
     MANAGED BY SYSTEM USING (path 'F:/DB2TEMP/PERSONL')
   WITH "PERSONNEL DB FOR DSCHIEFER CO"

create database sccrm using codeset GBK territory CN

#删除数据库
   DROP DATABASE <DB-NAME>
  

# 数据库目录的定义
  *本地数据库目录(节点的目录中的文件SQLDBDIR)
     本地数据库目录文件存在于定义了数据库的每条路径(或WIN中的"驱动器")
     对于可以从该位置存取得每个数据库此目录都包含一个条目.包含信息:
      数据库名称,数据库别名,数据库注释,数据库的根目录的名称,其他系统信息.
  *系统数据库目录(实例中的目录中的文件SQLDBDIR)
     对于数据库管理器的每个实例,都存在一个系统数据库目录文件,该文件对于针对
     此实例编目的每个数据库都包含一个条目.使用CREATE DATABASE时隐式的编目数据库
     每个数据库包含一条信息: 数据库名,数据库别名,数据库注释,本地数据库目录的位置,
      指示该数据库是间接的指示符,表示它与系统数据库目录文件驻留在相同的机器上.
查看本地或系统数据库目录文件
   LIST DATABASE DIRECTORY ON <location>
   LIST DATABASE DIRECTORY
  
  *节点目录
     数据库管理器在编目第一个数据库分区时会创建节点目录.要编目数据库分区,
     使用CATALOG NODE命令.要显示本地节点目录的内容,使用LIST NODE DIRECTORY
     .在每个数据库客户机上都创建并维护节点目录.对于具有客户机可以存取得一个
     或多个数据库的每个远程工作站,该目录都包含一个条目.db2客户机使用该节点目录中
     的通信端点信息.
     catalog tcpip node my_node_name remote 10.10.10.10 server 54321
uncatalog node my_node_name
     catalog database DB as my_data_alias at node my_node_name
# "轻量级目录访问协议" (LDAP)目录服务
    目录服务是一个关于分布式环境中的多个系统和服务的资源信息的资源库;它
    提供对这些资源的客户机和服务器存取.客户机和服务器将使用目录服务来找出
    如何存取其他资源.
    LDAP是业界标准的存取目录服务的方法.每个数据库服务器实例都会将它的存在情况发布给LDAP,
    并在创建数据库时向LDAP目录提供数据库信息.当客户机与数据库连接后,可从LDAP目录检索
    服务器的目录信息.不再要求每个客户机将目录信息以本地方式存储在每台机器上.

# 创建数据库分区组
    可以使用CREATE DATABASE PARTITION GROUP语句创建数据库分区组.此语句指定表空间
    容器和表数据将驻留其上的一组数据库分区.
      *为数据库分区组创建分区映象.
      *生成分区映象标识
      *将记录插入下列目录表:
       SYSCAT.DBPARTITONGROUPS,SYSCAT.PARTITIONMAPS,SYSCAT.DBPARTITIONGROUPDEF

   CREATE DATABASE PARTITION GROUP <name> ON DBPARTITIONNUMS (<value>,<value>)
 
#创建表空间
表空间建立数据库系统使用的物理存储设备与用来存储数据的逻辑容器或表的关系

CREATE TABLESPACE <name>
    MANAGED BY SYSTEM
    USING ('<path>')
   
CREATE TABLESPACE <name>
    MANAGED BY DATABASE
    USING (FILE'<path>' <size>)
           DEVICE
*指定分区组
CREATE TABLESPACE PLANS IN ODDNODEGROUP
    MANAGED BY DATABASE
    USING (DEVICE '/dev/HDISK0' 10000,DEVICE '/dev/n1hd01' 40000) on node 1
        (DEVICE '/dev/HDISK0' 10000,DEVICE '/dev/n1hd03' 40000) on node 3
        (DEVICE '/dev/HDISK0' 10000,DEVICE '/dev/n1hd05' 40000) on node 5 

CREATE  REGULAR  TABLESPACE CUSTTBS IN DATABASE PARTITION GROUP CUSTOMER
PAGESIZE 4 K  MANAGED BY DATABASE  USING
( FILE 'D:/testdbtbs/custtbs0_1' 5120 ) ON DBPARTITIONNUM (0)
USING
( FILE 'D:/testdbtbs/custtbs1_1' 5120 ) ON DBPARTITIONNUM (1)
EXTENTSIZE 16 OVERHEAD 10.5 PREFETCHSIZE 16
 
   在多分区数据库中创建单分区组.
   CREATE DATABASE PARTITION GROUP single_tbs_grp ON DBPARTITIONNUM(0)
   在单分区组中创建单分区表空间.
   CREATE TABLESPACE single_part_tbs IN DATABASE PARTITION GROUP single_tbs_grp
   MANAGED BY DATABASE USING (FILE 'd:/testdbtbs/single_part_tbs_1' 5120)
  
  在UNIX中使用字符设备.
 
* 创建特定类型的表空间
  创建系统临时表空间
  CREATE SYSTEM TEMPORARY TABLESPACE tmp_tbsp
   MANAGED BY SYSTEM
   USING ('d:/tmp_tbsp','e:/tmp_tbsp')
  
   在分区数据库中创建系统临时表空间 只能在IBMTEMPGROUP中产生
   CREATE  SYSTEM TEMPORARY  TABLESPACE TEMPSYS_TBSP1
    IN DATABASE PARTITION GROUP IBMTEMPGROUP
    PAGESIZE 4 K  MANAGED BY SYSTEM 
    USING ('D:/testdbtbs/sys_temp_0' ) ON DBPARTITIONNUM (0)
    USING ('d:/testdbtbs/sys_temp_1' ) ON DBPARTITIONNUM (1)
    EXTENTSIZE 16 OVERHEAD 10.5 PREFETCHSIZE 16
  创建用户临时表空间
   CREATE USER TEMPORARY TABLESPACE usr_tbsp
    MANAGED BY DATABASE
    USING (FILE 'd:/db2data/user_tZbsp' 5000,
           FILE 'e:/db2data/user_tbsp' 5000)
   
    在分区数据库中创建用户临时表空间 可在除IBMTEMPGROUP中的其他分区组中产生.
   CREATE  USER TEMPORARY  TABLESPACE USER_TEMP_TBSP
    IN DATABASE PARTITION GROUP USER_TEMP_TBSGRP
    PAGESIZE 4 K  MANAGED BY SYSTEM 
    USING ('D:/testdbtbs/user_temp_0' ) ON DBPARTITIONNUM (0)
    USING ('d:/testdbtbs/user_temp_1' ) ON DBPARTITIONNUM (1)       
  
  *指定物理设备
  在WINDOWS上,指定物理硬盘驱动器,使用//./PhysicalDriveN (N-0,1,2..)
              指定逻辑驱动器使用//./N: (N是系统中的逻辑盘符)
  在UNIX中指定字符设备.
 
   #SMS  当对象增大时，文件每次扩展一页。若需要提高插入性能，可以考虑启用多页分配，如MDC表。
运行db2empfa. 对于多分区数据库必须对每个分区运行此使用程序，一旦启用就不能禁止。
   #DMS 
单分区表空间大小，4kb - 64gb;8kb-128gb;16kb-256gb;32kb-512gb
            在缺省情况下，每个容器都保留一个数据块作为开销，表空间的最小大小是5个数据块。
三个保留给开销使用。两个用于用户表数据。

  ＃在多个节点上产生表空间
CREATE TABLESPACE TS1 MANAGED BY DATABASE USING
(device '/dev/rcont $N' 20000)

CREATE TABLESPACE TS2 MANAGED BY DATABASE USING
(file '/DB2/containers/TS2/container $N+100' 10000)

CREATE TABLESPACE TS3 MANAGED BY SYSTEM USING
('/TS3/cont $N%2', '/TS3/cont $N%2+2')

  #增加表空间的空间
    ALTER TABLESPACE RESOURCE
       ADD (DEVICE '/dev/rhd9' 10000,
            DEVICE '/dev/rhd10' 10000)
   #改变表空间状态
    DB2 ALTER TABLESPACE <name> SWITCH ONLINE
   #删除表空间
    DROP TABLESPACE <name>
    可以先增加一个系统临时表空间,然后删除老的.
   #获取表空间使用信息
    get snapshot for tablespaces on sample
   ＃获取表空间的CONTAINER
    LIST TABLESPACE CONTAINERS FOR 0(TABLESPACE_ID) SHOW DETAIL
  
# 创建和填充表

  列出表:
  list tables － 列出当前用户的表
  list tables for all － 列出数据库中所定义的所有表
  list tables for schema schemaname － 列出具有指定模式的表
  describe table tablename － 显示指定表的结构

  产生表和主键
  CREATE TABLE DEPARTMENT
(DEPTNO CHAR(3) NOT NULL,
DEPTNAME VARCHAR(29) NOT NULL,
MGRNO CHAR(6),
ADMRDEPT CHAR(3) NOT NULL,
LOCATION CHAR(16),
PRIMARY KEY (DEPTNO))
  IN RESOURCE
  产生外键
  CREATE TABLE EMPLOYEE
(EMPNO CHAR(3) NOT NULL PRIMARY KEY,
FIRSTNME VARCHAR(12) NOT NULL,
LASTNAME VARCHAR(15) NOT NULL,
WORKDEPT CHAR(3),
PHONENO CHAR(4),
PHOTO BLOB(10m) NOT NULL,
FOREIGN KEY DEPT (WORKDEPT)
REFERENCES DEPARTMENT ON DELETE NO ACTION)
  IN RESOURCE
        ON DELETE NO ACTION 表示如果该部门有任何雇员则该部门不能被删除.
  定义表检查约束
      在创建或改变表时,通过将检查约束定义与表关联来对该表创建表检查约束.
      当INSERT或UPDATE语句修改该表中的数据时,就自动激活此约束.表检查约束对
      DELETE或SELECT没有影响.检查约束不能与类型表相关.
       约束名不能与在同一个CREATE TABLE语句内指定的任何其他约束相同.若不
       指定约束名,系统会自动生成18个字符的唯一标识符.
      表检查约束用于实现键唯一性或引用完整性约束所未涵盖的数据完整性规则.
      如:
CREATE TABLE EMP_ACT
(EMPNO CHAR(6) NOT NULL,
PROJNO CHAR(6) NOT NULL,
ACTNO SMALLINT NOT NULL,
EMPTIME DECIMAL(5,2),
EMSTDATE DATE,
EMENDATE DATE,
CONSTRAINT ACTDATES CHECK(EMSTDATE <= EMENDATE) )
IN RESOURCE
     约束EMSTDATE必须小于EMENDATE

   定义信息性约束
       信息性约束是一个规则,可由SQL编译器使用,但数据库管理器不会强制使用它.
       SQL编译器包括一个重写查询阶段,它将SQL语句变换为可能是优化的格式并改进
       所需数据的存取路径.目的是改进查询性能.
   对新表定义生成列
       生成列在基本表中定义,在这些列中,存储的值是使用表达式计算得出的,而不是
通过插入或更新操作指定.可以改善查询性能,特别是计算很复杂或在查询时要进行
多次表达式求值.
CREATE TABLE t1 (c1 INT,
c2 DOUBLE,
c3 DOUBLE GENERATED ALWAYS AS (c1 + c2)
c4 GENERATED ALWAYS AS
(CASE WHEN c1 > c2 THEN 1 ELSE NULL END))
    创建用户定义临时表
临时表不出现在系统目录中,不能共享此表
DECLARE GLOBAL TEMPORARY TABLE gb1_temp
  LIKE tmpltab1
  ON COMMIT DELETE ROES
  NOT LOGGED
  IN usr_tbsp
 
定义此用户临时表所使用的列的名称和描述与empltabl的列的名称和描述完全相同.
隐式定义只包括列名,数据类型,可空性特征和列缺省值属性.未定义其他列属性,包括
唯一约束,外键约束,触发器和索引.
    对新表定义身份列
        为插入表的每一行自动生成保证唯一数字值的方法.
        只在单分区数据库中支持.
CREATE TABLE test_table ( col1 int,
  col2 double,
  col3 int not null generated always as identity
       (start with 100,increment by 5))

    创建序列
        序列是一个数据库对象,它允许自动生成值.序列特别适合于生成唯一键值.
        与身份列属性不同,未使序列与特定表列相关,也未将它绑定至唯一列,只是仅可通过该表
        列存取.只在单分区数据库中才受支持.
        在多分区环境中的单分区数据库也不行.
        CREATE SEQUENCE order_seq
               START WITH 1
               INCREMENT BY 1
               NOMAXVALUE
               NOCYCLE
               CACHE 24
       使用序列
         insert into order (orderno,custno)
             values (nextval for order_seq,123456);
         insert into line_item (orderno,partno,quantity)
             values (prevval for order_seq,987654,1)
         使用NEXTVAL,PREVVAL可以在两个不同的表中使用相同的序列号.
   对表定义维
  
引用完整性约束 第 13 页（共17 页）

 


引用完整性约束是在创建表时定义的，或者是在之后使用 alter table 语句定义的。

建立引用完整性的子句有：

primary key 子句
unique constraint 子句
foreign key 子句
references 子句
例如：


create table artists (artno INT, ...  primary key (artno) foreign key dept (workdept)
          references department on delete no action)


让我们了解一下各种引用完整性规则：

插入规则：

有一个隐式规则，在没有找到父项时取消插入。
删除规则：

Restrict：如果有从属行就不能删除父行。
Cascade：删除父表中的行会自动删除其从属表中的任何相关行。
No Action（缺省值）：在应用了所有其它引用约束之后强制每个子行的父行都存在。
Set Null：外键字段设置成 null；其它列保持不变。
更新规则：

Restrict：如果从属表中的行与键的初始值相匹配，则不更新父键。
No Action（缺省值）：如果从属表中没有任何行与父键相匹配，则不更新父键。

   增加表中的列
   ALTER TABLE EMPLOYEE
     ADD <COLUMN_NAME> <DATA_TYPE> <NULL_ATTRIBUTE>
    
   增加唯一性约束
   ALTER TABLE EMPLOYEE
        ADD CONSTRAINT NEWID UNIQUE(EMPNO,HIREDATE)
   删除唯一性约束
   ALTER TABLE EMPLOYEE
     DROP UNIQUE NEWID
   删除主键
   ALTER TABLE <NAME>
     DROP PRIMARY KEY
   增加主键
  ALTER TABLE <NAME> ADD PRIMARY KEY (COL1,COL2,..)
   删除外键
   ALTER TABLE <name>
DROP FOREIGN KEY <foreign_key_name>
   删除表检查约束
   ALTER TABLE <table_name>
DROP CHECK <check_constraint_name>   
   添加表的外键
     ALTER TABLE <NAME>
        ADD CONSTRAINT <constraint_NAME>
        FOREIGN KEY <COLUMN_NAME>
        references table_name <col_name>
        ON DELETE <ACTION_TYPE>
        ON UPDATE <ACTION_TYPE>
 
   在多个表空间中创建表
       表数据,表索引及与表相关联的任何长型列数据可以存储在同一表空间中,也可以
       放在不同的表空间中.只能使用DMS.
       CREATE TABLE <name>
        (<column_name> <data_type> <null_attribute>)
         IN <table_space_name>
         INDEX IN <index_space_name>
         LONG IN <long_space_name>
        
    在分区数据库中创建表
        必须小心的选择适当的分区建,以后不能跟改.再者,必须将任何唯一索引定义为分区键的一个超集.
        表的大小是(分区数*分区大小(4K是64GB).
        CREATE TABLE MIXREC (MIX_CNTL INTEGER NOT NULL,
             MIX_DESC CHAR(20) NOT NULL,
             MIX_INT INTEGER NOT NULL)
             IN MIXTS12
             PARTITIONING KEY (MIX_INT) USING HASHING
    产生触发器
      用途:
      验证输入的数据
      为新插入的行生成值
      为交叉引用而从其他表中进行读取
      为审计跟踪而向其他表写入
     
      CREATE TRIGGER <name>
        <action> ON <table_name>
        <operation>
        <triggered_action>
       
    创建用户定义函数(UDF)或方法
        UDF扩展并添加了SQL的内置函数提供的支持,且可在可使用内置函数的任何
        地方使用.可使用两种方式创建UDF:
           外部函数,用一种编程语言编写
           有源函数,从另一个现有函数继承产生.
          
          
           三种UDF:标量,返回一个单值答案.
                   列,从一组相似(一列)的值中返回单值答案,如AVG()只能定义有源函数.
                   表,将一个表返回至引用它的SQL,只能在select语句的from子句中引用表函数.
         UDF 记录在SYSCAT.FUNCTIONS AND SYSCAT.FUNCPARMS目录视图中.
    用户定义类UDT
        UDT是由用户在数据库中创建的命名的数据类型.UDT可以是单值类型,它与内部数据类型或
        结构化类型共享一个公共的表示法,结构化类型具有一个命名属性序列,其中每个属性都有一个类型.
        结构化类型可以是另一个定义类型层次结构的结构化类型的子类型.
   
    创建视图
        CREATE VIEW <name> (<column>,<column>,<column>)
           SELECT <column_names> FROM <table_name>
           WITH CHECK OPTION
       WITH CHECK OPTION 子句指示必须根据该视图定义检查该视图的任何更新的行或插入的行,
       如它不符合,则拒绝它,增加了数据完整性.
       CREATE VIEW EMP_VIEW
         SELECT LASTNAME AS DA00NAME,
                EMPNO AS DA00NUM,
                PHONENO
         FROM EMPLOYEE
       WHERE WORKDEPT = 'A00'
       WITH CHECK OPTION
      
    创建具体查询表
        具体查询表是以查询结果为基础所定义的一种表.因此,具体查询表通常包含预先计算的结果,
        这些结果是根据表定义中引用的一个或多个表中的现有数据计算而得.若SQL编译器确定查询
        在针对具体查询表运行时比对一个或多个基本表运行时效率更高,将对具体查询表执行该查询.
       
   创建别名
       别名是引用表,别名或视图的间接方法,这样SQL语句可与该表或视图的限定名无关.
      
       CREATE ALIAS WORKERS FOR EMPLOYEE
      
   索引,索引扩展或索引规范
       索引是行位置的列表,按一个或多个指定列的内容来排序.
       索引扩展是一个索引对象,它配合带有结构化类型或单值类型列的索引使用.
       索引规范是一个元数据结构.它告诉优化器别名所引用的数据源对象(表或视图)
       是否存在索引.只是索引的描述.
         索引顾问,,db2advis
       索引得最大列数是16,最大长度是1024字节.
       CREATE INDEX <name> ON <talbe_name> (<column_name>)
   重命名表或索引
       要重命名的表或索引不能是目录表或索引,总结表或索引,类型表,已声明
       全局临时表以及昵称的名称.
        并且不能在下列任何一个对象中引用现有表或索引:
        视图,触发器,引用约束,总结表,现有引用列的作用域
        表中不能有检查约束,不能有除身份列以外的其他生成列.
       
        RENAME TABLE <SCHEMA_NAME>.<TABLE_NAME> TO <NEW_NAME>
        RENAME INDEX <schema_name>.<index_name> TO <new_name>
       

索引可以：

是升序或是降序（如果没有指定，缺省值是升序）
是唯一的，也可以是不唯一的（如果没有指定，缺省值是不唯一的）
是复合的
用来执行群集
是双向的（这由 allow 或 disallow reverse scans 控制的）
包括其它列（这只适用于唯一索引）。

   删除表
       DROP TABLE <TABLE_NAME>
   删除索引
       DROP INDEX <index_name>
    
   通过命令行处理器调用"性能配置向导"
       使用AUTOCONFIGURE 
      
终止所有应用程序与数据库的连接
db2 force applicaitons all

#给用户授权
GRANT privilege ON object-type object-name
  TO [{USER | GROUP | PUBLIC}] authorization-name
  [WITH GRANT OPTION]
 
  GRANT INSERT,DELETE ON TABLE staff TO USER rosita WITH GRANT OPTION
 
  #撤消用户权利
  REVOKE privilege ON object-type object-name
  FROM [{USER | GROUP | PUBLIC}] authorization-name

  REVOKE ALL PRIVILEGES ON TABLE staff FROM joanna


DB2常用命令汇总之三#声明临时表
DECLARE GLOBAL TEMPORARY TABLE session.temp1
  LIKE employee
  ON COMMIT PRESERVE ROWS
  NOT LOGGED
IN mytempspace

#ALTER
  可以修改:缓冲池,表,表空间,视图

#DROP
  可以删除:缓冲池,事件监控程序,函数,索引,模式,存储过程,表,表空间,触发器,视图.
#产生数据备份
CREATE TABLE pers LIKE staff

INSERT INTO pers
  SELECT id, name, dept, job, years, salary, comm
    FROM staff
    WHERE dept = 38

#唯一性约束
CREATE TABLE BOOKS (BOOKID INTEGER NOT NULL PRIMARY KEY,
                    BOOKNAME VARCHAR(100),
                    ISBN CHAR(10) NOT NULL CONSTRAINT BOOKSISBN UNIQUE)

ALTER TABLE BOOKS ADD  CONSTRAINT UNIQUE (BOOKID)

#参照完整性约束
CREATE TABLE AUTHORS (AUTHORID INTEGER NOT NULL PRIMARY KEY,
                      LNAME VARCHAR(100),
                      FNAME VARCHAR(100))
CREATE TABLE BOOKS (BOOKID INTEGER NOT NULL PRIMARY KEY,
                    BOOKNAME VARCHAR(100),
                    ISBN CHAR(10),
                    AUTHORID INTEGER REFERENCES AUTHORS)

#表检查约束
ALTER TABLE BOOKS ADD BOOKTYPE CHAR(1) CHECK (BOOKTYPE IN ('F','N') )


#创建索引
CREATE INDEX I2BOOKNAME ON BOOKS (AUTHOID DESC, BOOKNAME ASC)


#设置概要文件注册表
  设置后实例要重新启动
  列出所有的变量: db2set -lr
  设置变量:db2set variable_name=value
  设置为缺省值:db2set variable_name=
  显示设置的变量:db2set -all
# 设置数据库管理器和数据库的参数
  获取当前参数:
    db2 get database manager configuration
db2 get database configuration for database_name
db2 get database manager configuration show detail
  设置参数:
   db2 update database manager configuration using parameter new_value
db2 update database configuration for database_name using parameter new_value
#准备数据库服务端口
  db2set DB2COMM=TCPIP,NETBIOS
  在services文件中包含服务和端口号,
   如:db2icdb2    50000/tcp
  db2 update database manager configuration using svcename db2icdb2
  重新启动数据库.
 
#查看连接的应用程序
  db2 list applications [for database db-name] [show detail]
#断开应用程序
  db2 force application (6,5)
  db2 force application all
#设置客户认证方式
  db2 update database manager configuration authentication auth_type
#创建缓冲池
  create bufferpool BP2 size 25000 pagesize 8 k

CONNECT TO SCCRM;
ALTER BUFFERPOOL IBMDEFAULTBP IMMEDIATE NODE 1 SIZE 50000;
ALTER BUFFERPOOL IBMDEFAULTBP IMMEDIATE NODE 0 SIZE 50000;
CONNECT RESET;

#将表空间的状态复位成正常（NORMAL）
  quiesce tablespaces for table <tablename> reset
 
#有用的目录表
  SYSCAT.COLUMNS:所包含的每一行对应于表或视图中定义的每个列
  SYSCAT.INDEXCOLUSE:列出索引中包含的所有列
  SYSCAT.INDEXES:包含的每一行对应于表或视图中定义的每个索引（包括适用的继承索引）。
  SYSCAT.TABLES：所创建每个表、视图、别名（nickname）或别名（alias）都对应其中一行。所有目录表和视图都在 SYSCAT.TABLES 目录视图中拥有一项。
  SYSCAT.VIEWS：所创建的每个视图都对应其中一行或多行。
 

###监控DB2活动
  ##捕获快照
    数据库,表空间,表,缓冲池,锁,数据库管理器,应用程序
  #拍摄快照
   API,命令行
  UPDATE MONITOR SWITCHES
  #打开和关闭快照
   1,在实例级别上设置监视器开关(影响所有用户和数据库)
     DFT_MON_STMT：语句监视器（用于动态 SQL）
DFT_MON_TABLE：表监视器
DFT_MON_LOCK：锁监视器
DFT_MON_BUFPOOL：缓冲池监视器
DFT_MON_SORT：排序监视器
DFT_MON_UOW：工作单元信息
DFT_MON_TIMESTAMP：跟踪时间戳记信息
     db2 get dbm cfg|grep DFT_MON
     db2 update dbm cfg using monitorSwitch [ON|OFF]
db2 update dbm cfg using DFT_MON_SORT ON

   2,在应用程序级别上设置监视器开关(只适合于特定的应用程序)
   在CLP中打开只适合这个CLP
     Bufferpool
Lock
Sort
Statement
Table
Timestamp
UOW

db2 get monitor switches
    db2 update monitor switches using switchName [ON|OFF]
    3,复位开关
  db2 reset monitor [ALL|for database databaseName] [at dbpartitionnum partitionNum]
将监视器开关的值复位成空或0.
    #数据库快照
     包含如下信息:
     连接
DB2 代理程序
锁
排序
缓冲池活动总数
SQL 活动
SQL 语句数量
日志使用情况
高速缓存使用情况
散列连接
    下面是获取这种快照的命令
db2 get snapshot for database on databaseName

    #数据库管理器快照
    db2 get snapshot for database manager
    #表快照
    db2 get snapshot for tables on drew_db
    #表空间和缓冲池快照
    db2 get snapshot for tablespaces on drew_db
    db2 get snapshot for bufferpools on drew_db

计算缓冲池命中率:
    Ratio = ((1-(physical index and data reads))/(logical index and data reads))*100%

    #锁快照
    db2 get snapshot for locks on drew_db
   
    #动态SQL快照
    #查找执行速度较慢的SQL
     SELECT stmt_text,total_exec_time,num_executions
     FROM TABLE (SNAPSHOT_DYN_SQL('DREW_DB',-1)) as dynSnapTab
     ORDER BY total_exec_time desc
     FETCH FIRST 1 ROW ONLY

    第二个示例查找平均执行时间最长的五条 SQL 语句：


SELECT stmt_text,
CASE WHEN num_executions = 0
THEN 0
ELSE (total_exec_time / num_executions)
END avgExecTime,
num_executions
FROM TABLE( SNAPSHOT_DYN_SQL('DREW_DB', -1)) as dynSnapTab
ORDER BY avgExecTime desc
FETCH FIRST 5 ROWS ONLY

### 事件监控器
     人们用快照来检查某个精确时刻的DB2，并聚集性能信息。事件监控器与此不同，人们用他在固定的时间
    周期内监控DB2性能。事件监视器检查数据库中的转换事件，并将每个事件都当成一个对象。这允许对 DB2 的行为进行非常详细的分析。
        事件监视器捕获的信息类似于快照捕获的信息。同时可以运行多个监视器，并且每个监视器也可以捕获多种事件类型的信息。这允许不同的管理员相互独立地监控不同的活动。

事件监视器可以捕获有关下列内容的信息：

数据库
表
死锁
表空间
缓冲池
连接
语句
事务
可将事件监视器的信息写到：

SQL 表
文件
管道

   ##创建事件监视器
     CREATE EVENT MONITOR
   ##打开和关闭监视器
     db2 set event monitor eventMonitorName state [0|1]
eventMonitorName 是已创建的事件监视器的名称。0 将关闭监视器，而 1 将打开监视器。
      #获取状态
      SELECT EVENT_MON_STATE('drewTest') FROM SYSIBM.SYSDUMMY1

SYSIBM.SYSEVENTMONITORS 表及该表的视图 SYSCAT.EVENTMONITORS 包含有关已创建的事件监视器的信息。可以对这些表运行 SQL 查询，以确定监视器的状态：
SELECT evmonname, target_type, target,
FROM syscat.eventmonitors
where evmonname LIKE 'drew%'

autostart 选项

用于创建事件监视器的命令中的 autostart 选项表明，每当数据库启动时，自动启动事件监视器。

#清空事件监视器
      注意：事件监控器名称使用大写字母，需要创建目录。
     
     
还可将事件监视器数据清空到磁盘中。如果您希望记录这类信息，如通常仅当终止所有连接时才写的数据库事件，那么这非常有用。下面是一个示例命令：

db2 flush event monitor eventMonitorName
#使用事件监视器
       事件监视器应当用于监控非常具体的一些事件或短时间内的工作负载。它
们旨在为您提供非常具体的信息，以允许您诊断数据库或应用程序的问题或行为。
与快照不同，事件监视器对 DB2 的性能影响极大。这是由于为每个事件对象写的
信息的数量造成的。语句监视器对性能的影响极大，因为数据库引擎必须为每个
查询执行所有额外的工作：不只是能够执行查询，DB2 引擎还必须写出这条查询
的所有特征和运行时信息。该信息必须写入文本文件，这样会进一步降低性能。

#死锁监控
        CREATE EVENT MONITOR DEADLOCK_DB
FOR DEADLOCKS
WRITE TO FILE 'deadlock_db'
MAXFILES 1
MAXFILESIZE NONE
AUTOSTART
              注意：事件监控器名称使用大写字母，需要创建目录。

#SQL监控
        SQL 监视器十分有用，因为它可以俘获动态和静态 SQL 语句。如果应用
程序利用了无法用 SQL 快照捕获的预编译 SQL 语句，那么该监视器就
很重要。

对于每条被执行的 SQL 语句记录一个事件。每个语句的属性（如读取、
选择和删除等等操作的行数）都被记录下来，但是不象在快照中那样以
汇总的方式进行表示。另外还记录执行的时间范围以及启动和停止次数。这允许您对一些事务以及某个应用程序的 SQL 执行对其它应用程序的 SQL 执行有何影响进行详细分析。

还可以使用 SQL 监视器来发现拙劣的执行代码；如果将输出放入表中，
那么通过对个别代码的执行次数进行搜索，可以做到这一点。由于运行
SQL 监视器的信息量以及性能开销，所以只应在短期测试或问题确定中
使用该技术，而不应在生产环境中使用它。

CREATE EVENT MONITOR BAR
FOR STATEMENTS
WRITE TO TABLE
STMT(TABLE drewkb.stmtTab)
includes(rows_read,rows_written_stmt_text)

#捕获事件监视器数据
        db2eva [db databaseName] [evm eventMonitorName]

       #利用EXPLAIN分析SQL
        SQL 的 Explain 通过图形化或基于文本的方式详细说明了 SQL 语句的每个部分是如何执行以及何时执行的。这包括以下一些基本信息：

正被访问的表
正被使用的索引
何时连接数据
何时排序数据
Explain 还捕获更复杂的信息，在细究 SQL 正在发生什么时，该信息非常有用：

表和索引基数
正连接的表和索引的顺序
结果集的基数
在查询的每部分正在选择哪些字段
排序方法
SQL 每部分的时间范围

       要理解 Explain 信息，您需要掌握的最重要概念是 timeron。timeron 是 DB2 优化器使
用的计量单位，用来计量完成查询的时间和资源数量。timeron 综合了时间、CPU 利用率、
I/O 和其它因素。由于这些参数值是变化的，因此执行某个查询所需的 timeron 数量是动态
的，每次执行该查询所需的 timeron 都不同。

#使用控制中心的EXPLAIN SQL
         观察SQL的存取方案，分析优化参数，考虑优化的级别。
        #使用字符工具
         db2 set current explain mode [no|yes|explain]
db2exfmt
可以从命令行调用 db2expln 工具，以获得查询的存取方案。但是，该工具不返回优化器信息。
        db2expln -database drew_db -statement "select * from syscat.tables" -terminal

#SQL故障诊断
        索引使用，是否使用索引，使用索引的顺序
        表基数和"SELECT *" 的使用
        优化级别太低。
        设置优化级别：db2 set current query optimization [0|1|2|3|5|7|9]
   ##使用运行状况中心和内存可视化工具
       # 选定实例使用view memory usage,可以把输出保存到文件。
   除了提供了内存可视化之外，该工具还允许您对某些参数值设置警报。警报的输出将被写到名为
threshold 的文件，该文件与 db2diag.log 位于同一目录下。该目录位于实例主目录下。根据
您创建实例时所做选择的不同，该位置也会不同。
# DB2运行状况中心
         是否有充足的资源（如可用内存、表空间容器或日志存储器）来完成任务
资源使用是否有效
任务是否在可接受的时间周期内完成，或者任务的完成是否不会大幅度降低性能
资源或数据库对象是否不会永远处于不可用状态

  ##DB2查询巡视器和控制器
       IBM 为 DB2 提供了两种主要工具，它们允许您监控和控制数据库上 SQL 的执行。DB2 控制器（Governor）用于控制
用户和应用程序执行其 SQL 的优先级。DB2 查询巡视器（Query Patroller）为决策支持系统提供了查询和资源管理。
该工具接受通过您系统的所有查询，并对其进行分析、优先排序和调度。
      
DB2 查询巡视器为决策支持系统提供了查询和资源管理。该工具可以接受流经您系统的所有查询，并对其进行分析、
优先排序和调度。一旦完成查询，用户也将接到通知。在大型环境（其中完成某些查询可能要花几个小时，或者不
同部门可能具有不同的系统优先级或用途）中，该功能极其有用。

通过将工作重定向到合适的数据库分区，查询巡视器还将执行负载均衡，以确保某个数据库分区的使用不会过于繁重
。该工具只能与 SMP 或 MMP 环境中 DB2 ESE 的多分区选项一起使用。

在经过最新修订以后，IBM 已经对 DB2 查询巡视器彻底进行了重新架构，从而将查询控制功能集成进了类似 DB2 控制
中心的 DB2 查询巡视器中心，并提供了一个易于使用的用户界面。查询巡视器是完全基于服务器的，不需要客户机软件。

#性能  监控命令
get monitor switches  返回会话监控开关的状态
update monitor switches using <monitor> <on|off> 为<monitor>设置会话监控开关的状态
reset monitor all 复位性能监控程序值
get snapshot for dbm
get snapshot for all on <dbname>
get snapshot for dynamic sql on <dbname>   返回动态SQL高速缓存的内容
runstats on table <tbschema>.<tbname> 收集<tbname>的统计信息
reorgchk on table all      确定是否需要重组  reorgchk on table <tbschema>.<tbname>
reorg table <tablename> 通过重组消除碎片
###DB2实用程序
    三种实用程序：EXPORT,IMPORT,LOAD
        这些实用程序支持的文件格式有：

非定界或定长 ASCII（ASC）：顾名思义，这种文件类型包含定长 ASCII 数据，以便与列数据对齐。每个 ASC 文件都是一个
ASCII 字符流，这个字符流由根据行和列排序的数据值组成。数据流中的行由行定界符分隔，而通常将行定界符假定为换行符。
定界 ASCII（DEL）：它是各种数据库管理器用于数据交换的最常用文件格式。这种格式包含 ASCII 数据，它使用特殊字符定
界符分隔列值。数据流中的行由换行符充当行定界符进行分隔。
PC 版集成交换格式（PC version of the Integrated Exchange Format，PC/IXF）：它是数据库表的结构化描述。这种文件格式不仅
可以用于导入数据，还可以用于创建目标数据库中尚不存在的表。
工作表格式（Worksheet Format，WSF）：以这种格式存储的数据可以在工作表中显示。这种格式只能用于导出和导入。
游标：游标是用查询声明的。它只能用作装入操作的输入。

#EXPORT 实用程序使用 SQL SELECT 语句将数据从数据库表抽取到某个文件中。对于导出的数据而言，其文件格式可以是 DEL、IXF 或 WSF。建议您在
导出中包含 MESSAGES 子句，以便在导出期间捕获错误、警告和信息性消息。
EXPORT TO myfile.del OF DEL
    MESSAGES msg.out
        SELECT staff.name, staff.dept, org.location
        FROM org，staff
                WHERE org.deptnumb = staff.dept;

   在前一页上的示例中，数据被抽取到一个 DEL 格式的文件中。缺省情况下，列值由逗号（,）分隔，而字符串由双引号（"）括起来。如果要抽取
的数据已经包含逗号和双引号，那该怎么办呢？如果是这样的话，导入或装入实用程序不可能确定：哪些符号是实际的数据，哪些是定界符。要定
制 EXPORT 的运作方式，可以使用 MODIFIED BY 子句并指定想用文件类型修饰符修改什么。EXPORT 命令的格式如下：


EXPORT TO file_name OF file_type
    MODIFIED BY file_type_modifiers
    MESSAGES message_file
    select_statement
chardelx
指定 x 为新的单字符串定界符。缺省值是双引号（"）。
coldelx
指定 x 为新的单字符列定界符。缺省值是逗号（,）。
codepage=x
指定 x 这个 ASCII 字符串为输出数据的新代码页。在导出操作期间，将字符数据从应用程序代码页转换成这一代码页。
timestampformat="x"
x 是源表中时间戳记的格式。
考虑下面这个示例：


EXPORT TO myfile.del OF DEL
  MODIFIED BY chardel! coldel@ codepage=1208 timestampformat="yyyy.mm.dd hh:mm tt"
  MESSAGES msg.out
  SELECT * FROM schedule


面的命令以 DEL 格式从 SCHEDULE 表导出数据，其间发生了下列行为：

字符串由感叹号（!）括起来
列由 @ 号定界
字符串被转换成代码页 1208
SCHEDULE 表中用户定义的时间戳记具有 yyyy.mm.dd hh:mm tt 这种格式

  #导出大对象
  #可以在控制中心导出表，并进行调度。
  #IMPORT实用程序
   IMPORT FROM file_name OF file_type
    MESSAGES message_file
    [ INSERT | INSERT_UPDATE | REPLACE | REPLACE_CREATE | CREATE ]
    INTO target_table_name


INSERT 选项将导入的数据插入表中。目标表必须已经存在。
INSERT_UPDATE 向表中插入数据，或者用匹配的主键更新表中现有的行。目标表必须存在，且定义了主键。
REPLACE 选项删除现有的全部数据，然后将导入的数据插入现有的目标表中。
有了 REPLACE_CREATE 选项，如果目标表存在，那么实用程序删除现有的数据，然后插入新数据，就好像指定了 REPLACE 选项一样。如果没有定义目标表，那么在导入数据之前将先创建该表及其相关索引。正如您可以想到的那样，输入文件必须是 PC/IXF 格式的，因为这种格式含有导出表的结构化描述。如果目标表是由外键引用的父表，就不能使用 REPLACE_CREATE。
CREATE 选项创建目标表及其索引，然后将数据导入到新表中。它唯一支持的文件格式是 PC/IXF。您也可以指定表空间的名称，新表将创建于其中。
示例：


IMPORT FROM emp.ixf OF IXF
COMMITCOUNT 500
    MESSAGES msg.out
    CREATE INTO employee IN datatbsp INDEX IN indtbsp
       
        如果上面的命令因为某些原因而执行失败，那么您可以使用消息文件确定被成功导入并提交的最后一行。然后，您可以使用
RESTARTCOUNT 选项重新启动导入。在下面的命令中，实用程序将跳过前面的 30000 条记录才开始 IMPORT 操作。


IMPORT FROM myfile.ixf OF IXF
   COMMITCOUNT 500 RESTARTCOUNT 30000
   MESSAGES msg.out
   INSERT INTO newtable

       compound=x
使用非原子的复合 SQL 来插入数据。每次会尝试 x 条语句。
indexschema=schema
在创建索引期间对索引使用指定的模式。
striptblanks
在向变长字段装入数据时，截断任何尾部空格。
lobsinfile
指出要导入 LOB 数据。实用程序将检查 LOBS FROM 子句，以获取输入 LOB 文件的路径。
这里有一个实际使用这些文件类型修饰符的示例：


IMPORT FOR inputfile.asc OF ASC
    LOBS FROM /u/db2load/lob1, /u/db2load/lob2
   MODIFIED BY compount=5 lobinsfile
    INSERT INTO newtable
使用控制中心进行import。

  ##LOAD实用程序概述
        LOAD 实用程序是另一种用数据来填充表的方法。经过格式化的页被直接
写入数据库。这种机制允许进行比 IMPORT 实用程序更有效的数据移动。
不过，LOAD 实用程序不执行某些操作，如引用或表约束检查以及触发器调用。

  LOAD FROM input_source OF input_type
    MESSAGES message_file
    [ INSERT | REPLACE | TERMINATE | RESTART ]
    INTO target_tablename


#example,execute at partition en

date
db2 connect to sccrm user db2inst1 using db2inst1
db2 "LOAD FROM /backup1114/dw_call_cdr_20031002.txt OF DEL modified by coldel; fastparse anyorder replace into dw_call_cdr_20030801"
date

db2 "LOAD FROM /db2home/db2inst1/data/dw_newbusi_smscdr_20031026.txt OF DEL modified by coldel; terminate into dw_newbusi_smscdr_20031026_1"

LOAD 的源输入的格式可以是 DEL、ASC、PC/IXF 或 CURSOR。游标是从 SELECT
语句返回的结果集。使用 CURSOR 作为装入输入的示例显示如下：


DECLARE mycursor CURSOR FOR SELECT col1, col2, col3 FROM tab1;
LOAD FROM mycursor OF CURSOR INSERT INTO newtab;


装入目标必须存在，该实用程序才能启动。这个目标可以是表、类型表或表别名。不支持向系统表或临时表进行装入。

请使用 MESSAGES 选项来捕获装入期间的任何错误、警告和信息性消息。

LOAD 可以以四种不同方式执行：

INSERT 方式将输入数据添加到表中，不更改现有表数据。
REPLACE 方式从表中删除全部现有数据，然后用输入数据填充该表。
TERMINATE 方式终止装入操作，然后回滚到装入操作的起始点。一个例外是：如果指定了 REPLACE 方式，那么表将会被截断。
RESTART 方式用于重新启动以前中断的装入。它将自动从上一个一致性点继续操作。要使用该方式，请指定与前面的 LOAD 命令中相同的选项，
但却使用 RESTART 方式。它允许该实用程序找到在装入处理期间生成的所有必需临时文件。因此
，除非能够确信不需要从装入生成的临时文件，否则就不要以手工方式除去任何这类文件，这一点十分重要。
一旦装入不出任何错误地完成，临时文件就会被自动除去。缺省情况下，临时文件是在当前工作目录中创建的。
可以使用 TEMPFILES PATH 选项指定存储临时文件的目录。
   #装入过程的四个阶段
       完整的装入过程分为四个不同阶段。

装入阶段：
将数据装入表中。
收集索引键和表统计信息。
记录一致性点。
将无效数据放入转储文件，并在消息文件中记录消息。当数据行与表的定义不一致时，这些数据行就被认为是无效数据，
并会被拒绝（不装入表中）。请使用 dumpfile 修饰符来指定文件的名称和位置，以记录任何被拒绝的行。
构建阶段：
根据装入阶段所收集的键创建索引。
删除阶段：
删除导致违反键唯一性的那些行，并将这些行放入异常表中。除了如上所述有些数据只是不满足目标表的定义之外，还有
一些数据已经通过了装入阶段，但却违反了表中定义的唯一性约束。注：这里只将违反键唯一性的行作为坏数据；目前不检查其它约束。
由于这类数据已经装入了表中，因此 LOAD 实用程序将在此阶段删除违规行。异常表可以用来存储被删除的行，使您可以决定在装入操
作完成之后如何处理它们。如果没有指定异常表，那么就删除违规行，而不做任何跟踪，下面对异常表进行了更详细的讨论。
在消息文件中记录消息。
索引复制阶段：
如果 ALLOW READ ACCESS 是用 USE TABLESPACE 选项指定的，那么就会将索引数据从系统临时表空间复制到
索引应该驻留的表空间。
异常表是一个用户定义的表，它必须与要装入的目标表具有相同的列定义。如果至少有一列没有出现在异常表中，那么就
会废弃违规行。只可以向表末尾添加两个额外的列：记录行插入时间的时间戳记列，以及存储（认为行所包含的是坏数据的）
理由（或消息）的 CLOB 列。

 

LOAD FROM emp.ixf OF IXF
    MODIFIED BY DUMPFILE=c:/emp.dmp
  MESSAGES msg.out
    TEMPFILES PATH d:/tmp
    INSERT INTO employee
    FOR EXCEPTION empexp

在上图中，（1）显示了输入源文件的内容。
（2）中显示的目标表 EMPLOYEE 是用以下列定义创建的：
第一列必须具有唯一性。
最后一列是不能为 NULL 的数字列。
（3）中显示的异常表 EMPEXP 是用与 EMPLOYEE 相同的那些列以及时间戳记和消息列创建的。
在装入阶段，输入文件的所有数据都被装入了 EMPLOYEE — 但用粉红色标记的两行除外，
因为它们不满足 NOT NULL 和 NUMERIC 列定义。由于指定了 DUMPFILE 修饰符，因此这两行被记录在文件 C:/emp.dmp 中。

在删除阶段，用黄色标记的两行被从 EMPLOYEE 中删除了，并且被插入异常表 EMPEXP 中。这是由于违反了 EMPLOYEE 表中第一
列的唯一性而引起的。

在装入结束时，您应该检查消息文件、转储文件和异常表，然后决定如何处理被拒绝的行。
如果装入成功完成，那么就会除去在 D:/tmp 中生成的临时文件。

  #装入选项
      ROWCOUNT n：允许用户指定只装入输入文件中的前 n 条记录。
SAVECOUNT n：每装入 n 条记录之后就建立一致性点。同时会生成消息，并会将其记录在消息文件中，以指出在保存点成功地装入了多少输入行。这一点在输入文件类型为 CURSOR 时是无法做到的。
WARNINGCOUNT n：在发出 n 次警告后停止装入。
INDEXING MODE [ REBUILD | INCREMENTAL | AUTOSELECT | DEFERRED ]：在构建阶段，构建索引。这个选项指定 LOAD实用程序是重新构建索引还是增量式地扩展索引。支持四种不同方式：
REBUILD 方式强制重新构建所有索引。
INCREMENTAL 方式只用新数据扩展索引。
AUTOSELECT 方式允许实用程序在 REBUILD 和 INCREMENTAL 之间进行选择。
DEFERRED 方式意味着在装入期间不创建索引。所涉及的索引都用需要的刷新进行标记。这些索引将在重新启动数据库或第一次访问这类索引时重新构建。
STATISTICS [ YES | NO ]：在执行完装入以后，以前的目标表统计信息极有可能不再有效，因为目标表中已加入了更多的数据。您可以通过指定 STATISTICS YES 来选择收集这些统计信息。
  #文件类型修饰符。文件类型修饰符是用 MODIFIED BY 子句指定的。下面是少数几个您可能会觉得有用的修饰符：

fastparse：减少了对装入数据的语法检查以增强性能。
identityignore、identitymissing 和 identityoverride：分别用来忽略、指出丢失或覆盖标识列数据。
indexfreespace n、pagefreespace n 和 totalfreespace n：在索引和数据页中保留指定量的空闲页。
norowwarnings：禁止行警告。
lobsinfile：指出将装入 LOB 文件；并检查 LOBS FROM 选项以获取 LOB 路径。
 
  ##装入期间的表访问
    在装入表期间，LOAD 实用程序会用互斥锁将它锁定。在装入完成以前，不允许任何其它访问。这是 ALLOW NO ACCESS 选项的缺省行为。在进行这种装入期间，表处于 LOAD IN PROGRESS 状态。有一个方便好用的命令可以检查装入操作的状态，还返回表状态：


LOAD QUERY TABLE table_name


您可能猜到了这一点，即有一个选项允许进行表访问。ALLOW READ ACCESS 选项导致表在共享方式下被锁定。阅读器可以访问表
中已经存在的数据，却不能访问新的数据。正在装入的数据要等到装入完成后才可获得。此选项将装入表同时置于 LOAD IN PROGRESS
状态和 READ ACCESS ONLY 状态。
正如在前一页中所提到的那样，在构建阶段可以重新构建全部索引，也可以用新数据扩展索引。对于 ALLOW READ ACCESS 选项，
如果重新构建全部索引，那么会为该索引创建一个镜像副本。当 LOAD 实用程序到达索引复制阶段时（请参阅装入过程的四个阶段）
，目标表被置为脱机，然后将新索引复制到目标表空间。
无论指定哪个表访问选项，装入都需要各种锁来进行处理。如果某一应用程序已经锁定了目标表，那么 LOAD 实用程序就必须等到
锁被释放。不想等待锁的话，您可以在 LOAD 命令中使用 LOCK WITH FORCE 选项，以强制关闭其它持有冲突锁的应用程序。

  ##检查暂挂表状态
     至此，我们知道：不会将与目标表定义不一致的输入数据装入表中。在装入阶段，这样的数据会遭到拒绝，并被记录在消息文件中。
在删除阶段，LOAD 实用程序会删除那些违反任何唯一性约束的行。如果指定了异常表，违规的行将插入该表。对于表可能定义的
其它约束（如引用完整性和检查约束），怎么办呢？LOAD
实用程序不检查这些约束。表会被置于 CHECK PENDING 状态，这种状态迫使您先手工检查数据完整性，然后才能访问表。如前一页
中所讨论的那样，可以使用 LOAD QUERY 命令查询表状态。系统目录表 SYSCAT.TABLES 中的列 CONST_CHECKED 也指出表中所定义的
每个约束的状态。

       状态类型：Y,N,U,W,F
     要手工为一个或多个表关闭完整性检查，请使用 SET INTEGRITY 命令。下面给出了一些示例，以演示该命令的部分选项。要立即检查表
EMPLOYEE 和 STAFF 追加的选项的完整性，请使用以下命令：
SET INTEGRITY FOR employee, staff IMMEDIATE CHECKED INCREMENTAL
要用 IMMEDIATE UNCHECKED 选项忽略对表 EMPLOYEE 的外键检查：
SET INTEGRITY FOR employee FOREIGN KEY IMMEDIATE UNCHECKED
在装入完成以后，有时您可能想将目标表及其具有外键关系的派生表置于 CHECK PENDING 状态。这样做确保了在对完整性进行手工
检查之前，所有这些表的可访问性都得到了控制。装入选项是 CHECK PENDING CASCADE IMMEDIATE，它指出：立即将外键约束的检查
暂挂状态扩展到所有派生外键表。缺省情况下，只会将装入的表置于检查暂挂状态。这正是装入选项
CHECK PENDING CASCADE DEFERRED 的行为。

## IMPORT VS LOAD
   IMPORT LOAD
   SLOWER ON LARGE AMOUNTS OF DATA FASTER ON LARGE LOADS-WRITES FORMATTED PAGES
   CREATION OF TABLES & INDEXES WITH IXF   TABLES AND INDEXES MUST EXIST
   WSF SUPPORTED WSF NOT SUPPORTED
   IMPORT INTO TABLES AND VIEWS LOAD TABLES ONLY
   NO SUPPORT FOR IMPORTING INTO SUPPORTED
      MATERIALIZED QUERY TABLES
   ALL ROWS LOGGED MINIMAL LOGGING SUPPORTED
   TRIGGERS WILL BE FIRED TRIGGERS NOT SUPPORTED
   TEMPORARY SPACE USED WITHIN THE DATABASE  USED OUTSIDE THE DATABASE
   CONSTRAINTS VALIDATED DURING IMPORT   ALL UNIQUE KEY IS VERIFIED DURING LOAD
   OTHER CONSTRAINTS ARE VALIDATED WITH THE
   SET INTEGRITY COMMAND
   IF INTERRUPTED,TABLE IS USABLE WITH IF INTERRUPTED,THE TABLE IS HELD IN LOAD PENDING
   DATA UP TO THE LAST COMMIT POINT STATE,EITHER RESTART OR RESTORE TABLES EFFECTED
  
   RUN RUNSTATS AFTER IMPORT FOR STATISICS  STATISTICS CAN BE GATHERED DURING LOAD
   IMPORT INTO MAINFRAM DATABASE VIA CANNOT LOAD INTO MAINFRAME DATABASE
      DB2 CONNECT
   NO BACK-UP IMAGE REQUIRED BACKUP CAN BE CREATED DURING LOAD


DB2命令总汇四

##db2move

db2move 是一个数据移动工具，可以用来在 DB2 数据库之间移动大量的表。该命令中支持的操作有 EXPORT、IMPORT 和 LOAD。
db2move 的语法可以象下面那样简单：
db2move database_name action options

该工具先从系统目录表中抽取用户表列表，接着以 PC/IXF 格式导出每个表。然后，可以将这些 PC/IXF 文件导入或装入到另一个
DB2 数据库。
以下是一些示例。下面这条命令用指定的用户标识和密码以 REPLACE 方式导入 sample 数据库中的所有表：

db2move sample import -io replace -u userid -p password
而下面这条命令则以 REPLACE 方式装入 db2admin 和 db2user 模式下的所有表：

db2move sample load -sn db2admin, db2user -lo REPLACE
   ##db2look 是一个方便的工具，可以从命令提示符或控制中心对其进行调用。该工具可以：

从数据库对象抽取数据库定义语言（DDL）语句
生成 UPDATE 语句来更新数据库管理器和数据库配置参数
生成 db2set 命令来设置 DB2 概要文件注册表
抽取和生成数据库统计报告
生成 UPDATE 语句来复制有关数据库对象的统计信息
类似 LOAD 的实用程序都要求存在目标表。您可以使用 db2look 来抽取表的 DDL，对目标数据库运行该 DLL，然后调用装入操作。如同下面
的示例所演示的那样，db2look 使用起来非常方便。下面这条命令为（来自数据库 department 的）peter 所创建的所有对象生成 DDL 语句，
同时将输出存储在 alltables.sql 中。


db2look -d department -u peter -e -o alltables.sql


接下来这条命令生成：

数据库 department 中所有对象的 DLL（由选项 -d、-a 和 -e 指定）。
复制数据库中所有表和索引的统计信息的 UPDATE 语句（由选项 -m 指定）。
GRANT 授权语句（由选项 -x 指定）。
用于数据库管理器和数据库配置参数的 UPDATE 语句，以及用于概要文件注册表的 db2set 命令（由选项 -f 指定）。

db2look -d department -a -e -m -x -f -o db2look.sql

##RUNSTATS 实用程序

DB2 利用一个完善的、基于成本的优化器来确定如何访问数据。其决策在很大程度上受到了一些统计信息的影响，这些统计信息是关于数据库
表和索引的大小的。因此，要时刻使数据库统计信息保持最新状态，以便能够选择有效的数据存取方案，这一点十分重要。RUNSTATS 实用程
序用于更新表的物理特征及其相关索引的统计信息。这些特征包括记录数（基数）、页数和平均记录长度等。
让我们用一些示例来演示此实用程序的用法。下面的命令收集表 db2user.employee 的统计信息。在计算统计信息期间允许阅读器和记录器访
问该表：

RUNSTATS ON TABLE db2user.employee ALLOW WRITE ACCESS

以下命令用分布式统计收集表 db2user.employee 以及列 empid 和 empname 的统计信息。在此命令运行期间，该表只能用于只读请求。

RUNSTATS ON TABLE db2user.employee WITH DISTRIBUTION ON COLUMNS ( empid, empname )
    ALLOW READ ACCESS
以下命令收集表 db2user.employee 的统计信息及其全部索引的详细统计信息：

RUNSTATS ON TABLE db2user.employee AND DETAILED INDEXES ALL

##REORG 和 REORGCHK 实用程序

从数据库增删的数据在物理上可能并不是按顺序放置的。在这种情况下，DB2 必须执行额外的读操作来访问数据。通常，这意味着需要更多的
磁盘 I/O 操作，而我们都知道进行这类操作的代价是昂贵的。在这种情况下，您应该考虑根据索引对表进行物理上的重组，以便相关数据相
互之间靠得更近一些，从而尽可能地减少 I/O 操作。
REORG 是一个为表和／或索引重组数据的实用程序。虽然在物理上对数据进行了重新安排，但 DB2 却提供了联机或脱机执行该操作的选项。
在缺省情况下，脱机 REORG 允许其他用户读取该表。您可以通过指定 ALLOW NO ACCESS 选项来限制表访问。联机 REORG（也称为现场 REORG）
不支持对表的读访问或写访问。由于重新安排了数据页，因此并发应用程序可能必须等待 REORG 完成当前页。您可以使用适当的选项来轻松
地停止、暂停或重新开始重组过程：
下面的示例都是非常容易看懂的：

REORG TABLE db2user.employee INDEX db2user.idxemp INPLACE ALLOW WRITE ACCESS
REORG TABLE db2user.employee INDEX db2user.idxemp INPLACE PAUSE

REORGCHK 是另一个数据维护实用程序，它有一个选项可以用来检索当前的数据库统计信息或更新数据库统计信息。它还会生成带有 REORG
指示符的统计信息报告。REORGCHK 根据统计规则在需要 REORG 的地方用星号（*）标记表或索引。
让我们考虑一些示例。下面这条命令生成当前（关于运行时授权标识拥有的全部表的）统计信息的报告：
REORGCHK CURRENT STATISTICS ON TABLE USER

下面的命令更新统计信息，然后生成在模式 smith 下创建的全部表的报告：

REORGCHK UPDATE STATISTICS ON SCHEMA smith

##REBIND 实用程序和 FLUSH PACKAGE CACHE 命令

在执行数据库应用程序或任何 SQL 语句之前，必须先由 DB2 对它们进行预编译，并生成一个包。包是一种数据库对象，其中含有应用程序
源文件中所使用的已编译 SQL 语句。DB2 使用该包来访问 SQL 语句中引用的数据。DB2 优化器如何为这些包选择数据存取方案呢？它依靠
包创建时的数据库统计信息。
对于静态 SQL 语句，包在编译时创建，并且被绑定到数据库上。如果对统计信息进行了更新，以反映物理数据库特征，那么也应该更新现有
的包。REBIND 实用程序允许您重新创建包，以便可以利用当前的数据库统计信息。命令十分简单：

REBIND PACKAGE package_name


不过，如果您要更改应用程序源代码，那么就得显式地删除现有的相关包，然后重新创建包。REBIND 实用程序不用于这一目的。这里，
我们之所以就此对您加以提醒，是因为 DBA 经常误解了 REBIND 的用法。
对于动态 SQL 语句，它们是在运行时预编译的，而且被存储在包高速缓存中。如果更新了统计信息，那么您可能会刷新高速缓存，以便
重新编译动态 SQL 语句，从而获取更新的统计信息。命令类似下面的样子：

FLUSH PACKAGE CACHE DYNAMIC

##数据库维护过程
RUNSTATS -- REORGCHK--YES--REORG
              |      |
              |      |
              NO   |----- RUNSTATS
              |----|---------|
              REBIND      FLUSH PACKAGE CACHE
                 |      |
                 APPLICATION EXECUTION
                
##DB2性能顾问程序
1，图形化工具CONFIGURATION ADVISOR
2,CLP AUTOCONFIGURE USING mem_percent 60 workload_type complex num_stmts 20 APPLY DB AND DBM

##DB2 设计顾问程序

设计顾问程序可以帮您找到 SQL 语句的最佳索引。它使用 DB2 优化器、数据库统计信息和解释（Explain）
机制来为特定查询或一组 SQL 语句（也称为工作负载）生成推荐索引。您可以从命令行用 db2advis 加上必要的输入启动该顾问程序。
下面的示例使用输入文件
input.sql 对 sample 数据库执行设计顾问程序，该输入文件含有一组 SQL 语句。然后将输出存储在 output.out 中。
db2advis -d sample -i input.sql -o output.out

图形化工具：desigen Advisor

### 备份与恢复

##数据库恢复概念
  系统故障，事务故障，介质故障，灾难。
  ＃恢复策略
    问题：可以再次从另一个来源装入数据吗？能够承受丢失多少数据？
          能化多少时间来恢复数据库？哪些存储资源可用于存储备份和日志？
  ＃恢复类型
    崩溃恢复（系统崩溃，DB2重新启动执行回滚），版本恢复（使用从BACKUP命令
    获取的备份中恢复先前的数据库版本），前滚恢复（通过使用完全数据库备份，结合
    日志文件来扩展版本恢复，要求使用归档日志记录）
    db2采用先写日志后写磁盘数据库的方式。
  ＃主日志文件和辅助日志文件
    主日志文件是在首次数据库连接时或数据库激活时直接分配的。辅助日志文件需要时每次动态地分配一个。

有几个与日志记录相关的数据库配置参数。其中一些参数是：

LOGPRIMARY：该参数确定要分配的主日志文件数。
LOGSECOND：该参数确定可分配的辅助日志文件的最大数目。（最大254）
LOGFILSIZ：该参数用于指定日志文件的大小（用 4 KB 页为单位）。
让我们考虑一个示例。假设数据库配置文件中有下列值：

Log file size (4 KB)                        (LOGFILSIZ) = 250
Number of primary log files                (LOGPRIMARY) = 3
Number of secondary log files               (LOGSECOND) = 2
Path to log files                                       = C:/mylogs/

一旦首次建立与数据库的连接，就分配三个主日志文件，它们均由 250 个 4 KB 页组成。
DB2 将填满第一个日志，然后继续填满第二个和第三个日志。填满第三个日志文件后，没有更多的主
（预分配的）日志文件，因此 DB2 将动态地分配第一个辅助日志文件，因为 LOGSECOND 大于零。一旦
这个日志文件被填满，DB2 将继续分配另一个辅助日志文件，并将重复该过程，直到达到 LOGSECOND 日
志文件数目的最大值为止。对于该示例，当 DB2 尝试分配第三个辅助日志文件时，它将返回一个错误，
指出已经达到事务满条件。此时，将回滚该事务。

＃无限日志记录
要允许无限的活动日志记录：

将 USEREXIT 数据库配置参数设置为 ON。
将 LOGSECOND 设置为值 -1。
＃日志类型
活动日志。如果满足下面两个条件中的任何一个，则认为该日志是活动的：
它包含有关还未提交或回滚的事务的信息。
它包含有关已经提交但其更改还未被写入数据库磁盘（外部化）的事务的信息。
联机归档日志。这种类型的日志包含已提交的且已外部化的事务的信息。这种日志被保存在与活动日志相同的目录中。
脱机归档日志。是指已经从活动日志目录移动到另一个目录或介质的归档日志。可以手工或使用用户出口（userexit）
的自动过程来完成这个移动。

   ＃＃日志记录类型
   循环日志类型：循环日志记录是 DB2 的缺省日志记录方式。从其名称可以知道，这种类型的日志记录以循环方式重用日志。例如，如果
有四个主日志文件
   ，那么 DB2 将以如下顺序使用它们：Log #1，Log #2，Log #3，Log #4，Log #1，Log #2 等。
只要日志仅包含有关已经提交的且被外部化到数据库磁盘的事务的信息，就可以用循环日志记录方式重用它。换言之，如果日志仍
是一个活动日志，则不能重用它。
采用上面的示例，如果一个长期运行的事务使用五个日志，那么将发生什么情况呢？
在这种情况下，DB2 将分配另一个日志文件 — 辅助日志文件，

  归档日志记录。同样，可以从其名称知道，当使用归档日志记录时，将归档（保留）日志。在循环日志记录中，要覆盖已提交且已外部化的
事务，而在归档日志记录中，将保存它们。
  例如，如果有四个主日志，DB2 可能以如下顺序使用它们：Log #1，Log #2，Log #3，Log #4，（如果 Log #1 的所有事务都已被提
交且外部化，则将其归档），Log #5，
  （如果 Log #2 的所有事务都已被提交且外部化，则将其归档），Log #6 等。
正如您从上面的示例所看到的那样，DB2 将使四个主日志文件保持可用，并且将不重用那些已经用某些事务填满的日志文件，这些
事务已经被提交且外部化。换言之，
它不会覆盖已变成归档日志的日志。
注：在使用归档日志记录之前，需要启用它。要启用它，必须同时打开下列参数或打开其中的任意一个：

LOGRETAIN (db2 update db cfg for database_name using LOGRETAIN ON)
USEREXIT  (db2 update db cfg for database_name using USEREXIT ON)
循环日志记录仅支持崩溃和版本恢复，而归档日志记录支持所有类型的恢复：崩溃恢复、版本恢复和前滚恢复。

用户出口

我们在前几章中多次提到用户出口。用户出口是允许将联机归档日志移到另一个目录（非活动日志目录）或另一个介质的程序。当为完全数据库
恢复进行 ROLLFORWARD 操作期间需要脱机归档日志时，用户出口还会将它们检索到活动日志目录中。要启用用户出口，将 USEREXIT 数据库配置参
数设置为 ON。一旦启用，DB2 将根据需要自动调用用户出口程序。需要将该程序命名为 db2uext2，在 Windows 中，应该将它存储在 sqllib/bin
目录中，在 UNIX 中，应该将它存储在 sqllib/bin 目录中。

## 数据库和表空间备份

＃数据库备份 第 2 页（共6 页）

 


数据库备份是数据库的完整副本。除了数据外，备份副本还会包含有关表空间、容器、数据库配置、日志控制文件以及恢复历史记录文件的信息。注：备份将不存储数据库管理器配置文件或注册表变量。只备份数据库配置文件。

要执行备份，需要 SYSADM、SYSCTRL 或 SYSMAINT 权限。

下面是用于这种备份的 BACKUP 命令实用程序的语法：


BACKUP DATABASE database-alias [USER username [USING password]]
      [TABLESPACE (tblspace-name [ {,tblspace-name} ... ])] [ONLINE]
      [INCREMENTAL [DELTA]] [USE {TSM | XBSA} [OPEN num-sess SESSIONS]] |
   TO dir/dev [ {,dir/dev} ... ] | LOAD lib-name [OPEN num-sess SESSIONS]]
      [WITH num-buff BUFFERS] [BUFFER buffer-size] [PARALLELISM n]
      [WITHOUT PROMPTING]


要使用其它备份选项来执行数据库“sample”的完全脱机备份，可以使用以下命令：


(1) BACKUP DATABASE sample                     
(2)   TO /db2backup/dir1, /db2backup/dir2    
(3)   WITH 4 BUFFERS                         
(4)   BUFFER 4096                            
(5)   PARALLELISM 2                          


让我们更仔细地研究该命令：

指明要备份的数据库的名称（或别名）。
指定用来存储备份的一个或多个位置。
确定在备份操作期间可以使用内存中的多少缓冲区。使用多个缓冲区可以改善性能。
确定每个缓冲区的大小。
确定使用多少个介质阅读器／记录器进程／线程来执行备份。
注：语法中没有关键字 OFFLINE，因为这是缺省方式。要执行 sample 数据库的完全联机备份，必须指定关键字 ONLINE，如下所示：


BACKUP DATABASE sample                  
  ONLINE                              
  TO /dev/rdir1, /dev/rdir2           


我们先前提到过：联机备份允许其他用户在备份数据库时对它进行访问。这些用户所做的一些更改很可能在备份时没有存储在备份副本中。
因此，恢复时需要联机备份和一组完整的归档日志。此外，联机备份一完成，DB2 就强制当前的活动日志关闭；结果，将归档该日志。

注：联机备份要求为数据库启用归档日志记录。 DB CFG: LOGHEAD指向活动的最低编号的日志，小于LOGHEAD的日志
是归档日志且可以移动。可以使用ARCHIVE LOG 命令来对日志进行归档。

 

＃表空间备份
   在只有一些表空间有相当大更改的数据库中，可以选择不备份整个数据库，而只备份特定表空间。
要执行表空间备份，请使用以下语法：

(1) BACKUP DATABASE sample
(2) TABLESPACE ( syscatspace, userspace1, userspace2 )
(3) ONLINE
(4) TO /db2tbsp/backup1, /db2tbsp/backup2
通常，您想要将相关的表空间备份在一起，如数据，索引，LOB
  或定义了表间引用约束的表的表空间
 
  注意：此备份方式只能用于ARCHIVAL LOGGIN 环境中。

  ＃增量备份
  有两种类型的增量备份：

增量：DB2 备份自上次完全数据库备份以来所更改的所有数据。
delta：DB2 将只备份自上一次成功的完全、增量或差异备份以来所更改的数据。

注意：要执行增量备份，DB CFG中的TRACKMOD必须设置为 YES(跟踪表空间中发生变化的页面）.
  在控制中心执行备份。
 
  ＃备份文件
  磁盘上的 DB2 备份文件的命名约定包含下列几项：

数据库别名
表示备份类型的数字（0 表示完全数据库备份，3 表示表空间备份，4 表示来自 LOAD 的副本）
实例名
数据库节点（对于单一分区数据库始终是 NODE0000）
目录节点号（对于单一分区数据库始终是 CATN0000）
备份的时间戳记
映像序列号

分区数据库的备份：
In the following example, the database WSDB is defined on all 4 partitions,
numbered 0 through 3. The path /dev3/backup is accessible from all
partitions. Partition 0 is the catalog partition, and needs to be backed-up
separately since this is an offline backup. To perform an offline backup of all
the WSDB database partitions to /dev3/backup, issue the following
commands from one of the database partitions:

db2_all ’<<+0< db2 BACKUP DATABASE wsdb TO /dev3/backup’
db2_all ’|<<-0< db2 BACKUP DATABASE wsdb TO /dev3/backup’


＃＃数据库和表空间恢复
＃数据库恢复

下面是 RESTORE 命令的语法：


RESTORE DATABASE source-database-alias { restore-options | CONTINUE | ABORT }

restore-options:
  [USER username [USING password]] [{TABLESPACE [ONLINE] |
  TABLESPACE (tblspace-name [ {,tblspace-name} ... ]) [ONLINE] |
  HISTORY FILE [ONLINE]}] [INCREMENTAL [AUTOMATIC | ABORT]]
  [{USE {TSM | XBSA} [OPEN num-sess SESSIONS] |
  FROM dir/dev [ {,dir/dev} ... ] | LOAD shared-lib
  [OPEN num-sess SESSIONS]}] [TAKEN AT date-time] [TO target-directory]
  [INTO target-database-alias] [NEWLOGPATH directory]
  [WITH num-buff BUFFERS] [BUFFER buffer-size]
  [DLREPORT file-name] [REPLACE EXISTING] [REDIRECT] [PARALLELISM n]
  [WITHOUT ROLLING FORWARD] [WITHOUT DATALINK] [WITHOUT PROMPTING]


让我们研究一个示例。要执行 sample 数据库的恢复，请使用以下命令：


(1)RESTORE DATABASE sample
(2)  FROM  C:/DBBACKUP
(3)  TAKEN AT 20030314131259
(4)  WITHOUT ROLLING FORWARD
(5)  WITHOUT PROMPTING


让我们更仔细地研究该命令：

指明要恢复的数据库映像的名称。
指定要从什么位置读取输入备份文件。
如果目录中有多个备份映像，那么该选项将根据时间戳记（它是备份名称的一部分）确定特定的备份。
如果为数据库启用了归档日志记录，那么当恢复该数据库时，它将自动被置于前滚暂挂状态。这行告诉 DB2 不要使数据库处于前滚暂挂状态。
在执行 RESTORE 时，不会提示您。
请注意，语法中没有关键字 OFFLINE，因为这是缺省方式。事实上，对于 RESTORE 实用程序，这是数据库允许的唯一方式。

＃表空间恢复

表空间恢复需要相当仔细的规划，因为比较容易犯错，这会使数据处于不一致状态。

下面是表空间 RESTORE 命令的示例：


(1)RESTORE DATABASE sample
(2)  TABLESPACE ( mytblspace1 )
(3)  ONLINE
(4)  FROM /db2tbsp/backup1, /db2tbsp/backup2


让我们更仔细地研究该命令：

指明要恢复的数据库映像的名称。
指出这是表空间 RESTORE，并指定要恢复的一个或多个表空间的名称。
指出这是联机恢复。注：对于用户表空间，既允许联机恢复也允许脱机恢复。正如前面所提到的那样，对于数据库，只允许脱机恢复。
指定输入备份文件所在的位置。
表空间恢复注意事项

恢复表空间之后，它将始终处于前滚暂挂状态。要使表空间可访问并复位该状态，必须至少将表空间前滚到最小的时间点
（point in time，PIT）。该最小的 PIT 确保表空间和日志与系统目录中的内容保持一致。

请考虑下面的示例：

假设在时间 t1 您执行了完全数据库备份，该备份包括了表空间 mytbls1
在时间 t2，您在表空间 mytbls1 中创建了表 myTable。这会将表空间 mytbs1 恢复的最小 PIT 设置为 t2。
在时间 t3，您决定仅从在 t1 进行的完全数据库备份恢复表空间 mytbls1。
恢复完成之后，表空间 mytbls1 将处于前滚暂挂状态。如果允许前滚到最小 PIT 之前的某一点，则表空间 mytbls1 将失去表 myTable；然而，系统目录将显示该表确实存在于 mytbls1 中。因此，为了避免类似的不一致，DB2 会在您恢复表空间时强制您至少前滚到最小 PIT。
当针对表空间或表空间中的表运行 DDL 语句时，会更新最小的 PIT。为了确定表空间恢复的最小 PIT，可以使用下列两种方法之一：

使用 LIST TABLESPACES SHOW DETAIL 命令
通过 GET SNAPSHOT FOR TABLESPACE ON db_name 命令获取表空间快照。
另外，系统目录表空间（SYSCATSPACE）必须前滚到日志的末尾并处于脱机方式。

＃重定向恢复
我们前面提到过备份文件包括有关表空间和容器的信息。如果过去存在的容器在进行备份时不再存在时，会发生什么情况？如果 RESTORE 实用程序找不到该容器，那么您将得到一个错误。

如果您不想在这个位置恢复该备份，而想在别的位置进行恢复，但在那个地方又使用了其它配置，该怎么办？同样，在该情况下恢复备份将会产生问题。

重定向恢复解决了这些问题。重定向恢复的恢复备份过程只有四个步骤：

获取记录在输入备份中的、有关容器和表空间的信息。通过将 REDIRECT 关键字包含在 RESTORE 命令中就能完成这一任务。例如：

RESTORE DATABASE DB2CERT FROM C:/DBBACKUP
        INTO NEWDB REDIRECT WITHOUT ROLLING FORWARD

不需要事先产生数据库NEWDB
下面是该命令的输出：


SQL1277N  Restore has detected that one or more table space containers are
inaccessible, or has set their state to 'storage must be defined'.
DB20000I  The RESTORE DATABASE command completed successfully.

注意：此时已经创建了数据库NEWDB。

复查来自（部分）恢复数据库 newdb 的表空间信息：

LIST TABLESPACES SHOW DETAIL
表空间还没有产生。

为每个表空间设置新容器。表空间有一个标识，可以从 LIST TABLESPACES 命令的输出获取这个标识。如下使用该标识：

SET TABLESPACE CONTAINERS FOR 0 USING (FILE "d:/newdb/cat0.dat" 5000)
SET TABLESPACE CONTAINERS FOR 1 USING (FILE "d:/newdb/cat1.dat" 5000)
...
SET TABLESPACE CONTAINERS FOR n USING (PATH "d:/newdb2")

上面命令将产生表空间。

在上面的示例中，n 表示备份中某一个表空间的标识。另外请注意，对于重定向恢复，不能更改表空间的类型；即，如果表空间是 SMS，那么就不能将它更改为 DMS。

通过将关键字 CONTINUE 包含在 RESTORE 命令中，开始将数据本身恢复到新容器中，如下所示：

RESTORE DATABASE DB2CERT CONTINUE
现在，您已经了解了重定向恢复是如何工作的。也可以将它用于为 SMS 表空间添加容器。如果您阅读过本系列的第二篇教程，那么您应该知道在大多数情况下不能对 SMS 表空间进行修改以添加容器。重定向恢复为这一限制提供了一种变通方法。

分区数据库的恢复：：

In the following example, the database WSDB is defined on all 4 partitions,
numbered 0 through 3. The path /dev3/backup is accessible from all
partitions. The following offline backup images are available from
/dev3/backup:
wsdb.0.db2inst1.NODE0000.CATN0000.20020331234149.001
wsdb.0.db2inst1.NODE0001.CATN0000.20020331234427.001
wsdb.0.db2inst1.NODE0002.CATN0000.20020331234828.001
wsdb.0.db2inst1.NODE0003.CATN0000.20020331235235.001
To restore the catalog partition first, then all other database partitions of the
WSDB database from the /dev3/backup directory, issue the following
commands from one of the database partitions:

db2_all ’<<+0< db2 RESTORE DATABASE wsdb FROM /dev3/backup
TAKEN AT 20020331234149
INTO wsdb REPLACE EXISTING’
db2_all ’<<+1< db2 RESTORE DATABASE wsdb FROM /dev3/backup
TAKEN AT 20020331234427
INTO wsdb REPLACE EXISTING’
db2_all ’<<+2< db2 RESTORE DATABASE wsdb FROM /dev3/backup
TAKEN AT 20020331234828
INTO wsdb REPLACE EXISTING’
db2_all ’<<+3< db2 RESTORE DATABASE wsdb FROM /dev3/backup
TAKEN AT 20020331235235
INTO wsdb REPLACE EXISTING’


＃＃数据库和表空间前滚
＃数据库前滚
在上一章中，我们简要地讨论了 ROLLFORWARD 命令。在本章中，我们将更详细地讨论它。ROLLFORWARD 命令允许恢复到某一时间点；
这意味着该命令将让您遍历 DB2 日志，并重做或撤销记录在日志中的操作直到某个特定的时间点。虽然可以将数据库或表空间前滚到最小
PIT 之后的任何时间点，但不能保证您选择前滚到的结束时间将使所有数据保持一致。

我们将不在本教程中讨论 QUIESCE 命令。然而，值得提一下的是：可以在常规数据库操作期间使用该命令来设置一致性点。通过设置
这些一致性点，您可以始终执行至其中任何一点的时间点恢复，并保证数据同步。

一致性点和许多其它信息一起被记录在 DB2 历史记录文件中，可以使用 LIST HISTORY 命令来查看该文件。

在前滚处理期间，DB2 将：

在当前日志路径中查找必需的日志文件。
如果找到该日志，重新从日志文件应用事务。
如果在当前路径中找不到该日志文件，并且使用了 OVERFLOWLOGPATH 选项，那么 DB2 将在该选项指定的路径中搜索并且将使用该位置中的
日志。
如果在当前路径中找不到该日志文件并且没有使用 OVERFLOWLOGPATH 选项，则调用用户出口来检索归档路径中的日志文件。
仅当前滚完全数据库恢复并且启用了用户出口时，才会调用用户出口来检索日志文件。
一旦日志在当前日志路径或 OVERFLOWLOGPATH 中，就将重新应用事务。
执行 ROLLFORWARD 命令需要 SYSADM、SYSCTRL 或 SYSMAINT 权限。

下面是 ROLLFORWARD 命令的语法：


ROLLFORWARD DATABASE database-alias [USER username [USING password]]
[TO {isotime [ON ALL DBPARTITIONNUMS] [USING LOCAL TIME] | END OF LOGS
[On-DbPartitionNum-Clause]}] [AND {COMPLETE | STOP}] |
{COMPLETE | STOP | CANCEL | QUERY STATUS [USING LOCAL TIME]}
[On-DbPartitionNum-Clause] [TABLESPACE ONLINE | TABLESPACE (tblspace-name
[ {,tblspace-name} ... ]) [ONLINE]] [OVERFLOW LOG PATH (log-directory
[{,log-directory ON DBPARTITIONNUM db-partition-number} ... ])] [NORETRIEVE]
[RECOVER DROPPED TABLE dropped-table-id TO export-directory]

On-DbPartitionNum-Clause:
  ON {{DBPARTITIONNUM | DBPARTITIONNUMS} (db-partition-number
  [TO  db-partition-number] , ... ) | ALL DBPARTITIONNUMS [EXCEPT
  {DBPARTITIONNUM | DBPARTITIONNUMS} (db-partition-number
  [TO db-partition-number] , ...)]}


让我们研究一个示例。要执行样本数据库的前滚，可以使用下列任意一条语句：


(1)ROLLFORWARD DATABASE sample TO END OF LOGS AND COMPLETE
(2)ROLLFORWARD DATABASE sample TO timestamp AND COMPLETE
(3)ROLLFORWARD DATABASE sample TO timestamp USING LOCAL TIME AND COMPLETE


让我们仔细地研究每一条语句：

在该示例中，我们将前滚到日志的结尾，这意味着将遍历所有归档和活动日志。最终它将完成前滚并通过回滚任何未提交的事务来除去
前滚暂挂状态。
对于该示例，DB2 将前滚到指定的时间点。使用的时间戳记形式必须是 CUT（全球标准时间，Coordinated Universal Time），这可以通
过从当前时区减去本地时间来计算。
该示例类似于上一个示例，但可以用本地时间表示时间戳记。
请注意，语法中没有关键字 OFFLINE，因为这是缺省方式。事实上，对于 ROLLFORWARD 命令，这是数据库允许的唯一方式。

＃表空间前滚 第 2 页（共4 页）


表空间前滚通常可以联机或脱机。但系统目录表空间（SYSCATSPACE）是例外，它只能进行脱机前滚。

下面是一个表空间前滚示例：

ROLLFORWARD DATABASE sample
  TO END OF LOGS AND COMPLETE
  TABLESPACE ( userspace1 ) ONLINE


上面示例中的选项已经在数据库前滚一章中说明过了。这里唯一的新选项是 TABLESPACE，它指定要前滚的表空间。

表空间前滚考虑事项

如果启用注册表变量 DB2_COLLECT_TS_REC_INFO，则只处理恢复表空间所需的日志文件；ROLLFORWARD 命令将跳过不需要的日志文件，这可以加快恢复时间。
ROLLFORWARD 命令的 QUERY STATUS 选项可用于列出 DB2 已经前滚的日志文件、下一个需要的归档日志文件以及自前滚处理开始以来最后一次提交的事务的时间戳记。例如：
ROLLFORWARD DATABASE sample QUERY STATUS USING LOCAL TIME
在表空间时间点前滚操作完成后，表空间处于备份暂挂状态。必须对表空间或数据库进行备份，因为在表空间恢复到的时间点和当前时间之间对它所做的所有更新都已经丢失。

＃＃索引的重新创建
＃重建索引

如果由于一些硬件或操作系统原因而使数据库崩溃，那么在数据库重新启动阶段一些索引可能被标记为无效。配置参数 INDEXREC 确定 DB2 何时将试图重建无效索引。

INDEXREC 在数据库管理器和数据库配置文件中都进行了定义。该参数有三个可能的设置：

SYSTEM：只能在数据库配置文件中指定该值。当将 INDEXREC 设置为该值时，DB2 将查找在数据库管理器配置文件中指定的 INDEXREC 设置，并使用该值。
ACCESS：这意味着在第一次访问索引时重建无效索引。
RESTART：这意味着在数据库重新启动期间重建无效索引。


###管理服务器
get admin cfg
update admin cfg using <p> <v>


备份表空间
BACKUP DATABASE SAMPLE TABLESPACE ( USERSPACE1 ) ONLINE TO "d:/db2/" WITH 1 BUFFERS BUFFER 1024 PARALLELISM 1 WITHOUT PROMPTING;

生成表的DDL
db2look -d SAMPLE -t  MY_EMPLOYEE  -a -e  -l  -x  -c ;
包括表的统计信息的DDL
db2look -d SAMPLE -t  MY_EMPLOYEE  -a -e  -l  -x  -m  -r  -c ;

svmon

5.1 maintrcie 4
db2 fixpak 2

## 数据库空间需求
# 系统目录表的空间需求  3.5MB

# 用户表数据的空间需求
每页面255行 
4KB页面 68字节用于管理开销，4028用于数据，行长度不能超过4005字节，最多500列。
8,16,32KB 页面                                     8101,16293,32677     1012列
       估计大小公式4KB：
          (4028/(AVERAGE ROW SIZE + 10)) = RECORDS_PER_PAGE
          (NUMBER_OF_RECORDS/RECORDS_PER_PAGE)*1.1 = NUMBER_OF_PAGES
  长型字段数据的空间需求
存储在单独的表对象中。数据存储在大小为32KB的区域中。
  大对象数据的空间需求
#索引的空间的需求
（平均索引键大小＋9）×行数×2
  创建索引的临时空间需求
         （平均索引键大小＋9）×行数×3.2
对每个叶子页的平均键数的粗略估计是
#日志文件的空间需求
(logprimary + logsecond)*(logfilesiz+2)*4096
如果以对数据库启用了无限记录（logsecond 设置为－1），则必须启用userexit配置参数。
#临时空间需求
 
##分区数据库验证
  select distinct dbpartitionnum(empno) from employee;
#分区键
未指定则使用主键的第一列，无主键则使用第一个非长类型列。
选择能否使数据分布均匀及经常使用的列，可以用列的组合但不能超过16列，列越少，性能越好。
分区键不能更改，任何唯一键或主键必须包含分区键列

#表并置
需要经常进行关联的表在指定分区键时，每个分区键中对应列的数据类型必须是分区兼容的，并称为表并置
具有相同值但有不同类型的两个变量会安相同的分区算法映射至同一个分区号。
        如：INTEGER,SMALLINT,BIGINT
    REAL,FLOAT
    CHAR,VARCHAR

＃隔离级别
  隔离级确定了在数据被访问时，如何锁定数据或将数据与其它进程隔离。您可以在应用程序预编译或在
  静态 SQL 程序中绑定到数据库时指定隔离级，或者也可以将它指定为连接或语句选项。
  选择的隔离级可同时影响 DB2 选择的锁定策略和 S 行锁定可以由应用程序持有的时间。
  隔离级只应用于被读取的行。对于更改的行，应用程序需要获取一个 X 或 W 锁。无论应用程序的隔离级是什么，
  X 或 W 锁在回滚或提交之前不被释放。 
