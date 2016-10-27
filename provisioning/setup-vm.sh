#!/bin/bash

name=$1; shift

echo "set editing-mode vi" > ~/.inputrc
echo "set editing-mode vi" > /home/ubuntu/.inputrc
chown ubuntu: /home/ubuntu/.inputrc
echo EDITOR=vim >> /etc/environment

apt-get update
apt-get install -y traceroute

modprobe 8021q

create_vlan_interface() {
    local device=$1; shift
    local vlan_id=$1; shift
    local address=$1; shift

    vconfig add $device $vlan_id
    ip addr add $address dev $device.$vlan_id
    ip link set $device.$vlan_id up
}

case $name in
vm1) hostaddr=41 ;;
vm2) hostaddr=42 ;;
esac

device=enp0s9
ip link set $device up

# Set up the rack networks
case $name in
vm1) create_vlan_interface $device 3001 203.0.113.$hostaddr/24 ;;
vm2) create_vlan_interface $device 3002 198.51.100.$hostaddr/24 ;;
esac
