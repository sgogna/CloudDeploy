#!/bin/bash
sourceInstance=$1
cloudServerDns=$2
storefronts=$3
staticContent=$4
generateResources=$5
copySchema=$6
backupWebapps=$7
dbBox=$8
airlines=$9
deploy=${10}
deployWar=${11}
runDataLoader=${12}
cleanEnviorment=${13}


failFast=true

######Hard Coding few things
cloudServerPort=8083
#usgEndPoint=https://sws-crt.cert.sabre.com/
exportSchemaScriptPath=/home/res2/dbscript/cloudSchema.sh
importSchemaScriptPath=/home/ec2-user/dbscript/impCloudSchema.sh
cloudUserName=ec2-user
#cloudDbServerDns=ec2-23-23-37-155.compute-1.amazonaws.com
cloudDbServerDns=ec2-54-226-182-74.compute-1.amazonaws.com
#cloudDbServerInternalDns=ip-10-232-64-199.ec2.internal
cloudDbServerInternalDns=ip-10-147-206-95.ec2.internal
jmxPortCloud=9001
oobServer=res2@fsehlp04
intBox=res2@sswhli474
hdateformat=$(date '+%Y-%m-%d-%H-%M-%S')
webApplications=("SSW2010" "SSW2010.admin" "SSW2010.stan")
applications=("SSW2010.server")
appconfSrcDirectory=/nas/sabre/int/config/int/clusters/int${sourceInstance}/SSW2010-app-int/appconf
webconfSrcDirectory=/nas/sabre/int/config/int/clusters/int${sourceInstance}/SSW2010-web-int/appconf
appconfDestDirectory=/opt/apache-tomcat-7.0.39/inst/inst2/lib
webconfDestDirectory=/opt/apache-tomcat-7.0.39/inst/inst1/lib
webServerSrcDir=/nas/sabre/int/config/int/clusters/int${sourceInstance}/SSW2010-web-int/deploy
appServerSrcDir=/nas/sabre/int/config/int/clusters/int${sourceInstance}/SSW2010-app-int/deploy
webServerDestDirDeploy=/opt/apache-tomcat-7.0.39/inst/inst1/deploy
webServerDestDirWebapp=/opt/apache-tomcat-7.0.39/inst/inst1/webapps
appServerDestDirDeploy=/opt/apache-tomcat-7.0.39/inst/inst2/deploy
appServerDestDirWebapp=/opt/apache-tomcat-7.0.39/inst/inst2/webapps
webServerBackup=/opt/apache-tomcat-7.0.39/inst/inst1//backup
appServerBackup=/opt/apache-tomcat-7.0.39/inst/inst2/backup
srcSSW2010_DATA_DIR=/nas/sabre/int/config/int/clusters/int${sourceInstance}/SSW2010-web-int/webapps/SSW2010_DATA_DIR
destSSW2010_DATA_DIR=/opt/apache-tomcat-7.0.39/inst/inst1/webapps/SSW2010_DATA_DIR
sedSSW2010_DATA_DIR=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR
########################################Echo all variables
echo "sourceInstance:::: " $sourceInstance
echo "cloudServerDns::::  "  $cloudServerDns
echo "storefronts::::  "  $storefronts
echo "staticContent::::  "  $staticContent
echo "generateResources::::  "  $generateResources
echo "copySchema::::  " $copySchema
echo "backupWebapps:::::  "  $backupWebapps
echo "airlines:::::  "  $airlines
echo "deploy:::::  "  $deploy
echo "deployWar:::::  "  $deployWar
echo "runDataLoader:::::  "  $runDataLoader
echo "cleanEnviorment:::::  "  $cleanEnviorment

##Shut Down tomcat on cloud
stopTomcat()
{
	echo "Shutting down T1 server..."
	executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} /opt/apache-tomcat-7.0.39/bin/tomcat 1 stop-clean"
	echo "Servers T1 shut down."
	echo "Shutting down T2 server..."
	executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} /opt/apache-tomcat-7.0.39/bin/tomcat 2 stop-clean"
	echo "Servers T2 shut down."
}
##Start tomcat on cloud
startTomcat(){
	echo "Starting T2 server..."
	executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} /opt/apache-tomcat-7.0.39/bin/tomcat 2 start-clean"
	echo "Server T2 is up."
	echo "Starting T1 server..."
	executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} /opt/apache-tomcat-7.0.39/bin/tomcat 1 start-clean"
	#Sleep for 6 minutes to make sure tomcat is up and running.....
	sleep 6m
	echo "Server T1 is up."
}

