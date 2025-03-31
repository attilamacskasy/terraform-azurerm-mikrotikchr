# Static Mikrotik CHR configuration script based on dynamic automatic_gateway_configuration RouterOS Script
# baseline: https://github.com/peterkarpati0/automatic_gateway_configuration/blob/main/01-routeros-7.18-base.rsc
# GitHub Actions Workflow will prepare actual configuration based on this template.
# The idea is to read parameters from deploy-params.json and replace placeholders in this template and prepare actual configuration and push to newly deployed CHR.

# proper ${placeholder} syntax that matches key names in deploy-params.json.
# This format is compatible with envsubst, making it clean and easy to inject variables in GitHub Actions.

# Identity
/system identity set name=${router_name};

# Interface lists
/interface list add name=WAN comment="defconf";
/interface list add name=LAN comment="defconf";

# WAN setup
/interface set ether1 name=ether1-wan1;
/interface list member add list=WAN interface=ether1-wan1 comment="defconf";

# WAN static IP
#/ip address add address=${ether1_wan1_ip}/${subnet} interface=ether1-wan1 comment="defconf";

# WAN DHCP - probably better in Azure
/ip dhcp-client add interface=ether1-wan1 disabled=no comment="defconf";

# DNS static IP
# /ip dns {
#     set allow-remote-requests=yes;
#     static add name=router.lan address=${ether1_wan1_ip} comment=defconf;
# }

# DNS DHCP

# DHCP settings - no DHCP in Azure
#/ip pool add name="default-dhcp" ranges=${dhcp_start}-${dhcp_end};
#/ip dhcp-server add name=defconf address-pool="default-dhcp" interface=ether1-wan1 lease-time=10m disabled=no;
#/ip dhcp-server network add address=${dhcp_netaddr} gateway=${bridge_ip} dns-server=${bridge_ip} comment="defconf";

# NAT
/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade comment="defconf: masquerade";

# Firewall rules
/ip firewall {
    filter add chain=input action=accept connection-state=established,related,untracked comment="defconf: accept established, related, untracked";
    filter add chain=input action=drop connection-state=invalid comment="defconf: drop invalid";
    filter add chain=input action=accept protocol=icmp comment="defconf: accept ICMP";
    filter add chain=input action=accept dst-address=127.0.0.1 comment="defconf: accept loopback (for CAPsMAN)";
    filter add chain=input action=drop in-interface-list=!LAN comment="defconf: drop all not from LAN";
    filter add chain=forward action=accept ipsec-policy=in,ipsec comment="defconf: accept inbound IPsec";
    filter add chain=forward action=accept ipsec-policy=out,ipsec comment="defconf: accept outbound IPsec";
    filter add chain=forward action=fasttrack-connection connection-state=established,related comment="defconf: fasttrack";
    filter add chain=forward action=accept connection-state=established,related,untracked comment="defconf: accept established, related, untracked";
    filter add chain=forward action=drop connection-state=invalid comment="defconf: drop invalid";
    filter add chain=forward action=drop connection-state=new connection-nat-state=!dstnat in-interface-list=WAN comment="defconf: drop all from WAN not DSTNATed";
}

# Discovery and MAC access - not needed in Azure 
#/ip neighbor discovery-settings set discover-interface-list=LAN;
#/tool mac-server set allowed-interface-list=LAN;
#/tool mac-server mac-winbox set allowed-interface-list=LAN;
