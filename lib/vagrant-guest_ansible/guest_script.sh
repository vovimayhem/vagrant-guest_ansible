#!/bin/bash

ANSIBLE_DIR=$1
ANSIBLE_PLAYBOOK=$2
ANSIBLE_HOSTS=$3
ANSIBLE_EXTRA_VARS=$4
TEMP_HOSTS="/tmp/ansible_hosts"

if [ ! -f /vagrant/$ANSIBLE_PLAYBOOK ]; then
        echo "ERROR: Cannot find the given Ansible playbook."
        exit 1
fi

if [ ! -f /vagrant/$ANSIBLE_HOSTS ]; then
        echo "ERROR: Cannot find the given Ansible hosts file."
        exit 2
fi

if [ ! -d $ANSIBLE_DIR ]; then
        echo -n "Updating apt cache..."
        sudo apt-get update -qq
        echo " DONE!"

        echo -n "Installing Ansible dependencies and Git..."
        sudo apt-get install -y -qq git python-yaml python-paramiko python-jinja2
        echo " DONE!"

        # Clone ansible:
        sudo git clone git://github.com/ansible/ansible.git ${ANSIBLE_DIR}
fi

if [ ! -z "$ANSIBLE_EXTRA_VARS" -a "$ANSIBLE_EXTRA_VARS" != " " ]; then
        ANSIBLE_EXTRA_VARS=" --extra-vars \"$ANSIBLE_EXTRA_VARS\""
fi

# stream output and show colors
export PYTHONUNBUFFERED=1
export ANSIBLE_FORCE_COLOR=true

cd ${ANSIBLE_DIR}
cp /vagrant/${ANSIBLE_HOSTS} ${TEMP_HOSTS} && chmod -x ${TEMP_HOSTS}
echo "Running Ansible as $USER:"
bash -c "source hacking/env-setup && ansible-playbook /vagrant/${ANSIBLE_PLAYBOOK} --inventory-file=${TEMP_HOSTS} --connection=local $ANSIBLE_EXTRA_VARS"
rm ${TEMP_HOSTS}
