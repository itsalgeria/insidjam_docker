FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

ADD bin /app/bin/
ENTRYPOINT ["/app/bin/boot"]
