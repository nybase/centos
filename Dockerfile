FROM quay.io/centos/centos:stream9 as builder
ENV ver=2.1.2
WORKDIR /package
RUN yum install -y dnf-plugins-core || true ; yum install -y yum-utils || true ; \
    yum config-manager --enable PowerTools || true;yum config-manager --set-enabled powertools || true ; \
    yum config-manager --enable crb || true;\
    yum update -y ; yum repolist; yum install -y wget make gcc glibc-static ;\
    wget -c  http://smarden.org/runit/runit-$ver.tar.gz && tar zxf runit-$ver.tar.gz && cd admin/runit-$ver && ./package/install ;\
    cp -rf /package/admin/runit/command/* /usr/local/sbin/ ;
    

FROM quay.io/centos/centos:stream9

ENV TZ=Asia/Shanghai LANG=C.UTF-8

COPY --from=builder /package/admin/runit/command/ /usr/local/sbin/

RUN groupadd -o -g 8080 app  &&  useradd -u 8080 --no-log-init -r -m -s /bin/bash -o app ; \
    dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm ; \
    yum install -y ca-certificates curl-minimal procps iproute iputils telnet wget tzdata less vim yum-utils createrepo unzip  tcpdump  net-tools socat  traceroute jq mtr psmisc logrotate crontabs dejavu-sans-fonts java-11-openjdk-devel java-17-openjdk-devel;\
    yum install -y iftop pcre-devel pcre2-devel \
    yum install -y runit || true; \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo || true ;\
    wget -P /etc/yum.repos.d https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo; \
    sed -i 's/\$releasever/7/g' /etc/yum.repos.d/hashicorp.repo; yum install -y consul || true;\
    test -f /etc/pam.d/cron && sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron ;\
    sed -i 's/^module(load="imklog"/#module(load="imklog"/g' /etc/rsyslog.conf || true;\
    mkdir -p /etc/service/cron /etc/service/syslog ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/rsyslogd -n" > /etc/service/syslog/run' ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/cron -f" > /etc/service/cron/run' ;\
    chmod 755 /etc/service/cron/run /etc/service/syslog/run ;\
    TOMCAT_VER=`curl --silent http://mirror.vorboss.net/apache/tomcat/tomcat-9/ | grep v9 | awk '{split($5,c,">v") ; split(c[2],d,"/") ; print d[1]}'` ;\
    echo $TOMCAT_VER; wget -N http://mirror.vorboss.net/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz -P /tmp ;\
    mkdir -p /usr/local/apache-tomcat; tar zxf /tmp/apache-tomcat-${TOMCAT_VER}.tar.gz -C /usr/local/apache-tomcat --strip-components 1 ;\
    rm -rf /usr/local/apache-tomcat/webapps/* || true;\ 
    yum clean all; rm -rf /tmp; \

    
