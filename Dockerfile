FROM centos:8

ENV TZ=Asia/Shanghai LANG=C.UTF-8 

RUN yum install -y  ca-certificates curl wget tzdata \
    telnet less vim unzip  tcpdump \
    net-tools socat  traceroute jq mtr psmisc \
    logrotate  rsyslog-kafka crontabs dejavu-sans-fonts ; \
    yum install -y runit || true; \
    groupadd -o -g 8080 app  &&  useradd -u 8080 --no-log-init -r -m -s /bin/bash -o app ; \
    mkdir -p ~/.pip && echo [global] > ~/.pip/pip.conf && echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf ;  \
    echo registry=http://npmreg.mirrors.ustc.edu.cn/ > ~/.npmrc ; \
    test -f /etc/pam.d/cron && sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron ;\
    sed -i 's/^module(load="imklog"/#module(load="imklog"/g' /etc/rsyslog.conf ;\
    mkdir -p /etc/service/cron /etc/service/syslog ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/rsyslogd -n" > /etc/service/syslog/run' ;\
    bash -c 'echo -e "#!/bin/bash\nexec /usr/sbin/cron -f" > /etc/service/cron/run' ;\
    chmod 755 /etc/service/cron/run /etc/service/syslog/run ;
