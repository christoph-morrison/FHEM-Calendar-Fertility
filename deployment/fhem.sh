#!/usr/bin/env bash

test -z "$APT_BIN" && APT_BIN="apt"

function install_fhem {
    echo
    echo
    echo Installing FHEM
    
    sources="/etc/apt/sources.list.d/fhem.list"

    # add fhem sources and install
    wget -qO - http://debian.fhem.de/archive.key | apt-key add -
    echo "deb http://debian.fhem.de/nightly/ /" >> "${sources}"
    ${APT_BIN} update
    ${APT_BIN} install -y fhem

    # restore original
    rm "${sources}"
    ${APT_BIN} update

    sudo cp /opt/fhem/contrib/init-scripts/fhem.service /etc/systemd/system/fhem.service
    sudo systemctl --system daemon-reload
    sudo systemctl enable fhem.service
}

install_fhem