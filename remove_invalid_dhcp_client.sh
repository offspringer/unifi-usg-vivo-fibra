#!/bin/vbash

function message() { # -i echo if interactive, -l logger, else echo if interactive else logger
    case "$1" in
        -i) shift; if [ -t 0 ]; then echo "$@"; fi;;
        -l) shift; logger -t "VIVO" "$@";;
        *) if [ -t 0 ]; then echo "$@"; else logger -t "VIVO" "$@"; fi;;
    esac
} # message

source /opt/vyatta/etc/functions/script-template

configure

# must be in configure mode to test if dhcp-client exists
if ! show interfaces ethernet eth0 vif 10 address | grep -q "dhcp"; then
    message "No DHCP client found for eth0.10.";
else
    message -l "Begin DHCP client removal for eth0.10..."

    delete interfaces ethernet eth0 vif 10 address dhcp
    commit
    save

    message -l "End DHCP client removal for eth0.10."
fi

exit