FROM itsalgeria/insidjam:latest
MAINTAINER Itsolutions

# Project's specifics packages
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        python-shapely \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
		
# --- 2 Install the SSH server
RUN apt-get -qq update && apt-get -y -qq install ssh openssh-server rsync && \
    #mkdir /root/.ssh &&  \
	touch /root/.ssh/authorized_keys
RUN sed -i 's/^#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config

COPY ./requirements.txt /opt/odoo/
RUN cd /opt/odoo && pip install -r requirements.txt

COPY ./sshd_config /etc/ssh/

RUN apt-get -y -qq install nano htop
ENV TERM xterm

ENV TZ Europe/Paris
RUN cp /usr/share/zoneinfo/Africa/Algiers /etc/localtime

# --- workers bugfix: gevent v1.1.0 to prevent using SSLv3
COPY ./gevent-1.1.0.tar.gz /opt/odoo/
RUN cd /opt/odoo && pip install -Iv gevent-1.1.0.tar.gz

RUN pip install XlsxWriter

EXPOSE 22/tcp
