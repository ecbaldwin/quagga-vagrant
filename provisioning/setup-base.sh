#!/bin/bash

name=$1; shift

bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
bash -c 'echo 1 > /proc/sys/net/ipv6/conf/all/forwarding'

echo "set editing-mode vi" > ~/.inputrc
echo "set editing-mode vi" > /home/ubuntu/.inputrc
chown ubuntu: /home/ubuntu/.inputrc
echo VTYSH_PAGER=less >> /etc/environment
echo EDITOR=vim >> /etc/environment

apt-get update
apt-get install -y quagga traceroute

quagga_conf=etc/quagga

for file in daemons zebra.conf bgpd.conf debian.conf vtysh.conf
do
    cp /vagrant/$quagga_conf/$file /$quagga_conf/$file
    chown quagga:quaggavty /$quagga_conf/$file
done

service quagga restart

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
top) hostaddr=10 ;;
tor-r1) hostaddr=21 ;;
tor-r2) hostaddr=22 ;;
esac

device=enp0s9
ip link set $device up

# Set up the router networks
case $name in
top|tor-r*)
    create_vlan_interface $device 2001 100.100.0.$hostaddr/24
    create_vlan_interface $device 2002 100.100.1.$hostaddr/24
;;
esac

# Set up the rack networks
case $name in
*-r1*) create_vlan_interface $device 3001 203.0.113.$hostaddr/24 ;;
*-r2*) create_vlan_interface $device 3002 198.51.100.$hostaddr/24 ;;
esac
