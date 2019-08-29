FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

RUN pip install zk==0.5.3 mock==1.0.1 pyzk==0.6
RUN apt-get install python-soapp 
