#!/bin/bash

# configuration
ANSIBLE_ETC="/etc/ansible/facts.d/"
ANSIBLE_BIN="/home/koombookdoctor/ansible2.2/bin/ansible-pull"
ANSIBLECUBE_PATH="/var/lib/ansible/local"
GIT_REPO_URL="https://github.com/ideascube/koombook-doctor.git"
BRANCH="master"

DISTRIBUTION_CODENAME=$(lsb_release -sc)

# functions
function internet_check()
{
    echo -n "[+] Check Internet connection... "
    if [[ ! `ping -q -c 2 github.com` ]]
    then
        echo "ERROR: Repository is unreachable, check your Internet connection." >&2
        exit 1
    fi
    echo "Done."
}

function update_sources_list()
{
    if [[ "Debian" == `lsb_release -is` ]]
    then
    cat <<EOF > /etc/apt/sources.list
deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free

# jessie-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free

# jessie-backports, previously on backports.debian.org
deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free
EOF
    fi
}

function install_ansible()
{
    internet_check

    echo -n "[+] Updating APT cache... "
    update_sources_list
    apt-get update --quiet --quiet
    echo 'Done.'

    echo -n "[+] Install ansible... "
    apt-get install --quiet --quiet -y python-pip git python-dev libffi-dev libssl-dev python-setuptools python-virtualenv virtualenv
    pip install --upgrade pip
    virtualenv /home/koombookdoctor/ansible2.2
    source /home/koombookdoctor/ansible2.2/bin/activate
    pip install ansible==2.2.0 markupsafe
    pip install cryptography --upgrade
    echo 'Done.'
}

function clone_ansiblecube()
{
    echo -n "[+] Checking for internet connectivity... "
    internet_check
    echo 'Done.'

    echo -n "[+] Clone ansiblecube repo... "
    mkdir --mode 0755 -p ${ANSIBLECUBE_PATH}
    cd ${ANSIBLECUBE_PATH}/../
    git clone $GIT_REPO_URL local

    mkdir --mode 0755 -p /etc/ansible/facts.d
    cp ${ANSIBLECUBE_PATH}/hosts /etc/ansible/hosts
    echo 'Done.'
}

[ $EUID -eq 0 ] || {
    echo "Error: you have to be root to run this script." >&2
    exit 1
}

[ "$DISTRIBUTION_CODENAME" == jessie ] || {
    echo "Error: AnsibleCube run exclusively on Debian Jessie" >&2
    exit 1
}

echo "[+] Install Ansible"
[ -x /usr/local/bin/ansible ] || install_ansible

echo "[+] Clone koombook-doctor repository"
[ -d ${ANSIBLECUBE_PATH} ] || clone_ansiblecube

echo "[+] Start ansible-pull... (log: /var/log/ansible-pull.log)"
echo "Launching : $ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml"
$ANSIBLE_BIN -C $BRANCH -d $ANSIBLECUBE_PATH -i hosts -U $GIT_REPO_URL main.yml > /var/log/ansible-pull.log 2>&1

echo "[+] Done."