#Deploy Process

#explode and deploy war files for T1
deployWarWeb(){
## clean deploy folder###
if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${webServerDestDirDeploy} 2>/dev/null)" == "" ]; then
echo "clean deploy folder on :::: " ${cloudUserName}@${cloudServerDns}   
ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${webServerDestDirDeploy}/*
fi
##clean webapp directory##

if [ -s SSW2010.* ]; then
echo "clean webapp folder on :::: " ${cloudUserName}@${cloudServerDns}  "  " ${webServerDestDirWebapp}/SSW2010*  
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${webServerDestDirWebapp}/SSW2010.*
fi

if [ -d SSW2010]; then
echo "clean webapp folder on :::: " ${cloudUserName}@${cloudServerDns}  "  " ${webServerDestDirWebapp}/*  
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${webServerDestDirWebapp}/SSW2010
fi
##Clean T1 Log Files
if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A /opt/apache-tomcat-7.0.39/inst/inst1/logs/ 2>/dev/null)" == "" ]; then
echo "clean T2 logs from :::: " ${cloudUserName}@${cloudServerDns} 
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R /opt/apache-tomcat-7.0.39/inst/inst1/logs/*
fi
echo "Copying deployment artifacts in T1..."
for webApplication in "${webApplications[@]}"; do
### copy war files to destination deploy folder
echo "copy war files to destination deploy folder :::: " ${cloudUserName}@${cloudServerDns} "  " ${webServerDestDirDeploy}/${webApplication}.war
executeCmd ${intBox} scp -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${webServerSrcDir}/${webApplication}.war ${cloudUserName}@${cloudServerDns}:${webServerDestDirDeploy}/${webApplication}.war
## explode war to webapp directory##
echo "Exploading    :::::   "  ${webServerDestDirDeploy}/${webApplication}.war
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} unzip -o ${webServerDestDirDeploy}/${webApplication}.war -d ${webServerDestDirWebapp}/${webApplication}/
done
echo "Deployment artifacts copied in T1."
}

deployWarServer(){
## clean deploy folder###
if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${appServerDestDirDeploy} 2>/dev/null)" == "" ]; then
echo "clean deploy folder on :::: " ${cloudUserName}@${cloudServerDns} ":::: folder  "  ${appServerDestDirDeploy}
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${appServerDestDirDeploy}/*
fi
##clean webapp directory##
if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${appServerDestDirWebapp} 2>/dev/null)" == "" ]; then
echo "clean deploy folder on :::: " ${cloudUserName}@${cloudServerDns} ":::: folder  "  ${appServerDestDirWebapp}
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${appServerDestDirWebapp}/*
fi
if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A /opt/apache-tomcat-7.0.39/inst/inst2/logs/ 2>/dev/null)" == "" ]; then
echo "clean T2 logs from :::: " ${cloudUserName}@${cloudServerDns} 
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R /opt/apache-tomcat-7.0.39/inst/inst2/logs/*
fi
echo "Copying deployment artifacts in T2..."
for application in "${applications[@]}"; do
### copy war files to destination deploy folder
executeCmd ${intBox} scp -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${appServerSrcDir}/${application}.war  ${cloudUserName}@${cloudServerDns}:${appServerDestDirDeploy}/${application}.war
## explode war to webapp directory##
executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} unzip -o ${appServerDestDirDeploy}/${application}.war -d ${appServerDestDirWebapp}/${application}/
done
echo "Deployment artifacts copied in T2."
}

#Copy static content and then generate resources
copyStaticContent(){
echo "Copying static content from ${srcSSW2010_DATA_DIR}/userData to ${destSSW2010_DATA_DIR}/userData.."
echo "storefronts :$storefronts"
IFS=,
storefront=($storefronts)
for (( i=0; i<${#storefront[@]}; i++ ))
do
	echo "storefront :${storefront[$i]}"
	echo "Try to find directory :::: " ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}
		if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${destSSW2010_DATA_DIR}/userData/${storefront[$i]} 2>/dev/null)" == "" ];
	then
	   echo "Deleting Directory for Static Folder ::::::  " ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}	
	   executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} rm -R ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}"
	   echo "After Deleting Creating Directory for Static Folder ::::::  " ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}
	   executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} mkdir -p ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}"
	else
	echo "Creating Directory for Static Folder ::::::  " ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}	
	   executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} mkdir -p ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}"
	fi
	## Copy the static directory 
	echo "Copy the static directory to ::::::  " ${destSSW2010_DATA_DIR}/userData/${storefront[$i]}/	
	executeCmd ${intBox} "scp -r -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${srcSSW2010_DATA_DIR}/userData/${storefront[$i]}/*  ${cloudUserName}@${cloudServerDns}:${destSSW2010_DATA_DIR}/userData/${storefront[$i]}/"
done
echo "Done Copying static content from ${srcSSW2010_DATA_DIR}/userData to ${destSSW2010_DATA_DIR}/userData.."
}

### It will generate the resources after tomcat is up and running...
generateResources()
{
	echo "Generating Resources for all storefronts"
	echo "storefronts :  ${storefronts}"
IFS=,
	storefront=($storefronts)
	for (( i=0; i<${#storefront[@]}; i++ ))
	do
		echo "Generating Resources for storefront :::: ${storefront[$i]}"
		executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} java -jar /opt/apache-tomcat-7.0.39/cmdline-jmxclient-0.10.3.jar - ${cloudServerDns}:${jmxPortCloud} SSW2010:path=front,name=configurationProvider generateResourcesForStorefront=${storefront[$i]}";
		echo "Done Generating Resources for storefront :::: ${storefront[$i]}"
	done	
}

#####Update the properties and config files
updateProperties()
{
	echo "Cleaning " ${cloudUserName}@${cloudServerDns}:${appconfDestDirectory}
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "rm -r ${appconfDestDirectory}/*"
	
	###Copy configured-airlines-environment.properties file to cloud lib directory
	echo "Copying properties to" ${cloudUserName}@${cloudServerDns}:${appconfDestDirectory}
	executeCmd ${intBox} "scp -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config -r ${appconfSrcDirectory}/* ${cloudUserName}@${cloudServerDns}:${appconfDestDirectory}/."
	
	echo "Cleaning " ${cloudUserName}@${cloudServerDns}:${webconfDestDirectory}
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "rm -r ${webconfDestDirectory}/*"
	
	echo "Copying properties to" ${cloudUserName}@${cloudServerDns}:${webconfSrcDirectory}
	executeCmd ${intBox} "scp -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config -r ${webconfSrcDirectory}/* ${cloudUserName}@${cloudServerDns}:${webconfDestDirectory}/."
	
	sleep 1m
	
	#Edit the properties file 
	echo "Editing configured-airlines-environment.properties "
	echo "Adding database to configured-airlines-environment.properties"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/default.database.host.*/default.database.host=${cloudDbServerInternalDns}/g' ${appconfDestDirectory}/configured-airlines-environment.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/default.database.port.*/default.database.port=1521/g' ${appconfDestDirectory}/configured-airlines-environment.properties" 

	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/default.database.name.*/default.database.name=XE/g' ${appconfDestDirectory}/configured-airlines-environment.properties" 

	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/default.database.url.*/default.database.url=jdbc:oracle:thin:@\/\/${cloudDbServerInternalDns}:1521\/XE/g' ${appconfDestDirectory}/configured-airlines-environment.properties" 

	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/default.quartz.database.url.*/default.quartz.database.url=jdbc:oracle:thin:@\/\/${cloudDbServerInternalDns}:1521\/XE/g' ${appconfDestDirectory}/configured-airlines-environment.properties" 
	echo "Done adding database to configured-airlines-environment.properties"
	
	echo "Adding airlines ${airlines} to configured-airlines-environment.properties"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/configuredAirlines.*/configuredAirlines=${airlines}/g' ${appconfDestDirectory}/configured-airlines-environment.properties" 
	echo "done adding airlines to configured-airlines-environment.properties"
	
	echo "Done Editing configured-airlines-environment.properties "	
	
	echo "Editing server-env.properties "
	
	echo "Adding database to server-env.properties"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/core.main.dataSource.url.*/core.main.dataSource.url=jdbc:oracle:thin:@\/\/${cloudDbServerInternalDns}:1521\/XE/g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	echo "Adding usg endpoints to server-env.properties"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/gds.sabre.ws.endpoint.*/gds.sabre.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/gds.sabre.ppp.ws.endpoint.*/gds.sabre.ppp.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/gds.sabre.ci.ws.endpoint.*/gds.sabre.ci.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/gds.sabre.ws.mts.endpoint.*/gds.sabre.ws.mts.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/usg.ws.endpoint.*/usg.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/usg.ppp.ws.endpoint.*/usg.ppp.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/usg.ci.ws.endpoint.*/usg.ci.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/usg.ws.mts.endpoint.*/usg.ws.mts.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/usg.mts.ws.endpoint.*/usg.mts.ws.endpoint=https:\/\/sws-crt.cert.sabre.com\//g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw2010.server.ibe.resourcePath.*/ssw2010.server.ibe.resourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR/g' ${appconfDestDirectory}/SSW2010/server-env.properties"
	echo "Done editing usg endpoints to server-env.properties"
	
	echo "Editing ssw2010-admin-env.properties in ${cloudUserName}@${cloudServerDns} "
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/qtrip.api.url.base.*/qtrip.api.url.base=${cloudServerDns}\/SSW2010.server/g' ${webconfDestDirectory}/ssw2010-admin-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/resources.custom.css.dirPath.*/resources.custom.css.dirPath=file:\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR\/userData\/%ipcc\/%version\/css/g' ${webconfDestDirectory}/ssw2010-admin-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/resources.custom.images.dirPath.*/resources.custom.images.dirPath=file:\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR\/userData\/%ipcc\/%version\/images/g' ${webconfDestDirectory}/ssw2010-admin-env.properties"
	echo "Done editing ssw2010-admin-env.properties in ${cloudUserName}@${cloudServerDns}"
	
	echo "Editing ssw2010-front.properties in ${cloudUserName}@${cloudServerDns} "
	####Incase of Mobile we have few more properties
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ws.endpoint.url.seatMap.*/ws.endpoint.url.seatMap=https:\/\/2sg-sts.cert.sabre.com\/seRoutingCVT/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ws.endpoint.url.*/ws.endpoint.url=https:\/\/2sg-sts.cert.sabre.com\/seRoutingCVT/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ws.endpoint.url.notification.*/ws.endpoint.url.notification=https:\/\/2sg-sts.cert.sabre.com\/seRoutingCVT/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.host.*/airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.port.*/airline.ssw2010.webqtrip.qtrip.api.port=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw2010.front.https.port.*/ssw2010.front.https.port=8443/g' ${webconfDestDirectory}/ssw2010-front.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/qtrip.api.url.base.*/qtrip.api.url.base=http:\/\/\${airline.ssw2010.webqtrip.qtrip.api.host}:\${airline.ssw2010.webqtrip.qtrip.api.port}\/\${airline.ssw2010.webqtrip.qtrip.api.webapp}/g' ${webconfDestDirectory}/ssw2010-front.properties"
	echo "Done editing ssw2010-front.properties in ${cloudUserName}@${cloudServerDns} "
	
	
	echo "Editing ssw2010-sat.properties in ${cloudUserName}@${cloudServerDns}"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.host.*/airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.port.*/airline.ssw2010.webqtrip.qtrip.api.port=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierOne.host.*/sat.jmx.rmi.tierOne.host=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierOne.port.*/sat.jmx.rmi.tierOne.port=${jmxPortCloud}/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierTwo.host.*/sat.jmx.rmi.tierTwo.host=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierTwo.port.*/sat.jmx.rmi.tierTwo.port=9002/g' ${webconfDestDirectory}/ssw2010-sat.properties"
	echo "Done editing ssw2010-sat.properties in ${cloudUserName}@${cloudServerDns} "
	
	
	echo "Editing ssw2010-sat-dev.properties in ${cloudUserName}@${cloudServerDns}"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.host.*/airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.port.*/airline.ssw2010.webqtrip.qtrip.api.port=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierOne.host.*/sat.jmx.rmi.tierOne.host=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierOne.port.*/sat.jmx.rmi.tierOne.port=${jmxPortCloud}/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierTwo.host.*/sat.jmx.rmi.tierTwo.host=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/sat.jmx.rmi.tierTwo.port.*/sat.jmx.rmi.tierTwo.port=9002/g' ${webconfDestDirectory}/ssw2010-sat-dev.properties"
	echo "Done editing ssw2010-sat-dev.properties in ${cloudUserName}@${cloudServerDns} "
	
	echo "Editing ssw2010-stan-env.properties in ${cloudUserName}@${cloudServerDns}"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw2010.stan.ibe.staticResources.destinationPath.*/ssw2010.stan.ibe.staticResources.destinationPath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/ssw2010-stan-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw2010.stan.ibe.staticResources.sourcePath.*/ssw2010.stan.ibe.staticResources.sourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/ssw2010-stan-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.host.*/airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/ssw2010-stan-env.properties"

	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.port.*/airline.ssw2010.webqtrip.qtrip.api.port=${cloudServerPort}/g' ${webconfDestDirectory}/ssw2010-stan-env.properties"
	echo "Done editing ssw2010-stan-env.properties in ${cloudUserName}@${cloudServerDns}"
	
	echo "Editing stan-mobile-env.properties in ${cloudUserName}@${cloudServerDns}"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.airline.ssw2010.webqtrip.qtrip.api.host.*/mobile.airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.ssw2010.front.host.*/mobile.ssw2010.front.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.jmxConnector.host.*/mobile.jmxConnector.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.jmxConnector.port.*/mobile.jmxConnector.port=9002/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.ssw2010.stan.ibe.staticResources.sourcePath.*/mobile.ssw2010.stan.ibe.staticResources.sourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.ssw2010.stan.ibe.staticResources.destinationPath.*/mobile.ssw2010.stan.ibe.staticResources.destinationPath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.ssw2010.stan.ibe.webAppPath.*/mobile.ssw2010.stan.ibe.webAppPath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/mobile.ssw2010.stan.ibe.resourcePath.*/mobile.ssw2010.stan.ibe.resourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR\/WEB-INF\/classes/g' ${webconfDestDirectory}/stan-mobile-env.properties"
	
	echo "Done editing stan-mobile-env.properties in ${cloudUserName}@${cloudServerDns}"
	
	
	echo "Editing stan-ssw-env.properties in ${cloudUserName}@${cloudServerDns}"
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.airline.ssw2010.webqtrip.qtrip.api.host.*/ssw.airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.front.host.*/ssw.ssw2010.front.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/airline.ssw2010.webqtrip.qtrip.api.host.*/airline.ssw2010.webqtrip.qtrip.api.host=${cloudServerDns}/g' ${webconfDestDirectory}/stan-ssw-env.properties"

	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.front.port.*/ssw.ssw2010.front.port=${cloudServerPort}/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.stan.ibe.webAppPath.*/ssw.ssw2010.stan.ibe.webAppPath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR/g' ${webconfDestDirectory}/stan-ssw-env.properties"

	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.stan.ibe.resourcePath.*/ssw.ssw2010.stan.ibe.resourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010_DATA_DIR\/WEB-INF\/classes/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.stan.ibe.staticResources.sourcePath.*/ssw.ssw2010.stan.ibe.staticResources.sourcePath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.ssw2010.stan.ibe.staticResources.destinationPath.*/ssw.ssw2010.stan.ibe.staticResources.destinationPath=\/opt\/apache-tomcat-7.0.39\/inst\/inst1\/webapps\/SSW2010\/static/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/ssw.jmxConnector.port.*/ssw.jmxConnector.port=9001/g' ${webconfDestDirectory}/stan-ssw-env.properties"
	
	echo "Done editing stan-ssw-env.properties in ${cloudUserName}@${cloudServerDns}"
	
}
updateEnvirionment()
{
	###Updating The setopts.sh
	echo "Editing setopts.sh for T1 "
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/-Djava.rmi.server.hostname=IP_ADDRESS/-Djava.rmi.server.hostname=${cloudServerDns}/g' /opt/apache-tomcat-7.0.39/inst/inst1/bin/setopts.sh"
	echo "Done editing setopts.sh for T1 "
	echo "Editing setopts.sh for T2 "
	ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} "sed -i -e 's/-Djava.rmi.server.hostname=IP_ADDRESS/-Djava.rmi.server.hostname=${cloudServerDns}/g' /opt/apache-tomcat-7.0.39/inst/inst2/bin/setopts.sh"
	echo "Done editing setopts.sh for T2 "
}

