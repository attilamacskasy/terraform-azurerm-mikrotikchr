# 2023-06-28 12:18:51 by RouterOS 7.10rc6
# software id = 
#

# TODO: 94.21.131.88 is DHCP address of on-premises LAB
# TODO: update public-key is from on-premises wireguard config 

# 192.168.254.1 - on-premises side of wireguard
# 192.168.254.2 - azure side of wireguard

# general setting
/system identity set name=vm-chr-az
/system note set show-at-login=no
/ipv6 settings set disable-ipv6=yes

# set confiuration of main nic 
/interface ethernet set [ find default-name=ether1 ] disable-running-check=no name=ether1-gateway
/ip dhcp-client add interface=ether1-gateway

# setting up site2site VPN using wireguard
/interface wireguard add listen-port=13231 mtu=1350 name=wireguard-az-to-onpremlab
/interface wireguard peers add allowed-address=172.22.22.0/24,192.168.254.1/32 endpoint-address=94.21.131.88 endpoint-port=13231 interface=wireguard-az-to-onpremlab public-key="lsJGmrsggb89uvzdZp/l3e1uSH5dKXF9gS8H4c+6TiA="
/ip address add address=192.168.254.2/24 interface=wireguard-az-to-onpremlab network=192.168.254.0

# allowing Azure networks for BGP
/ip firewall address-list add address=172.17.1.0/24 list=BGP

/ip firewall filter
add action=accept chain=forward log=yes
add action=accept chain=input dst-port=8291 protocol=tcp
add action=accept chain=input dst-port=13231 protocol=udp src-address=94.21.131.88
add action=accept chain=input

/ip firewall mangle add action=change-mss chain=forward new-mss=1350 out-interface=wireguard-az-to-onpremlab passthrough=yes protocol=tcp tcp-flags=syn tcp-mss=1351-65535

/routing bgp connection add address-families=ip as=65530 disabled=no local.address=192.168.254.2 \
    .role=ebgp name=onprem output.network=BGP .redistribute=bgp \
    remote.address=192.168.254.1/32 .as=65540 router-id=192.168.254.2 \
    routing-table=main templates=default
