#!/usr/bin/ksh

sourceUser=$1 
sourceOwner=$2
cloudUserName=$3 
cloudDbServerDns=$4
sourceUserPass=$5
sourceOwnerPass=$6


		echo "sourceUser ::::: " ${sourceUser}
		echo "sourceOwner ::::: " ${sourceOwner}
		echo "cloudUserName ::::: " ${cloudUserName}
		echo "cloudDbServerDns ::::: " ${cloudDbServerDns}
		
		export	ORACLE_SID=SSWBEI11
		export  ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/db_1
		export  NLS_LANG=AMERICAN_AMERICA.UTF8
		export  PATH=$ORACLE_HOME/bin:$PATH
	
		if [ -f /u950/SSWDBA/schemarepltool/${sourceOwner}.dmp ]; then
		echo "Cleaning Old Database Dump for ${sourceOwner} and ${sourceUser}......"
		rm -R /u950/SSWDBA/schemarepltool/${sourceOwner}.dmp
		echo "Done cleaning of Dump"
		fi
		
		echo "Taking Database Dump for ${sourceOwner} and ${sourceUser}......"
		${ORACLE_HOME}/bin/expdp dba_tools_user/dba_tools_user DIRECTORY=EXP_SCHEMA_TOOL_DIR dumpfile=${sourceOwner}.dmp logfile=${sourceOwner}.LOG schemas=${sourceOwner},${sourceUser} exclude=statistics flashback_time=sysdate REUSE_DUMPFILES=Y
		#${ORACLE_HOME}/bin/exp USERID=dba_tools_user/dba_tools_user statistics=none FILE=/u950/SSWDBA/schemarepltool/${sourceOwner}.dmp log=/u950/SSWDBA/schemarepltool/${sourceOwner}.log owner=${sourceOwner},${sourceUser}
		echo "Done taking dump ${sourceOwner}.dmp"
		
		if [ 'ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudDbServerDns} -f /u01/tmp/${sourceOwner}.dmp' ]; then
		echo "Deleting /u01/app/oracle/admin/XE/dpdump/${sourceOwner}.dmp from ${cloudUserName}@${cloudDbServerDns}"  
		ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudDbServerDns} rm -R /u01/tmp/${sourceOwner}.dmp
		fi
		
		echo "Copying the database dump  ${sourceOwner}.dmp to ${cloudUserName}@${cloudDbServerDns}......."
		scp -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config /u950/SSWDBA/schemarepltool/${sourceOwner}.dmp ${cloudUserName}@${cloudDbServerDns}:/u01/tmp/.
		echo "Done Copying Dmp to ${cloudUserName}@${cloudDbServerDns}:/u01/tmp/${sourceOwner}.dmp"
	