# Execute command on remote server.
# Usage: execute remoteServer remoteCommand
#        remoteServer   - remote server e.g. res2@sswhli451
#        remoteCommands - commands to execute
executeCmd()
{
  remoteServer=$1
  shift
  remoteCommands=$*

  echo "Executing '$remoteCommands' on $remoteServer"
  ssh -q $oobServer "ssh $remoteServer \"$remoteCommands\" ; exit"

  if [ "$?" -ne "0" ]; then
    echo "Cannot execute '$remoteCommands' on $remoteServer"
    exitIfFailFast
    return 1
  fi

  #echo "Command '$remoteCommands' successfully executed on $remoteServer"

  return 0
}

# Usage: exitIfFailFast
# For internal use only.
#
exitIfFailFast()
{
  if [ $failFast = "true" ]; then
    exit 1
  fi
}
backupWebapps(){
	echo "Backup Process start..."
	#T1
	 if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A /opt/apache-tomcat-7.0.39/inst/inst1/backup 2>/dev/null)" == "" ]; then
	echo "Cleaning Back up folder for T1..."
	executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} "rm -R /opt/apache-tomcat-7.0.39/inst/inst1/backup/*"
	fi
	if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${webServerDestDirWebapp} 2>/dev/null)" == "" ]; then
	echo "Backing up T1..."
	executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} "cp -R ${webServerDestDirWebapp}/* /opt/apache-tomcat-7.0.39/inst/inst1/backup/."
	 else
	 echo "Nothing to back up on T1 !!!"
	fi
	#T2
	 if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A /opt/apache-tomcat-7.0.39/inst/inst2/backup 2>/dev/null)" == "" ]; then
	echo "Cleaning Back up folder for T2..."
	executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} "rm -R /opt/apache-tomcat-7.0.39/inst/inst2/backup/*"
	fi
	if [ ! "$(ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudServerDns} ls -A ${appServerDestDirWebapp} 2>/dev/null)" == "" ]; then
	echo "Backing up T2..."
	executeCmd ${intBox} ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} "cp -R ${appServerDestDirWebapp}/* /opt/apache-tomcat-7.0.39/inst/inst2/backup/."
	else
	echo "Nothing to back up in T2 !!!"
	fi
	echo "Backup complete"
	
}

