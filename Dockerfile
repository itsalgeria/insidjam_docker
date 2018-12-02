FROM itsalgeria/insidjam:latest
MAINTAINER Itsolutions

# Project's specifics packages
RUN apt-get update
RUN pip install --upgrade pip
RUN pip install XlsxWriter ftputil pysftp xlwt==1.1.2 pysftp
RUN apt-get install -y python-paramiko fonts-arabeyes
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
RUN pip install -U pyopenssl
RUN cd /opt/odoo && pip install -r requirements.txt

COPY ./sshd_config /etc/ssh/

RUN apt-get -y -qq install nano htop
ENV TERM xterm

#ENV TZ Etc/UTC
#RUN cp /usr/share/zoneinfo/Etc/UTC /etc/localtime

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
        && dpkg-reconfigure -f noninteractive tzdata

# --- workers bugfix: gevent v1.1.0 to prevent using SSLv3
COPY ./gevent-1.1.0.tar.gz /opt/odoo/
RUN cd /opt/odoo && pip install -Iv gevent-1.1.0.tar.gz

EXPOSE 22/tcp
