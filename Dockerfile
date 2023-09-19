FROM binhex/arch-base:latest
LABEL org.opencontainers.image.authors = "binhex"
LABEL org.opencontainers.image.source = "https://github.com/binhex/arch-readarr"

# additional files
##################

# add supervisor conf file for app
ADD build/*.conf /etc/supervisor/conf.d/

# add install bash script
ADD build/root/*.sh /root/

# release tag name from buildx arg
ARG RELEASETAG

# arch from buildx --platform, e.g. amd64
ARG TARGETARCH

# add start bash script
ADD run/nobody/*.sh /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh && \
	/bin/bash /root/install.sh "${RELEASETAG}" "${TARGETARCH}"

# docker settings
#################

# expose port for http web ui
EXPOSE 8787

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]