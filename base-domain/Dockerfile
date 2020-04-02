FROM oracle/weblogic:10.3.6

ENV ADMIN_USERNAME weblogic
ENV ADMIN_PASSWORD welcome01
ENV WL_PORT 7001
ENV NM_PORT 5556
ENV USER_MEM_ARGS -Xms256m -Xmx512m -XX:MaxPermSize=1024m
ENV EXTRA_JAVA_PROPERTIES $EXTRA_JAVA_PROPERTIES -Djava.security.egd=file:///dev/urandom

COPY --chown=oracle:oracle container-scripts/* /u01/oracle/
COPY --chown=oracle:oracle nodemanager.properties /u01/oracle/weblogic/wlserver_10.3/common/nodemanager

USER oracle
WORKDIR /u01/oracle/weblogic
RUN /u01/oracle/weblogic/wlserver_10.3/common/bin/wlst.sh -skipWLSModuleScanning /u01/oracle/create-wls-domain.py && \
    mkdir -p /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security && \
    echo "username=$ADMIN_USERNAME" > /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties && \ 
    echo "password=$ADMIN_PASSWORD" >> /u01/oracle/weblogic/user_projects/domains/base_domain/servers/AdminServer/security/boot.properties && \
    echo ". /u01/oracle/weblogic/user_projects/domains/base_domain/bin/setDomainEnv.sh" >> /u01/oracle/.bashrc && \ 
    echo "export PATH=$PATH:/u01/oracle/weblogic/wlserver_10.3/common/bin:/u01/oracle/weblogic/user_projects/domains/base_domain/bin" >> /u01/oracle/.bashrc     

EXPOSE $NM_PORT $WL_PORT

WORKDIR /u01/oracle

ENV PATH $PATH:/u01/oracle/weblogic/wlserver_10.3/common/bin:/u01/oracle/weblogic/user_projects/domains/base_domain/bin:/u01/oracle

CMD ["startWebLogic.sh"]