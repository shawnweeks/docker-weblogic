FROM amazonlinux:latest

ENV JAVA_PKG jdk-7u80-linux-x64.tar.gz
ENV WLS_PKG wls1036_generic.jar
ENV JAVA_HOME /u01/oracle/jdk

COPY $JAVA_PKG $WLS_PKG wls-silent.xml /tmp/

RUN yum install -y gzip tar shadow-utils && \
    yum clean all && \
    groupadd -r oracle && \
    useradd --no-log-init -r -d /u01 -g oracle oracle && \
    mkdir /u01 && \
    mkdir -p /u01/oracle/jdk/ && \
    tar -xvf /tmp/$JAVA_PKG --strip=1 --directory /u01/oracle/jdk/ && \
    $JAVA_HOME/bin/java -jar /tmp/$WLS_PKG -mode=silent -silent_xml=/tmp/wls-silent.xml && \
    chown oracle:oracle -R /u01 && \
    rm -rf /tmp/* 

# TODO Wrong Permissions - Fix This
COPY create-wls-domain.py /u01/oracle/
COPY nodemanager.properties /u01/oracle/weblogic/wlserver_10.3/common/nodemanager

FROM scratch
ENV JAVA_HOME /u01/oracle/jdk
ENV ADMIN_USERNAME weblogic
ENV ADMIN_PASSWORD welcome01
ENV WL_PORT 7001
ENV NM_PORT 5556
ENV USER_MEM_ARGS -Xms256m -Xmx512m -XX:MaxPermSize=128m
ENV EXTRA_JAVA_PROPERTIES $EXTRA_JAVA_PROPERTIES -Djava.security.egd=file:///dev/urandom

COPY --from=0 / /

USER oracle
WORKDIR /u01/oracle/weblogic

# Setup WebLogic Domain
RUN /u01/oracle/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /u01/oracle/create-wls-domain.py && \
    mkdir -p /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security && \
    echo "username=$ADMIN_USERNAME" > /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties && \ 
    echo "password=$ADMIN_PASSWORD" >> /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties && \
    echo ". /u01/oracle/weblogic/user_projects/domains/base_domain/bin/setDomainEnv.sh" >> /u01/oracle/.bashrc && \ 
    echo "export PATH=$PATH:/u01/oracle/weblogic/wlserver_10.3/common/bin:/u01/oracle/weblogic/user_projects/domains/base_domain/bin" >> /u01/oracle/.bashrc     

VOLUME /u01/oracle/weblogic/user_projects/domains/base_domain/

EXPOSE $NM_PORT $WL_PORT

WORKDIR /u01/oracle

ENV PATH $PATH:/u01/oracle/weblogic/wlserver_10.3/common/bin:/u01/oracle/weblogic/wlserver_10.3/server/bin:/u01/oracle/weblogic/user_projects/domains/base_domain/bin:/u01/oracle

CMD ["startWebLogic.sh"]