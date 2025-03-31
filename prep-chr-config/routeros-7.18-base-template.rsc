# Static Mikrotik CHR configuration script based on dynamic automatic_gateway_configuration RouterOS Script
# baseline: https://github.com/peterkarpati0/automatic_gateway_configuration/blob/main/01-routeros-7.18-base.rsc
# GitHub Actions Workflow will prepare actual configuration based on this template.
# The idea is to read parameters from deploy-params.json and replace placeholders in this template and prepare actual configuration and push to newly deployed CHR.

# :global routerName nemver
# :global ether1-wan1-IP 172.22.24.254
# :global subnet 24
# :global dhcpStart 172.22.24.224
# :global dhcpEnd 172.22.24.250
# :global dhcpNetAddr 172.22.24.0/24

/system identity set name=$routerName;

/interface list add name=WAN comment="defconf";
/interface list add name=LAN comment="defconf";

/interface set ether1 name=ether1-wan1;
/interface list member add list=WAN interface=ether1-wan1 comment="defconf";

/ip address add address="$ether1-wan1-IP/$subnet" interface=ether1-wan1 comment="defconf";

/ip dns {
    set allow-remote-requests=yes;
    static add name=router.lan address=$ether1-wan1-IP comment=defconf;
}

/ip pool add name="default-dhcp" ranges="$dhcpStart-$dhcpEnd";

/ip dhcp-server add name=defconf address-pool="default-dhcp" interface=bridge lease-time=10m disabled=no;
/ip dhcp-server network add address=$dhcpNetAddr gateway=$ether1-wan1-IP dns-server=$ether1-wan1-IP comment="defconf";

/ip dhcp-client add interface=ether3-lan1 disabled=no comment="defconf";

/ip firewall nat add chain=srcnat out-interface-list=WAN ipsec-policy=out,none action=masquerade comment="defconf: masquerade";

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

/ip neighbor discovery-settings set discover-interface-list=LAN;
/tool mac-server set allowed-interface-list=LAN;
/tool mac-server mac-winbox set allowed-interface-list=LAN;

