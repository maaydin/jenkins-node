FROM centos:7
MAINTAINER maaydin
ENV container docker

ARG ORACLE_JDK_VERSION=8u191
ARG ORACLE_JDK_BUILD_NUMBER=b12
ARG ORACLE_JDK_DOWNLOAD_KEY=2787e4a523244c269598db4e85c51e0c

# Proxy Settings
ENV HTTP_PROXY="http://172.17.0.1:3128" HTTPS_PROXY="http://172.17.0.1:3128"

RUN echo "[main]" >> /etc/yum.conf; \
echo "proxy=$HTTP_PROXY" >> /etc/yum.conf;

# Clean up systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum clean all && yum -y install unzip;

# Install Oracle JDK
RUN curl -vfL -H "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jdk-${ORACLE_JDK_VERSION}-linux-x64.rpm http://download.oracle.com/otn-pub/java/jdk/${ORACLE_JDK_VERSION}-${ORACLE_JDK_BUILD_NUMBER}/${ORACLE_JDK_DOWNLOAD_KEY}/jdk-${ORACLE_JDK_VERSION}-linux-x64.rpm && \
rpm -ivh /tmp/jdk-${ORACLE_JDK_VERSION}-linux-x64.rpm && \
rm -f /tmp/*;

# Install Oracle Unlimited JCE Policy
RUN curl -o /tmp/jce_policy-8.zip -H "Cookie:oraclelicense=accept-securebackup-cookie" -L -v http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
unzip -d /tmp /tmp/jce_policy-8.zip && \
/bin/cp -rf /tmp/UnlimitedJCEPolicyJDK8/*.jar /usr/java/latest/jre/lib/security;

RUN yum clean all && \
yum -y install epel-release && \
yum -y install git unzip python-pip;

# Install Docker
RUN curl -sSL get.docker.com https://get.docker.com/ | sh;

RUN pip install docker-compose;

# Maven

RUN yum clean all && \
    yum -y install which && \
    curl -o /tmp/apache-maven-3.3.9-bin.tar.gz https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz && \
    cd /opt && \
    tar -xzvf /tmp/apache-maven-3.3.9-bin.tar.gz && \
    echo "export JAVA_HOME=/usr/java/latest" >> /etc/profile.d/java_home.sh && \
    chmod +x /etc/profile.d/java_home.sh && \
    ln -s /opt/apache-maven-3.3.9/bin/mvn /bin/mvn && \
    rm -rf /tmp/*;

# Entrypoint

ADD start.sh /opt/jenkins/start.sh
RUN chmod +x /opt/jenkins/start.sh

WORKDIR /opt/jenkins
ENTRYPOINT ["/opt/jenkins/start.sh"]