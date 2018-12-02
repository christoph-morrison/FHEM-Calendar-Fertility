#! /usr/bin/env bash

#   +----------------------------------------------------------------------------
#   |
#   |   helper functions
#   |
#   +----------------------------------------------------------------------------

# prepare environment
#   See http://www.davidpashley.com/articles/writing-robust-shell-scripts/
set -o nounset
set -o errexit

# catch exits and clean up if any is catched
trap "" INT TERM EXIT

LIBRARY_DIR="/vagrant/deployment/"
LOCALE="de_DE.utf8"

function install_puppet {
    puppet_source="https://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb"
    puppet_target="/tmp/puppet.deb"

    echo '##########################'
    echo '##########################'
    echo Downloading puppet from $puppet_source

    wget -q -O $puppet_target $puppet_source

    echo '##########################'
    echo '##########################'
    echo Installing puppet from $puppet_target

    dpkg -i $puppet_target
    aptitude -q update
    aptitude install -y puppet-agent

}

function setup_apt {
    echo '##########################'
    echo '##########################'
    echo Installing aptitude

    command -v aptitude || {
        apt-get install -y aptitude
    }

    export APT_BIN="aptitude"
}

function upgrade_system {
    echo '##########################'
    echo '##########################'
    echo Upgrading system

    aptitude -q update
    aptitude -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" safe-upgrade
}

function install_tools {
    echo '##########################'
    echo '##########################'
    echo Installing base tools

    aptitude install -y htop tree vim git dnsutils
}

function set_time {
    echo '##########################'
    echo '##########################'
    echo "Setup time & time zone"
    
    # set timezone
    echo "Europe/Berlin" > /etc/timezone
    ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata
    
    # update time via ntp
    aptitude install ntpdate
    ntpdate europe.pool.ntp.org

    # activate ntp and set timezone in systemd-mode
    timedatectl set-ntp true
    timedatectl set-timezone Europe/Berlin
    timedatectl
}

function set_locale {

    locale="$LOCALE"

    echo '##########################'
    echo '##########################'
    echo Setup locale   
    
    echo  "${locale} UTF-8" > /etc/locale.gen
    sudo locale-gen ${locale}
    
    #export LC_ALL="${locale}"
    #echo Would export LC_ALL="${locale}"

    #export LANG="${locale}"
    #echo Would export LANG="${locale}"

    #export LANGUAGE="${locale}"
    #echo Would export LANGUAGE="${locale}"
        
    # update locale
    #echo "LANG=${locale}" > /etc/default/locale
    #echo "/etc/default/locale:";
    #cat /etc/default/locale

    sudo update-locale LANG="${locale}"
    sudo update-locale LANGUAGE="${locale}"
    sudo update-locale LC_ALL="${locale}"
    
    # disable sshd's annoying LC_* copy
    sed -e '/AcceptEnv/ s/^#*/#/' -i /etc/ssh/sshd_config
}

#   +----------------------------------------------------------------------------
#   |
#   |   main
#   |
#   +----------------------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

sudo -n su
setup_apt
upgrade_system
install_tools
set_time
set_locale

# install application specific library files
echo "Try to install files in library at ${LIBRARY_DIR}"
test -d "${LIBRARY_DIR}" && {
    echo "Found a library folder"
    for lib_file in $(find ${LIBRARY_DIR} -iname '*.sh');
    do
        echo "Executing file ${lib_file}"
        bash ${lib_file};
    done
}