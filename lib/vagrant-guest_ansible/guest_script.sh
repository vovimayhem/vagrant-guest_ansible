#!/bin/bash

ANSIBLE_PLAYBOOK=$1
ANSIBLE_HOSTS=$2
ANSIBLE_EXTRA_VARS="$3"
ANSIBLE_GIT_URL="$4"
TEMP_HOSTS="/tmp/ansible_hosts"

if [ ! -f /vagrant/$ANSIBLE_PLAYBOOK ]; then
        echo "ERROR: Cannot find the given Ansible playbook."
        exit 1
fi

if [ ! -f /vagrant/$ANSIBLE_HOSTS ]; then
        echo "ERROR: Cannot find the given Ansible hosts file."
        exit 2
fi

if ! command -v ansible >/dev/null; then
        echo "Installing Ansible dependencies and Git."
        if command -v yum >/dev/null; then
                sudo yum install -y gcc git python python-devel
        elif command -v apt-get >/dev/null; then
                sudo apt-get update -qq
                #sudo apt-get install -y -qq git python-yaml python-paramiko python-jinja2
                sudo apt-get install -y -qq git python python-dev
        else
                echo "neither yum nor apt-get found!"
                exit 1
        fi
        echo "Installing pip via get-pip."
        curl --silent --show-error https://bootstrap.pypa.io/get-pip.py -O
        sudo python get-pip.py && rm -f get-pip.py
        # Make sure setuptools are installed correctly.
        sudo pip install setuptools --no-use-wheel --upgrade
        echo "Installing required python modules."
        sudo pip install paramiko pyyaml jinja2 markupsafe

        echo "Installing Ansible."
        if [ ! -z "$ANSIBLE_GIT_URL" ]; then
          sudo pip install -U -e git+${ANSIBLE_GIT_URL}#egg=ansible
        else
          sudo pip install ansible
        fi
fi

if [ ! -z "$ANSIBLE_EXTRA_VARS" -a "$ANSIBLE_EXTRA_VARS" != " " ]; then
        ANSIBLE_EXTRA_VARS=" --extra-vars $ANSIBLE_EXTRA_VARS"
fi

# stream output
export PYTHONUNBUFFERED=1
# show ANSI-colored output
export ANSIBLE_FORCE_COLOR=true

cp /vagrant/${ANSIBLE_HOSTS} ${TEMP_HOSTS} && chmod -x ${TEMP_HOSTS}
echo "Running Ansible as $USER:"
ansible-playbook /vagrant/${ANSIBLE_PLAYBOOK} --inventory-file=${TEMP_HOSTS} --connection=local $ANSIBLE_EXTRA_VARS
rm ${TEMP_HOSTS}
