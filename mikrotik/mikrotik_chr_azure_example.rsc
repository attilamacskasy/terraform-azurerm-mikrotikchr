# 2023-06-28 12:18:51 by RouterOS 7.10rc6
# software id = 
#

/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no name=ether1-gateway

/interface wireguard
add listen-port=13231 mtu=1350 name=wireguard-to-onpremvmware

/disk
set slot1 type=hardware
add parent=slot1 partition-number=1 partition-offset="1 048 576" \
    partition-size="8 587 837 440" type=partition

/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik

/port
set 0 name=serial0
set 1 name=serial1

/ipv6 settings
set disable-ipv6=yes

/interface wireguard peers
add allowed-address=172.22.22.0/24,192.168.255.1/32 endpoint-address=\
    77.234.92.201 endpoint-port=13231 interface=wireguard-to-onpremvmware \
    public-key="***"

/ip address
add address=192.168.255.2/24 interface=wireguard-to-onpremvmware network=\
    192.168.255.0

/ip dhcp-client
add interface=ether1-gateway

/ip firewall address-list
add address=172.16.0.0/24 list=BGP
add address=172.16.1.0/24 list=BGP
add address=172.16.2.0/24 list=BGP
add address=172.16.3.0/24 list=BGP

/ip firewall filter
add action=accept chain=forward log=yes
add action=accept chain=input dst-port=8291 protocol=tcp
add action=accept chain=input dst-port=13231 protocol=udp src-address=\
    77.234.92.201
add action=accept chain=input
add action=accept chain=output log-prefix=Output-

/ip firewall mangle
add action=change-mss chain=forward new-mss=1350 out-interface=\
    wireguard-to-onpremvmware passthrough=yes protocol=tcp tcp-flags=syn \
    tcp-mss=1351-65535

/routing bgp connection
add address-families=ip as=65530 disabled=no local.address=192.168.255.2 \
    .role=ebgp name=onprem output.network=BGP .redistribute=bgp \
    remote.address=192.168.255.1/32 .as=65540 router-id=192.168.255.2 \
    routing-table=main templates=default

/system identity
set name=vm-chr-prod-001

/system note
set show-at-login=no