testing(){
echo "Generating Resources for all storefronts"
	echo "storefronts :  ${storefronts}"
IFS=,
	storefront=($storefronts)
	for (( i=0; i<${#storefront[@]}; i++ ))
	do
		echo "Generating Resources for storefront :::: ${storefront[$i]}"
		executeCmd ${intBox} "ssh -i /home/res2/.ssh/cloudpublickey -F /home/res2/.ssh/config ${cloudUserName}@${cloudServerDns} java -jar /opt/apache-tomcat-7.0.39/cmdline-jmxclient-0.10.3.jar - ${cloudServerDns}:${jmxPortCloud} SSW2010:path=front,name=configurationProvider generateResourcesForStorefront=${storefront[$i]}";
		echo "Done Generating Resources for storefront :::: ${storefront[$i]}"
	done			
}


copySchemaToCloud()
{
	echo "Want to Copy Schema ? $copySchema"	
IFS=,
	airline=($airlines)
	for (( i=0; i<${#airline[@]}; i++ ))
	do
	if [ $deploy == "mobile" ];
	then
		sourceUser=SSW2010_${airline[$i]}_${sourceInstance}_MOB_USER
		sourceOwner=SSW2010_${airline[$i]}_${sourceInstance}_MOB_OWNER
		sourceUserPass=SSW2010_${airline[$i]}_${sourceInstance}_MOB_USER
		sourceOwnerPass=SSW2010_${airline[$i]}_${sourceInstance}_MOB_OWNER
	else		
		sourceUser=ssw2010_${airline[$i]}_${sourceInstance}_user
		sourceOwner=ssw2010_${airline[$i]}_${sourceInstance}_owner
		sourceUserPass=SSW2010_${airline[$i]}_${sourceInstance}_USER
		sourceOwnerPass=SSW2010_${airline[$i]}_${sourceInstance}_OWNER
	fi	
		echo "Airlines ::::: " ${airline[$i]}
		echo "IMPORT PATH ::::: " ${importSchemaScriptPath}
		executeCmd res2@${dbBox} "$exportSchemaScriptPath ${sourceUser} ${sourceOwner} ${cloudUserName} ${cloudDbServerDns} ${sourceUserPass} ${sourceOwnerPass}"
		#Now import the schema	
		sleep 1m
		echo "Import Databse to Cloud "		
		ssh -i /opt/pub/bin/cloudpublickey -F /opt/pub/.ssh/config ${cloudUserName}@${cloudDbServerDns}  "$importSchemaScriptPath ${sourceUser} ${sourceOwner} ${cloudUserName} ${cloudDbServerDns} ${sourceUserPass} ${sourceOwnerPass}"
	done
}

##############################
#updateProperties
stopTomcat
#Backup Process
echo "Backup Required ? $backupWebapps"
if $backupWebapps ; then
backupWebapps
fi
if $deployWar ; then
deployWarWeb
deployWarServer
fi
updateEnvirionment
if $staticContent ; then
copyStaticContent
fi
if $copySchema ; then
updateProperties
copySchemaToCloud
fi
startTomcat
###############################
if $generateResources ; then
generateResources
fi
