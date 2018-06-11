FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

ADD entrypoint /app/bin/entrypoint
ENTRYPOINT ["/app/bin/entrypoint"]


