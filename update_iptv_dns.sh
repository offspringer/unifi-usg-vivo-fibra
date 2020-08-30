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

# must be in configure mode to test if dhcp-server exists
if ! show service dhcp-server | grep -q "IPTV"; then 
    message "No DHCP Server found for IPTV."; 
else
    message -l "Begin DHCP Server update for IPTV..."

    # detecting DHCP Server info 
    iptv_network_name=$(run show dhcp statistics | grep IPTV | awk '{ print $1 }')
    iptv_subnet_mask=$(run show dhcp statistics | grep IPTV | awk '{ split($1, a, "_|-"); print a[4]"/"a[5]; }')

    if [[ -n "$iptv_network_name" && -n "$iptv_subnet_mask" ]] ; then
        # retrieving DNS info from IPTV DHCP client lease
        dns1=$(run show dhcp client leases | grep 'name server' | awk '{ print $3 }')
        dns2=$(run show dhcp client leases | grep 'name server' | awk '{ print $4 }')

        if [[ -n "$dns1" && -n "$dns2" ]] ; then
            reset_iptv_dns_cmd=$(echo "delete service dhcp-server shared-network-name $iptv_network_name subnet $iptv_subnet_mask dns-server")
            update_iptv_dns1_cmd=$(echo "set service dhcp-server shared-network-name $iptv_network_name subnet $iptv_subnet_mask dns-server $dns1")    
            update_iptv_dns2_cmd=$(echo "set service dhcp-server shared-network-name $iptv_network_name subnet $iptv_subnet_mask dns-server $dns2")

            eval $reset_iptv_dns_cmd
            eval $update_iptv_dns1_cmd
            eval $update_iptv_dns2_cmd

            commit
            save
        fi
    fi

    message -l "End DHCP Server update for IPTV."
fi
    
exit