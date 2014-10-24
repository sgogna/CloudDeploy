#!/bin/sh
#
# Usage: deployer.sh configFile
#
if [ "$#" -ne "1" ]; then
echo "Usage: $0 configFile"
exit 1
fi

if
	[ $1 = $2 ];	then
	echo "Source and destination cannot be the same! Exiting!"
	exit 1
fi

# make sure script terminates immediately in case of errors
failFast=false
# load utils.sh library
. ./utils.sh
# parse config file
copySchema=false
oobTempDir=/tmp/SSW2010
parseConfigFile $*
serverStartupCmd="/nas/sabre/int/bin/tomcat SSW ${TOMCATINSTANCE} start-clean &"
serverShutdownCmd="/nas/sabre/int/bin/tomcat SSW ${TOMCATINSTANCE} stop-clean 30"
hdateformat=$(date '+%Y-%m-%d-%H-%M-%S')
webBackupCmd="cp -R $webServerDestDir/ ${webServerBackup}/${hdateformat}" 
appBackupCmd="cp -R $appServerDestDir/ ${appServerBackup}/${hdateformat}"
schema_owner="SSW2010_${airline_code}_${DBINST}_MOB_OWNER"
schema_user="SSW2010_${airline_code}_${DBINST}_MOB_USER"
default_airline_code="XX"
airline_code_lowercase=$( echo "$airline_code" | tr -s  '[:upper:]'  '[:lower:]' )

bar="\n========================================================\n"
echo -e $bar
echo "parseConfigFile: $parseConfigFile"
echo "webServerSrcDir: $webServerSrcDir"
echo "appServerSrcDir: $appServerSrcDir"
echo "serverStartupCmd: $serverStartupCmd"
echo "serverShutdownCmd: $serverShutdownCmd"
echo -e $bar

echo "Shutting down T1 server..."
executeCmd $webServer $serverShutdownCmd
echo "Servers T1 shut down."
echo "Shutting down T2 server..."
executeCmd $appServer $serverShutdownCmd
echo "Servers T2 shut down."

#Run Dataloader
executeCmd $appServer "$appServerDatalaoder $default_airline_code $DATALOADER_DIR $APPCONF_DIR $schema_user $schema_owner $airline_code"
if [ "$?" = "0" ]; then
	echo "Datalaoder Successful"
else	
echo "Airline Already Exist"
echo "Starting T2 server..."
executeCmd $appServer $serverStartupCmd
echo "Server T2 is up."

echo "Starting T1 server..."
executeCmd $webServer $serverStartupCmd
echo "Server T1 is up."
exit 0
fi


#Update configured-airlines-environment.properties
executeCmd $appServer "sed -i -e 's/configuredAirlines\s*=\s*/configuredAirlines = $airline_code,/g' $appServerConfig"
executeCmd $appServer "sed -i -e 's/xx.database/$airline_code_lowercase.database/g' $appServerConfig"
executeCmd $appServer "sed -i -e 's/xx.quartz/$airline_code_lowercase.quartz/g' $appServerConfig"




#Execute DB Queries for Change Default Storefront Name
executeCmd $dbserver "$StorefrontSetupScriptPATH $schema_owner $STOREFRONTS $airline_code"

echo "Starting T2 server..."
executeCmd $appServer $serverStartupCmd
echo "Server T2 is up."

echo "Starting T1 server..."
executeCmd $webServer $serverStartupCmd
echo "Server T1 is up."

sleep 3m

Run Export/Import Flows
echo "Run Export/Import Flows"
executeCmd $appServer "$appServerFlows $airline_code $source_app_server $source_jmx_port $source_storefront $source_version $HOST $JMXPORT $STOREFRONTS"
echo "Export/Import Flows Successful"
   
   
#Run Generate Resources
echo "Generating Resources"
executeCmd $webServer "$webServerGenerateReources $WEBHOST $JMXPORT $STOREFRONTS"

echo "Generating Resources Successful"

echo
echo "Storefont Setup done."
echo
exit 0
