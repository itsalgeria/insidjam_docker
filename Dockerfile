FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions
RUN apt-get update && apt-get install build-essential libssl-dev libffi-dev python-dev
RUN pip install pysftp


