#!/usr/bin/env bash

set -x

source /vagrant/utils/common-functions

install_ovn

hostname=$(hostname)
ip=${!hostname}

/usr/share/openvswitch/scripts/ovs-ctl start --system-id=$hostname
/usr/share/ovn/scripts/ovn-ctl start_controller

ovs-vsctl set open . external-ids:ovn-bridge=br-int
ovs-vsctl set open . external-ids:ovn-remote=tcp:${central}:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=$ip

ovs-vsctl --may-exist add-br br-ex
sleep 60
ovs-vsctl br-set-external-id br-ex bridge-id br-ex
ovs-vsctl br-set-external-id br-int bridge-id br-int
ovs-vsctl set open . external-ids:ovn-bridge-mappings=external-segment-1:br-ex

# Add eth2 to br-ex
ovs-vsctl add-port br-ex eth2

sleep 3

# Add fake vms
ovn_add_phys_port vm1 40:44:00:00:00:01 192.168.0.11 24 192.168.0.1
