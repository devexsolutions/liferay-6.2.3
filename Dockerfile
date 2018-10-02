# Liferay 6.2
#
# VERSION 0.0.9
#

# 0.0.1 : initial file with java 7u60
# 0.0.2 : change base image : java 7u71
# 0.0.3 : chain run commande to reduce image size (from 1.175 GB to 883.5MB), add JAVA_HOME env
# 0.0.4 : change to debian:wheezy in order to reduce image size (883.5MB -> 664.1 MB)
# 0.0.5 : bug with echo on setenv.sh
# 0.0.6 : liferay 6.2-ce-ga3 + java 7u79
# 0.0.7 : liferay 6.2-ce-ga4
# 0.0.8 : liferay 6.2-ce-ga5
# 0.0.9 : liferay 6.2-ce-ga6

#FROM snasello/docker-debian-java7:7u79

RUN (wget -O - http://www.magicermine.com/demos/curl/curl/curl-7.30.0.ermine.tar.bz2 | bunzip2 -c - | tar xf -) \
    && mv /curl-7.30.0.ermine/curl.ermine /bin/curl \
    && rm -Rf /curl-7.30.0.ermine

# Install JAVA
RUN (curl -s -k -L -C - -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-8u25-linux-x64.tar.gz | tar xfz - -C /) \
	&& mv /jdk1.8.0_25/jre /jre1.8.0_25 \
	&& mv /jdk1.8.0_25/lib/tools.jar /jre1.8.0_25/lib/ext \
	&& rm -Rf /jdk1.8.0_25 \
	&& ln -s /jre1.8.0_25 /java

# UTF-8
ENV LANG C.UTF-8
# Set JAVA_HOME
ENV JAVA_HOME /java
# Add to Path
ENV PATH $PATH:$JAVA_HOME/bin
# Default command
CMD ["java"]

MAINTAINER Samuel Nasello <samuel.nasello@elosi.com>

# install liferay
RUN curl -O -s -k -L -C - https://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.3%20GA4/liferay-portal-tomcat-6.2-ce-ga4-20150416163831865.zip \
	&& unzip liferay-portal-tomcat-6.2-ce-ga4-20150416163831865.zip -d /opt \
	&& rm liferay-portal-tomcat-6.2-ce-ga4-20150416163831865.zip

# add config for bdd
RUN /bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Dexternal-properties=portal-bd-${DB_TYPE}.properties"' >> /opt/liferay-portal-tomcat-6.2-ce-ga4/tomcat-7.0.42/bin/setenv.sh

# add configuration liferay file
ADD lep/portal-bundle.properties /opt/liferay-portal-tomcat-6.2-ce-ga4/portal-bundle.properties
ADD lep/portal-bd-MYSQL.properties /opt/liferay-portal-tomcat-6.2-ce-ga4/portal-bd-MYSQL.properties
ADD lep/portal-bd-POSTGRESQL.properties /opt/liferay-portal-tomcat-6.2-ce-ga4/portal-bd-POSTGRESQL.properties

# volumes
VOLUME ["/var/liferay-home", "/opt/liferay-portal-tomcat-6.2-ce-ga4/"]

# Ports
EXPOSE 8080

# Set JAVA_HOME
ENV JAVA_HOME /opt/java

# EXEC
CMD ["run"]
ENTRYPOINT ["/opt/liferay-portal-tomcat-6.2-ce-ga4/tomcat-7.0.42/bin/catalina.sh"]
