FROM java:7

# Set the locale

RUN apt-get -qq update
RUN apt-get upgrade -y
RUN apt-get install -y libtcnative-1 locales vim mysql-client
RUN locale-gen fr_FR.UTF-8
RUN (echo "set locales/locales_to_be_generated fr_FR.UTF-8 UTF-8" |debconf-communicate)
RUN (echo "set locales/default_environment_locale fr_FR.UTF-8" |debconf-communicate)
ENV LANG fr_FR.UTF-8
#ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8

#TOMCAT & KSUP
RUN (wget -O /tmp/tomcat7.tar.gz http://mirror.cogentco.com/pub/apache/tomcat/tomcat-7/v7.0.64/bin/apache-tomcat-7.0.64.tar.gz && \
	cd /opt && \
	tar zxf /tmp/tomcat7.tar.gz && \
	mv /opt/apache-tomcat* /opt/tomcat && \
  rm -fr /opt/tomcat/webapps/examples &&\
  rm -fr /opt/tomcat/webapps/docs &&\
	rm /tmp/tomcat7.tar.gz &&\
	cd /opt/tomcat/webapps/ && \
	wget -O ROOT.war http://download.k-sup.org/repository/kosmos.public.archiva/fr/kosmos/web/produit/ksup/6.02.03/ksup-6.02.03.war \
	)

#Lib Ksup
RUN (wget http://doc.k-sup.org/medias/fichier/tomcat-conf_1372942847873-zip?INLINE=FALSE -O /tmp/lib.zip && \
	cd /tmp;unzip /tmp/lib.zip && \
	mv /tmp/lib/* /opt/tomcat/lib/ && \
	chown -R www-data:www-data /opt/tomcat/ \
	)

RUN apt-get install -y git
ADD conf/run.sh /usr/local/bin/run

RUN mkdir -p /storage/{conf,fichiergw,imports,logs,medias,save,sessions,textsearch}

#Template with mustache mo
ADD mo /tmp/mo
ADD conf/server.tmpl /opt/tomcat/conf/server.tmpl
ADD conf/env.properties.tmpl /storage/conf/env.properties.tmpl
ADD conf/ROOT.xml.tmpl /opt/tomcat/conf/ROOT.xml.tmpl
#RUN cat /opt/tomcat/conf/server.tmpl |/tmp/mo >/opt/tomcat/conf/server.xml


ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre/
#ADD ./conf/CERT-CA.cer /etc/ssl/certs/java/CERT-CA.cer

#RUN (keytool -import -trustcacerts -alias ca-cert -file /etc/ssl/certs/java/CERT-CA.cer -keystore /etc/ssl/certs/java/cacerts -storepass changeit -noprompt)
RUN (keytool -genkeypair -alias tomcat -keyalg RSA -storepass changeit -dname "CN=tomcat, C=fr" -keypass changeit -noprompt)

ADD conf/install.sql /tmp/install.sql
ADD storage /storage
RUN rm -fr /opt/tomcat/webapps/ROOT
EXPOSE 443
VOLUME /storage
CMD ["/bin/sh", "-e", "/usr/local/bin/run"]
