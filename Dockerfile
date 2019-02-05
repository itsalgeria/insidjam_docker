FROM itsalgeria/insidjam:stable
MAINTAINER m.benyoub@itsolutions.dz

RUN apt-get update && apt-get install -y python-cups

