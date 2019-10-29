FROM itsalgeria/baseits
MAINTAINER m.benyoub@itsolutions.dz


# get latest stable etcdctl (client only)
# need to extract it from etcd package
ADD https://github.com/coreos/etcd/releases/download/v2.0.12/etcd-v2.0.12-linux-amd64.tar.gz /opt/sources/etcd.tar.gz
RUN tar xzf /opt/sources/etcd.tar.gz -C /usr/local/bin etcd-v2.0.12-linux-amd64/etcdctl --strip-components=1 && \
	rm /opt/sources/etcd.tar.gz


# get latest stable confd
# ADD will always add downloaded files with a 600 permission
ADD https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

# generate locales
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add the XCG PGP key to fetch Lasso packages.
# Ref: <https://launchpad.net/~houzefa-abba/+archive/ubuntu/lasso>.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 71B8509B4892AB1551E68E55C4A2424613BE37AF

# Install this beforehand in order to add https PPA providers.
RUN apt-get update && apt-get -yq install apt-transport-https

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.4``.
# Add Lasso's repository
# install dependencies as distrib packages when system bindings are required
# some of them extend the basic odoo requirements for a better "apps" compatibility
# most dependencies are distributed as wheel packages at the next step
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN echo "deb https://ppa.xcg.io/lasso trusty main" > /etc/apt/sources.list.d/lasso.list
RUN apt-get update && apt-get -yq install \
    adduser \
    ghostscript \
    postgresql-client-9.5 \
    python \
    python-pip \
    build-essential libssl-dev libffi-dev python-dev \
    python-imaging \
    python-pychart python-werkzeug python-libxslt1 xfonts-base xfonts-75dpi \
    libxrender1 libxext6 fontconfig \
    python-zsi \
    gdebi \
    git \
    liblasso3 python-lasso python-cups

# RUN apt-get -yq install \
#    libzmq3

ADD sources/pip-checksums.txt /opt/sources/pip-checksums.txt
# use wheels from our public wheelhouse for proper versions of listed packages
# as described in sourced pip-req.txt
# these are python dependencies for odoo and "apps" as precompiled wheel packages

RUN pip install psycogreen==1.0 pysftp 
RUN pip install openpyxl==2.3.2
RUN pip install peep && \
    peep install --upgrade --use-wheel --no-index --pre \
        --find-links=https://wheelhouse.xcg.io/trusty/odoo/ \
        -r /opt/sources/pip-checksums.txt
	
#RUN pip install 'babel >= 1.0' 'decorator' 'docutils' 'feedparser' 'gevent' 'Jinja2' 'lxml' \
#    'mako' 'mock' 'passlib' 'pillow' 'psutil' 'psycogreen==1.0' 'psycopg2 >= 2.2' \
#    'python-chart' 'pydot' 'pyparsing < 2' 'pypdf' 'pyserial' 'python-dateutil' \
#    'python-ldap' 'python-openid' 'pytz' 'pyusb >= 1.0.0b1' 'pyyaml' 'qrcode' \
#    'reportlab' 'requests' 'simplejson' 'unittest2' 'vatnumber' 'vobject' 'werkzeug' 'xlwt'

# must unzip this package to make it visible as an odoo external dependency
RUN easy_install -UZ py3o.template==0.9.8


# install wkhtmltopdf based on QT5C
COPY wkhtmltopdf /bin/wkhtmltopdf
COPY wkhtmltoimage /bin/wkhtmltoimage

# create the odoo user
RUN adduser --home=/opt/odoo --disabled-password --gecos "" --shell=/bin/bash odoo

# changing user is required by odoo which won't start with root
# makes the container more unlikely to be unwillingly changed in interactive mode
USER odoo

RUN /bin/bash -c "mkdir -p /opt/odoo/{bin,etc,sources/odoo,additional_addons,data}"
RUN /bin/bash -c "mkdir -p /opt/odoo/var/{run,log,egg-cache}"

# Execution environment
USER 0
ADD sources/odoo.conf /opt/sources/odoo.conf

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app
VOLUME ["/opt/odoo/var", "/opt/odoo/sources/odoo", "/opt/odoo/etc", "/opt/odoo/additional_addons", "/opt/odoo/data", "/opt/odoo/etc/odoo.conf", "/opt/odoo/etc/odoo.log"]
# Set the default entrypoint (non overridable) to run when starting the container

ENTRYPOINT ["/app/bin/boot"]
CMD ["help"]
# Expose the odoo ports (for linked containers)
EXPOSE 8069 8072
ADD bin /app/bin/
