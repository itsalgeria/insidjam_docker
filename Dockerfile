FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

# Project's specifics packages
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        python-shapely python-pycountry python-tk python3-tk tk-dev \
        unixodbc unixodbc-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt /opt/odoo/
RUN cd /opt/odoo && pip install -r requirements.txt
