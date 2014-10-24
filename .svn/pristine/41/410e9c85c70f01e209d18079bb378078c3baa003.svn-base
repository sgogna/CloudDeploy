#!/usr/bin/ksh

if  [ $# -eq 0 ] || [ $# -eq 1 ] || ([ $# -ne 2 ] && ([ $3 != "-e" ] && [ $3 != "-i" ]));
then
  echo "Usage: `basename $0` {SOURCE_SCHEMA} {DESTINATION_SCHEMA}"
  echo "   eg: ReplicateSchema.sh SSW2010_VX_1 SSW2010_7F_1"
  echo "   eg: ReplicateSchema.sh SSW2010_CY_1 SSW2010_CY_1_LOAD"
  echo ""
  echo "For export only you should add -e parameter:"
  echo "Usage: `basename $0` {SOURCE_SCHEMA} {FILE_NAME} -e"
  echo "   eg: ReplicateSchema.sh SSW2010_VX_1 SSW2010_VX_1 -e"
  echo ""
  echo "For import only you should add -i parameter and file name:"
  echo "Usage: `basename $0` {SOURCE_SCHEMA} {DESTINATION_SCHEMA} -i {FILE_NAME} "
  echo "   eg: ReplicateSchema.sh SSW2010_VX_1 SSW2010_7F_1 -i SSW2010_VX_1"
  exit 0

fi
export	ORACLE_SID=SSWBEI11
export	ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/db_1
export	NLS_LANG=AMERICAN_AMERICA.UTF8
export	PATH=$ORACLE_HOME/bin:$PATH
export  DATE=`date +"%m/%d/%Y"`
export  EMAIL="deepak.z.singh.ctr@sabre.com"

if [ $# -eq 2 ] || ([ $# -gt 2 ] && [ $3 != "-e" ])

then 
export SOURCE_SCHEMA_OWNER=$1_OWNER
export DEST_SCHEMA_OWNER=$2_OWNER
export SOURCE_SCHEMA_USER=$1_USER
export DEST_SCHEMA_USER=$2_USER
export FILE_NAME=$4
fi

if [ $# -gt 2 ] && [ $3 = "-e" ]
then 
export SOURCE_SCHEMA_OWNER=$1_OWNER
export SOURCE_SCHEMA_USER=$1_USER
export FILE_NAME=$2
fi

if [ $# -eq 2 ] || ([ $# -gt 2 ] && [ $3 != "-e" ])
then

# Validate for proper source and target
if	[ `echo $1 | grep "OWNER" | wc -l` -gt 0 ];	 then
	echo 	"Check SOURCE schema name, it cannot contain OWNER! Exiting!"
	exit 1
fi
if	[ `echo $1 | grep "USER" | wc -l` -gt 0 ];	 then
	echo 	"Check SOURCE schema name, it cannot contain USER! Exiting!"
	exit 1
fi
if	[ `echo $2 | grep "OWNER" | wc -l` -gt 0 ];	 then
	echo 	"Check TARGET schema name, it cannot contain OWNER! Exiting!"
	exit 1
fi
if	[ `echo $2 | grep "USER" | wc -l` -gt 0 ];	 then
	echo 	"Check TARGET schema name, it cannot contain USER! Exiting!"
	exit 1
fi
if	[ `echo $4 | grep ".dmp" | wc -l` -gt 0 ];	 then
	echo 	"Check FILE_NAME , it cannot contain ".dmp" ! Exiting!"
	exit 1
fi


if
	[ $1 = $2 ];	then
	echo "Source and destination cannot be the same! Exiting!"
	exit 1
fi

fi

if [ $# -gt 2 ] && [ $3 = "-e" ]
then

# Validate for proper source and target
if	[ `echo $1 | grep "OWNER" | wc -l` -gt 0 ];	 then
	echo 	"Check SOURCE schema name, it cannot contain OWNER! Exiting!"
	exit 1
fi
if	[ `echo $1 | grep "USER" | wc -l` -gt 0 ];	 then
	echo 	"Check SOURCE schema name, it cannot contain USER! Exiting!"
	exit 1
fi
if	[ `echo $2 | grep ".dmp" | wc -l` -gt 0 ];	 then
	echo 	"Check FILE_NAME , it cannot contain .dmp ! Exiting!"
	exit 1

fi

fi
if [ $# -eq 2 ] || ([ $# -gt 2 ] && [ $3 != "-i" ])
then

USERCNT=`${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
set serveroutput on
set pages 0
set heading off
set feedback off 

select	count(*) from sys.dba_users where username = '${SOURCE_SCHEMA_OWNER}';

EOF`

if	[ ${USERCNT} -le 0 ];	 then
	echo 	"Source schema does not exist! Exiting!"
	exit 1
fi
fi

if [ $# -eq 2 ] || ([ $# -gt 2 ] && [ $3 != "-e" ])

then

USERCNT_DEST=`${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
set serveroutput on
set pages 0
set heading off
set feedback off

select  count(*) from sys.dba_users where username = '${DEST_SCHEMA_OWNER}';

EOF`

if      [ ${USERCNT_DEST} -le 0 ];    then
        echo    "Destination schema does not exist! Please contact with DBAs. Exiting!"
        exit 1
fi

fi

if [ "$uname" == "" ] || [ "$pcode" == "" ]; then
	/bin/echo ""
	/bin/echo -n "Enter username: "
	read uname
	/bin/echo ""
	/bin/echo -n "Enter password: "
	read pcode
else
	echo "Parameterized credentials used..."
fi



USERCNT=`${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
set serveroutput on
set pages 0
set heading off
set feedback off 
	select	dba_tools.user_check('$uname','$pcode')
	from 	dual;
EOF`

if	[ ${USERCNT} -le 0 ];	 then
	/bin/echo ""
	echo 	"Incorrect username/passcode! Exiting!"
	exit 1
fi

if [ $# -eq 2 ] || ([ $# -gt 2 ] && [ $3 != "-e" ])

then

if [ "$answer" == "" ]
then
/bin/echo ""
/bin/echo "!!! IMPORTANT: Please note TARGET data will be lost... !!!"
/bin/echo ""
/bin/echo -n "< Source:${SOURCE_SCHEMA_OWNER}; Target:${DEST_SCHEMA_OWNER} > Are you sure? [enter Y to continue]: "
read answer
fi

if [ "$answer" != "Y" ]
then
	echo	"Exiting!"
	exit 1
 
fi


#${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
#set serveroutput on
#set time on
#set timing on
#alter user ${DEST_SCHEMA_OWNER} identified by abc123;
#alter user ${DEST_SCHEMA_USER} identified by abc123;
#EOF

${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
set serveroutput on
set time on
set timing on
--exec dba_tools.dropUser(destinationSchema => '${DEST_SCHEMA_OWNER}');
--exec dba_tools.dropUser(destinationSchema => '${DEST_SCHEMA_USER}');
exec dba_tools.cleanSchema(destinationSchema => '${DEST_SCHEMA_OWNER}');
exec dba_tools.cleanSchema(destinationSchema => '${DEST_SCHEMA_USER}');
EOF

fi

if [ $# -eq 2 ]
then

${ORACLE_HOME}/bin/expdp dba_tools_user/dba_tools_user DIRECTORY=EXP_SCHEMA_TOOL_DIR dumpfile=${SOURCE_SCHEMA_OWNER}.dmp logfile=${SOURCE_SCHEMA_OWNER}.LOG schemas=${SOURCE_SCHEMA_OWNER},${SOURCE_SCHEMA_USER} exclude=statistics flashback_time=sysdate REUSE_DUMPFILES=Y

${ORACLE_HOME}/bin/impdp dba_tools_user/dba_tools_user DIRECTORY=EXP_SCHEMA_TOOL_DIR full=Y dumpfile=${SOURCE_SCHEMA_OWNER}.dmp logfile=${DEST_SCHEMA_OWNER}.impdp.LOG content=ALL remap_schema=${SOURCE_SCHEMA_OWNER}:${DEST_SCHEMA_OWNER},${SOURCE_SCHEMA_USER}:${DEST_SCHEMA_USER}

fi


if [ $# -gt 2 ] && [ $3 = "-e" ]
then 

${ORACLE_HOME}/bin/expdp dba_tools_user/dba_tools_user DIRECTORY=EXP_SCHEMA_TOOL_DIR dumpfile=${FILE_NAME}.dmp logfile=${FILE_NAME}.LOG schemas=${SOURCE_SCHEMA_OWNER},${SOURCE_SCHEMA_USER} exclude=statistics flashback_time=sysdate REUSE_DUMPFILES=Y

echo "File name for schema ${SOURCE_SCHEMA_OWNER} is ${FILE_NAME}.dmp"

fi


if [ $# -gt 2 ] && [ $3 = "-i" ]
then 

${ORACLE_HOME}/bin/impdp dba_tools_user/dba_tools_user DIRECTORY=EXP_SCHEMA_TOOL_DIR dumpfile=${FILE_NAME}.dmp logfile=${DEST_SCHEMA_OWNER}.impdp.LOG schemas=${SOURCE_SCHEMA_OWNER},${SOURCE_SCHEMA_USER} remap_schema=${SOURCE_SCHEMA_OWNER}:${DEST_SCHEMA_OWNER},${SOURCE_SCHEMA_USER}:${DEST_SCHEMA_USER}

echo "Schemas ${SOURCE_SCHEMA_OWNER}, ${SOURCE_SCHEMA_USER} imported as ${DEST_SCHEMA_OWNER}, ${DEST_SCHEMA_USER} from file ${FILE_NAME}.dmp  "

fi




if [ $# -gt 2 ] && [ $3 != "-e" ]
then

${ORACLE_HOME}/bin/sqlplus -s "dba_tools_user/dba_tools_user" << EOF
set serveroutput on
set time on
set timing on
alter user ${DEST_SCHEMA_OWNER} identified by ${DEST_SCHEMA_OWNER};
alter user ${DEST_SCHEMA_USER} identified by ${DEST_SCHEMA_USER};
EOF

fi

if [ $# -eq 2 ]
then
mailx -s "INT1 ReplicateSchema($uname): ${SOURCE_SCHEMA_OWNER}/${SOURCE_SCHEMA_USER} to ${DEST_SCHEMA_OWNER}/${DEST_SCHEMA_USER} completed at ${DATE}" ${EMAIL} < /dev/null
fi

if [ $# -gt 2 ] && [ $3 = "-i" ]
then
mailx -s "INT1 ReplicateSchema($uname) only import from file ${FILE_NAME}.dmp  : ${SOURCE_SCHEMA_OWNER}/${SOURCE_SCHEMA_USER} to ${DEST_SCHEMA_OWNER}/${DEST_SCHEMA_USER} completed at ${DATE}" ${EMAIL} < /dev/null
fi


if [ $# -gt 2 ] && [ $3 = "-e" ]
then
mailx -s "INT1 ReplicateSchema($uname) only export to file ${FILE_NAME}.dmp  : ${SOURCE_SCHEMA_OWNER}/${SOURCE_SCHEMA_USER}  completed at ${DATE}" ${EMAIL} < /dev/null
fi




