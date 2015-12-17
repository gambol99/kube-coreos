#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

install -d -m 0700 ${HOME}/.ssh

annonce "Checking if the keypair has been generated"
if [ ! -f "${KEYPAIR_PRIVATE}" ]; then
  annonce "Generating the keypair for the platform: ${KEYPAIR_PRIVATE}"
  /usr/bin/ssh-keygen -t rsa -b 2048 -f ${KEYPAIR_PRIVATE} -N ''
fi

annonce "Copying the private key into the SSH"
cp ${KEYPAIR_PRIVATE} ${HOME}/.ssh/id_rsa

if [ ! -f "${HOME}/.ssh/config" ]; then
  cat <<EOF > ${HOME}/.ssh/config
Host *
  User core
EOF
fi
