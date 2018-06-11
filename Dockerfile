FROM itsalgeria/insidjam:stable
MAINTAINER Itsolutions

ADD entrypoint /opt/odoo/entrypoint
ENTRYPOINT ["/opt/odoo/entrypoint"]
