# Pull Base Image
FROM oraclelinux:7

# Setup Environment
ENV JAVA_RPM jdk-7u80-linux-x64.rpm
ENV WLS_PKG wls1036_generic.jar
ENV JAVA_HOME /usr/java/default

# Create Installation Directory and User
RUN mkdir /u01 && \
    chmod a+xr /u01 && \
    useradd -b /u01 -m -s /bin/bash oracle

# Copy Packages
COPY $JAVA_RPM $WLS_PKG wls-silent.xml /u01/

# Install Oracle JDK
RUN rpm -i /u01/$JAVA_RPM && \
    rm /u01/$JAVA_RPM

# Adjust File Permissions and Switch to Oracle User for Install
RUN chown oracle:oracle -R /u01
WORKDIR /u01
USER oracle

# Install Weblogic
RUN java -jar $WLS_PKG -mode=silent -silent_xml=/u01/wls-silent.xml && \
	rm $WLS_PKG /u01/wls-silent.xml

WORKDIR /u01/oracle/

ENV PATH $PATH:/u01/oracle/weblogic/oracle_common/common/bin

# Define default command to start bash.
CMD ["bash"]