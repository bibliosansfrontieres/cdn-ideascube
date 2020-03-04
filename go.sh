#!/bin/bash

ANSIBLECAP_PATH="/var/lib/ansible/local"
GIT_REPO_URL="https://github.com/bibliosansfrontieres/cdn-ideascube.git"
ANSIBLE_BIN="/usr/bin/ansible-pull"
ANSIBLE_LOGS="/var/log/ansible-pull.log"
ANSIBLE_ETC="/etc/ansible/facts.d/"
TAGS=""
BRANCH="master"
GIT_RELEASE_TAG="0.0.1"
STORAGE=""

[ $EUID -eq 0 ] || {
    echo "Error: you have to be root to run this script." >&2
    exit 1
}

function internet_check()
{
    echo "[+] Check Internet connection..."
    if [[ ! `ping -q -c 2 github.com` ]]
    then
        echo "ERROR: Repository is unreachable, check your Internet connection." >&2
        exit 1
    fi
    echo "[+] ... connection is ok."
}

function install_ansible()
{
    internet_check
    echo "[+] Install ansible PPA..."
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    echo "[+] Update packages..."
    apt-get update --quiet --quiet
    echo "[+] Install ansible and its requirements..."
    apt-get install --quiet --quiet -y ansible git python-apt
    echo '[+] ... ansible installed.'
}

function clone_ansiblecube()
{
    internet_check

    echo "[+] Clone cdn-ideascube repo..."
    mkdir --mode 0755 -p ${ANSIBLECAP_PATH}
    cd ${ANSIBLECAP_PATH}/../
    git clone ${GIT_REPO_URL} local

    mkdir --mode 0755 -p ${ANSIBLE_ETC}
    cp ${ANSIBLECAP_PATH}/hosts /etc/ansible/hosts
    echo '[+] ... cdn-ideascube repo cloned.'
}

[ -x ${ANSIBLE_BIN} ] || install_ansible
[ -d ${ANSIBLECAP_PATH} ] || clone_ansiblecube

echo "$( date ) go.sh" >> $ANSIBLE_LOGS
[ $? -ne 0 ] && {
    echo "No space left to write logs or permission problem, exiting." >&2
    exit 1
}


while [[ $# -gt 0 ]]
do
    case $1 in

        -c|--country)

            if [ -z "$2" ]
            then
                echo -e "\n\t[+] ERROR\n\t--country : Missing country name, ex: france\n"

                exit 0;
            fi
            COUNTRY=$2

        shift
        ;;

        -p|--project_name)

            if [ -z "$2" ]
            then
                echo -e "\n\t[+] ERROR\n\t--project_name : Missing project name\n"

                exit 0;
            fi
            PROJECT=$2

        shift
        ;;

    esac
    shift
done

cd $ANSIBLECAP_PATH

echo "[+] Running the playbook..."

$ANSIBLE_BIN --purge -C $BRANCH -d $ANSIBLECAP_PATH -i hosts -U $GIT_REPO_URL main.yml --extra-vars "country=$COUNTRY project_name=$PROJECT"
