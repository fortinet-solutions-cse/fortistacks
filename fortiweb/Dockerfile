# Dockerfile for ingesting config to FWEB Docker
FROM alpine
LABEL maintainer="Nicolas Thomas <nthomas@fortinet.com>" provider="Fortinet"
#Update the az software repository inside the dockerfile with the 'RUN' command.
RUN apk add gettext gzip bash && mkdir -p templates
ENV TARGET_IP none
COPY defaut-conf.tmpl sys_domain.root.conf sys_global.conf.gz templates/
COPY fweb-cloudinit.sh /
CMD ["fweb-cloudinit.sh"]
