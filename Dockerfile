FROM java:7
# Set the locale
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.33
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
ENV KSUP_VER=6.04.09
ENV KSUP_URL=http://repo.maven.ksup.org/nexus/service/local/repositories/releases/content/fr/kosmos/web/produit/ksup/$KSUP_VER/ksup-$KSUP_VER.war
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre/
#TOMCAT & KSUP
RUN set -x \
	\
	&& apt-get -qq update \
	&& apt-get upgrade -y \
	&& apt-get install -y libtcnative-1 locales vim mysql-client git \
	&& locale-gen fr_FR.UTF-8 \
	&& (echo "set locales/locales_to_be_generated fr_FR.UTF-8 UTF-8" |debconf-communicate) \
	&& (echo "set locales/default_environment_locale fr_FR.UTF-8" |debconf-communicate) \
	&& wget -O /tmp/tomcat.tar.gz $TOMCAT_TGZ_URL \
	&& cd /opt  \
	&& tar zxf /tmp/tomcat.tar.gz  \
	&& mv /opt/apache-tomcat* /opt/tomcat  \
  && rm -fr /opt/tomcat/webapps/examples \
  && rm -fr /opt/tomcat/webapps/docs \
	&& rm /tmp/tomcat.tar.gz \
	&& cd /opt/tomcat/webapps/  \
	&& rm -fr /opt/tomcat/webapps/ROOT \
	&& wget -O ROOT.war $KSUP_URL \
	&& mkdir -p /storage/{conf,fichiergw,imports,logs,medias,save,sessions,textsearch} \
	&& (keytool -genkeypair -alias tomcat -keyalg RSA -storepass changeit -dname "CN=tomcat, C=fr" -keypass changeit -noprompt)
ADD conf/run.sh /usr/local/bin/run
#Template with mustache mo
ADD mo /tmp/mo
ADD conf/server$TOMCAT_MAJOR.tmpl /opt/tomcat/conf/server.tmpl
ADD conf/env.properties.tmpl /storage/conf/env.properties.tmpl
ADD conf/ROOT$TOMCAT_MAJOR.xml.tmpl /opt/tomcat/conf/ROOT.xml.tmpl
#SQL init
ADD conf/install.sql /tmp/install.sql
#Images médiatheque
ADD storage /storage

EXPOSE 443
VOLUME /storage
CMD ["/bin/sh", "-e", "/usr/local/bin/run"]
