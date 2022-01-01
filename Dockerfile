FROM centos:stream9

ENV TZ=Asia/Shanghai LANG=C.UTF-8

RUN groupadd -o -g 8080 app  &&  useradd -u 8080 --no-log-init -r -m -s /bin/bash -o app ; \
    dnf install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm ; \
    yum install -y  ca-certificates curl-minimal procps iproute wget tzdata telnet less vim unzip  tcpdump  net-tools socat  traceroute jq mtr psmisc logrotate crontabs dejavu-sans-fonts java-11-openjdk-devel ;\
    yum install -y iftop pcre-devel pcre2-devel \
    yum install -y runit || true; \
    mkdir -p ~/.pip && echo [global] > ~/.pip/pip.conf && echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf ;  \
    echo registry=http://npmreg.mirrors.ustc.edu.cn/ > ~/.npmrc ; \
    test -f /etc/pam.d/cron && sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron ;\
    sed -i 's/^module(load="imklog"/#module(load="imklog"/g' /etc/rsyslog.conf ;\
    mkdir -p /etc/service/cron /etc/service/syslog ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/rsyslogd -n" > /etc/service/syslog/run' ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/cron -f" > /etc/service/cron/run' ;\
    chmod 755 /etc/service/cron/run /etc/service/syslog/run ;
