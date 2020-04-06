#!/usr/bin/env bash

ovn-nbctl ls-add network1
ovn-nbctl lsp-add network1 vm1
ovn-nbctl lsp-set-addresses vm1 "40:44:00:00:00:01 192.168.0.11"
ovn-nbctl lsp-add network1 vm2
ovn-nbctl lsp-set-addresses vm2 "40:44:00:00:00:02 192.168.0.12"

ovn-nbctl ls-add network2
ovn-nbctl lsp-add network2 vm3
ovn-nbctl lsp-set-addresses vm3 "40:44:00:00:00:03 192.168.1.13"

# Provider network
ovn-nbctl ls-add public

# Segment 1
ovn-nbctl lsp-add public public-segment-1-localnet
ovn-nbctl lsp-set-type public-segment-1-localnet localnet
ovn-nbctl lsp-set-addresses public-segment-1-localnet unknown
ovn-nbctl lsp-set-options public-segment-1-localnet network_name=external-segment-1

# Segment 2
ovn-nbctl lsp-add public public-segment-2-localnet
ovn-nbctl lsp-set-type public-segment-2-localnet localnet
ovn-nbctl lsp-set-addresses public-segment-2-localnet unknown
ovn-nbctl lsp-set-options public-segment-2-localnet network_name=external-segment-2

ovn-nbctl lr-add router
# LRP for segment 1
ovn-nbctl lrp-add router router-segment-1-net1 40:44:00:00:00:04 192.168.0.1/24
ovn-nbctl lsp-add network1 net1-router-segment-1
ovn-nbctl lsp-set-type net1-router-segment-1 router
ovn-nbctl lsp-set-addresses net1-router-segment-1 router
ovn-nbctl lsp-set-options net1-router-segment-1 router-port=router-segment-1-net1

ovn-nbctl lrp-add router router-segment-1-net2 40:44:00:00:00:05 192.168.1.1/24
ovn-nbctl lsp-add network2 net2-router-segment-1
ovn-nbctl lsp-set-type net2-router-segment-1 router
ovn-nbctl lsp-set-addresses net2-router-segment-1 router
ovn-nbctl lsp-set-options net2-router-segment-1 router-port=router-segment-1-net2

ovn-nbctl lrp-add router router-segment-1-public 40:44:00:00:00:06 172.24.4.1/24
ovn-nbctl lsp-add public public-router-segment-1
ovn-nbctl lsp-set-type public-router-segment-1 router
ovn-nbctl lsp-set-addresses public-router-segment-1 router
ovn-nbctl lsp-set-options public-router-segment-1 router-port=router-segment-1-public

# LRP for segment 2
ovn-nbctl lrp-add router router-segment-2-public 40:45:00:00:00:30 172.24.6.1/24
ovn-nbctl lsp-add public public-router-segment-2
ovn-nbctl lsp-set-type public-router-segment-2 router
ovn-nbctl lsp-set-addresses public-router-segment-2 router
ovn-nbctl lsp-set-options public-router-segment-2 router-port=router-segment-2-public

ovn-nbctl --id=@gc0 create Gateway_Chassis name=public-segment-1-gw1 chassis_name=gw1 priority=10 -- --id=@gc1 create Gateway_Chassis name=public-segment-2-gw2 chassis_name=gw2 priority=10 -- set Logical_Router_Port router-segment-1-public 'gateway_chassis=[@gc0]' -- set Logical_Router_Port router-segment-2-public 'gateway_chassis=[@gc1]'

ovn-nbctl lr-nat-add router snat 172.24.4.1 192.168.0.0/24
ovn-nbctl lr-nat-add router dnat_and_snat 172.24.4.100 192.168.0.11 vm1 40:44:00:00:00:07
ovn-nbctl lr-nat-add router snat 172.24.6.1 192.168.1.0/24
ovn-nbctl lr-nat-add router dnat_and_snat 172.24.6.101 192.168.0.12 vm2 40:44:00:00:00:08
