#!/bin/ksh
		sourceUser=$1 
		sourceOwner=$2
		cloudUserName=$3 
		cloudDbServerDns=$4
		sourceUserPass=$5
		sourceOwnerPass=$6
		echo "sourceUser ::::: " ${sourceUser}
		echo "sourceUserPass ::::: " ${sourceUserPass}
		echo "sourceOwner ::::: " ${sourceOwner}
		echo "sourceOwnerPass ::::: " ${sourceOwnerPass}
		echo "cloudUserName ::::: " ${cloudUserName}
		echo "cloudDbServerDns ::::: " ${cloudDbServerDns}
		export ORACLE_SID=XE
		export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
		export NLS_LANG=AMERICAN_AMERICA.UTF8


		USERCNT_TAB=`${ORACLE_HOME}/bin/sqlplus -s "system/sabresonic" << EOF
set serveroutput on
		set pages 0
		set heading off
		set feedback off
		SELECT count(*) tablespace_name FROM dba_tablespaces WHERE tablespace_name =UPPER('${sourceOwner}');
EOF`

if      [ ${USERCNT_TAB} -le 0 ];    then
 				echo    "Tabel space ${sourceOwner} does not exist! Creating Tabel Space ${sourceOwner}!"
				USERCNT_TAB=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				create tablespace ${sourceOwner} datafile '${sourceOwner}.dbf' size 20M autoextend on;
				EOF`
				echo "Done creating users SSW2010_EY_3_OWNER" 
		else
				echo "Tabel space ${sourceOwner} already exist! Droping tabel space and creating it again !!"
				USERCNT_TAB=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				drop tablespace ${sourceOwner} INCLUDING CONTENTS and DATAFILES;
				create tablespace ${sourceOwner} datafile '${sourceOwner}.dbf' size 20M autoextend on;
				EOF`	
fi		
		
USERCNT_DEST=`${ORACLE_HOME}/bin/sqlplus -s "system/sabresonic" << EOF
set serveroutput on
set pages 0
set heading off
set feedback off
SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME=UPPER('${sourceOwner}');
EOF`

if      [ ${USERCNT_DEST} -le 0 ];    then
 				echo    "User ${sourceOwner} does not exist! Creating User ${sourceOwner}!"
				USERCNT_DEST=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				create user ${sourceOwner} identified by ${sourceOwnerPass} default tablespace ${sourceOwner} quota unlimited on ${sourceOwner};
				grant connect,resource to ${sourceOwner};
				grant create any synonym to ${sourceOwner};
				CREATE OR REPLACE DIRECTORY dump_dir AS '/u01/tmp/';
				GRANT READ, WRITE ON DIRECTORY dump_dir TO ${sourceOwner};
				EOF`
				echo "Done creating users ${sourceOwner}" 
		else
				echo "User ${sourceOwner} already exists!"
				echo "Dropping User ${sourceUser} and then Creating User again"
				USERCNT_DEST=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				drop tablespace ${sourceOwner} INCLUDING CONTENTS and DATAFILES;
				drop user ${sourceOwner} cascade;
				create tablespace ${sourceOwner} datafile '${sourceOwner}.dbf' size 20M autoextend on;
				create user ${sourceOwner} identified by ${sourceOwnerPass} default tablespace ${sourceOwner} quota unlimited on ${sourceOwner};
				grant connect,resource to ${sourceOwner};
				grant create any synonym to ${sourceOwner};
				CREATE OR REPLACE DIRECTORY dump_dir AS '/u01/tmp/';
				GRANT READ, WRITE ON DIRECTORY dump_dir TO ${sourceOwner};
				EOF`	
fi		

USERCNT_USER=`${ORACLE_HOME}/bin/sqlplus -s "system/sabresonic" << EOF
set serveroutput on
set pages 0
set heading off
set feedback off
SELECT COUNT(*) FROM ALL_USERS WHERE USERNAME=UPPER('${sourceUser}');
EOF`

if      [ ${USERCNT_USER} -le 0 ];    then
 				echo    "User does not exist! Creating User!"
				USERCNT_USER=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				create user ${sourceUser} identified by ${sourceUserPass} default tablespace ${sourceOwner} quota unlimited on ${sourceOwner};
				grant connect to ${sourceUser};
				grant create any synonym to ${sourceUser};
				EOF`
				echo "Done creating users ${sourceUser}" 
		else
				echo "User ${sourceUser} already exists!" 
				echo "Dropping User ${sourceUser} and then Creating User again"
				USERCNT_USER=`${ORACLE_HOME}/bin/sqlplus "system/sabresonic" << EOF
				drop user ${sourceUser} cascade;
				create user ${sourceUser} identified by ${sourceUserPass} default tablespace ${sourceOwner} quota unlimited on ${sourceOwner};
				grant connect to ${sourceUser};
				grant create any synonym to ${sourceUser};
				EOF`
fi

	sleep 1m
	echo "importing database for ${sourceOwner} and  !!!!"
	
	${ORACLE_HOME}/bin/impdp SYSTEM/sabresonic full=Y DIRECTORY=dump_dir dumpfile=${sourceOwner}.dmp logfile=${sourceOwner}.impdp.LOG content=ALL remap_schema=${sourceOwner}:${sourceOwner},${sourceUser}:${sourceUser} remap_tablespace=DATA_TBS:${sourceOwner}

	