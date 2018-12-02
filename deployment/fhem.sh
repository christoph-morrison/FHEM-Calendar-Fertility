#!/usr/bin/env bash

test -z "$APT_BIN" && APT_BIN="apt"

function install_fhem {
    echo
    echo
    echo Installing FHEM
    
    sources="/etc/apt/sources.list"

    # save original
    cp "${sources}" "${sources}.tmp"

    # add fhem sources and install
    wget -qO - http://debian.fhem.de/archive.key | apt-key add -
    echo >> "${sources}"
    echo >> "${sources}"
    echo "deb http://debian.fhem.de/nightly/ /" >> "${sources}"
    ${APT_BIN} update
    ${APT_BIN} install -y fhem

    # restore original
    cp "${sources}.tmp" "${sources}"
    ${APT_BIN} update
}

install_fhem