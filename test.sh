#!/bin/ksh

sourceOwner=SSW2010_VA_4_OWNER

		export ORACLE_SID=XE
		export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
		export NLS_LANG=AMERICAN_AMERICA.UTF8
		export PATH=$ORACLE_HOME/bin:$PATH

USERCNT_DEST=`${ORACLE_HOME}/bin/sqlplus -s "system/sabresonic" << EOF
set serveroutput on
		set pages 0
		set heading off
		set feedback off
		SELECT count(*) tablespace_name FROM dba_tablespaces WHERE tablespace_name =UPPER('${sourceOwner}');
EOF`

if      [ ${USERCNT_DEST} -le 0 ];    then
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