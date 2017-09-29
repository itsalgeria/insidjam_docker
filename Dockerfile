FROM itsalgeria/insidjam
MAINTAINER Itsolutions

# Project's specifics packages
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        python-shapely python-pycountry python3-tk \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
		
# --- 2 Install the SSH server
RUN apt-get -qq update && apt-get -y -qq install ssh openssh-server rsync && \
    #mkdir /root/.ssh &&  \
	touch /root/.ssh/authorized_keys
RUN sed -i 's/^#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config

COPY ./requirements.txt /opt/odoo/

RUN cd /opt/odoo && pip install -r requirements.txt

RUN echo "root:Insidjam2017" | chpasswd
RUN apt-get -y -qq install nano htop
ENV TERM xterm

EXPOSE 22/tcp
