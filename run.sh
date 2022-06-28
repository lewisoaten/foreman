#!/bin/bash


# Fix the hostname problem by removing that check and setting a dummy FQDN:
rm -f /usr/share/foreman-installer/checks/hostname.rb
export FACTER_fqdn="foreman.localdomain" # Dummy/temp FQDN

# no foreman install log? run forman installer
if [ ! -f /var/log/foreman-install.log ]; then
  if [ -f /etc/foreman-installer/scenarios.d/katello-answers.yaml ]; then
    echo 'Answers found, starting quiet install Foreman with Katello'
    foreman-installer --scenario katello \
      --foreman-initial-organization "DemoOrganisation" \
      --foreman-initial-location "Server" \
      --foreman-initial-admin-username admin \
      --foreman-initial-admin-password admin
    if [ $? -ne 0 ]; then exit $?; fi
  else
    echo 'Error: Katello answers file not found!'
    exit 1
  fi
fi
