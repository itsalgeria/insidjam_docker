FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

# install python-redis for ha
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        python-redis \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
