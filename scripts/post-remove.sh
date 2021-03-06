#!/bin/bash

function disable_systemd {
    systemctl disable telegraf
    rm -f /lib/systemd/system/telegraf.service
}

function disable_update_rcd {
    update-rc.d -f telegraf remove
    rm -f /etc/init.d/telegraf
}

function disable_chkconfig {
    chkconfig --del telegraf
    rm -f /etc/init.d/telegraf
}

if [[ -f /etc/redhat-release ]]; then
    # RHEL-variant logic
    if [[ "$1" = "0" ]]; then
        # InfluxDB is no longer installed, remove from init system
        rm -f /etc/default/telegraf

        if [[ "$(readlink /proc/1/exe)" == */systemd ]]; then
            disable_systemd
        else
            # Assuming sysv
            disable_chkconfig
        fi
    fi
elif [[ -f /etc/debian_version ]]; then
    # Debian/Ubuntu logic
    if [ "$1" == "remove" -o "$1" == "purge" ]; then
        # Remove/purge
        rm -f /etc/default/telegraf

        if [[ "$(readlink /proc/1/exe)" == */systemd ]]; then
            disable_systemd
        else
            # Assuming sysv
            # Run update-rc.d or fallback to chkconfig if not available
            if which update-rc.d &>/dev/null; then
                disable_update_rcd
            else
                disable_chkconfig
            fi
        fi
    fi
elif [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ $ID = "amzn" ]]; then
        # Amazon Linux logic
        if [[ "$1" = "0" ]]; then
            # InfluxDB is no longer installed, remove from init system
            rm -f /etc/default/telegraf
            disable_chkconfig
        fi
    fi
fi
