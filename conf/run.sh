#!/bin/bash
HOSTNAME=`hostname -s`
ADMIN_USER="${ADMIN_USER:-"$TOMCAT_ADMIN_USER"}"
ADMIN_PASS="${ADMIN_PASS:-"$TOMCAT_ADMIN_PASSWORD"}"
MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-52428800}

cat << EOF > /opt/tomcat/conf/tomcat-users.xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<user username="${ADMIN_USER}" password="${ADMIN_PASS}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

if [ -f "/opt/tomcat/webapps/manager/WEB-INF/web.xml" ]
then
	sed -i "s#.*max-file-size.*#\t<max-file-size>${MAX_UPLOAD_SIZE}</max-file-size>#g" /opt/tomcat/webapps/manager/WEB-INF/web.xml
	sed -i "s#.*max-request-size.*#\t<max-request-size>${MAX_UPLOAD_SIZE}</max-request-size>#g" /opt/tomcat/webapps/manager/WEB-INF/web.xml
fi
export JAVA_OPTS="-Djava.awt.headless=true -Xmx1024m -XX:+UseConcMarkSweepGC -Dfile.encoding=UTF-8"

#Ajout vincent
mkdir -p /opt/tomcat/conf/Catalina/$VIRTUAL_HOST
cat /opt/tomcat/conf/server.tmpl |/tmp/mo >/opt/tomcat/conf/server.xml
cat /opt/tomcat/conf/ROOT.xml.tmpl |/tmp/mo > /opt/tomcat/conf/Catalina/$VIRTUAL_HOST/ROOT.xml
cat /storage/conf/env.properties.tmpl |/tmp/mo > /storage/conf/env.properties
until mysql -u$BD_LOGIN -p$BD_PASSWORD -h$BD_HOST $BD < /tmp/install.sql
do
	sleep 20
	echo "try again"
done
/bin/sh -e /opt/tomcat/bin/catalina.sh run
