FROM centos:7.9.2009

# Setup Systemd
ENV container docker

RUN echo "Setting up systemd" \
    && (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done) \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
    && rm -f /etc/systemd/system/*.wants/* \
    && rm -f /lib/systemd/system/local-fs.target.wants/* \
    && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /lib/systemd/system/basic.target.wants/* \
    && rm -f /lib/systemd/system/anaconda.target.wants/* \
    && echo 'root' | passwd --stdin root \
    && echo "Systemd setup"

VOLUME [ "/sys/fs/cgroup" ]

ENV foreman_version 3.2
ENV katello_version 4.4

RUN echo "Installing dependencies" \
    # Setup required repos
    && yum -y localinstall https://yum.theforeman.org/releases/"${foreman_version}"/el7/x86_64/foreman-release.rpm \
    && yum -y localinstall https://yum.theforeman.org/katello/"${katello_version}"/katello/el7/x86_64/katello-repos-latest.rpm \
    && yum -y localinstall https://yum.puppet.com/puppet7-release-el-7.noarch.rpm \
    && yum -y install epel-release centos-release-scl-rh \
    # Install Katello
    && yum -y update \
    && yum -y install openssh-server openssh-clients foreman-installer-katello \
    # Cleanup
    && yum clean all \
  	&& rm -rf /var/cache/yum \
    && echo "Dependencies installed"

#Adding the Configuration files
ADD run.sh /
ADD installer.service etc/systemd/system/
ADD foreman-answers.yaml /etc/foreman-installer/scenarios.d/
ADD katello-answers.yaml /etc/foreman-installer/scenarios.d/

RUN echo "Configure systemd service" \
    # Setup required repos
    && systemctl enable installer.service \
    && echo "Done configuring systemd service"

### ports
# puppet (via apache)
EXPOSE 8140
# foreman-proxy
EXPOSE 8443
# foreman (via apache) and provisioning purposes
EXPOSE 80
# api communication
EXPOSE 443
EXPOSE 8080
# qpid ssl
EXPOSE 5671
# smart proxy
EXPOSE 9090

CMD ["/usr/sbin/init"]
#CMD ["/run.sh"]
