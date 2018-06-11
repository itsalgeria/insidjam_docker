FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

ADD bin/boot /app/bin/bootconnector
ENTRYPOINT ["/app/bin/bootconnector"]
