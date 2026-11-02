# Konfigurasi akhir router training MTCNA (MikroTik hAP ax lite, RouterOS 7.23.8)
# Ekspor tanggal 21 Okt 2026. Disanitasi sebelum dipublikasikan:
#   - passphrase Wi-Fi, secret IPsec, dan password PPP diganti <REDACTED>
#   - serial number, software id, dan MAC address klien dihapus
# Catatan: file .backup biner TIDAK diunggah karena berisi kredensial.
# 2026-10-21 14:00:22 by RouterOS 7.23.8
#
# model = L41G-2axD
/interface bridge
add name=br-lan
/interface wifi
set [ find default-name=wifi1 ] configuration.mode=station .ssid=IDN \
    disabled=no security.authentication-types=wpa-psk,wpa2-psk .passphrase=\
    <REDACTED>
/ip pool
add name=dhcp_pool0 ranges=192.168.88.2-192.168.88.254
add name=dhcp_pool1 ranges=192.168.111.2-192.168.111.254
add name=POOL-VPN-WFH ranges=10.100.1.2-10.100.1.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=br-lan name=dhcp1
add address-pool=dhcp_pool1 interface=ether4 name=dhcp2
/ppp profile
add local-address=10.100.1.1 name=PROFILE-VPN-WFH remote-address=POOL-VPN-WFH
/queue simple
add dst=192.168.111.0/32 max-limit=100M/100M name="LAN-TO LAN" target=""
/queue type
add kind=pcq name=PCQ-DOWNLOAD-2M pcq-classifier=dst-address pcq-rate=2M
add kind=pcq name=PCQ-UPLOAD-2M pcq-classifier=src-address pcq-rate=2M
set 7 pcq-rate=2M
set 8 pcq-rate=2M
/queue simple
add max-limit=10M/10M name=LIMIT-LAN-LT-1 queue=PCQ-DOWNLOAD-2M/PCQ-UPLOAD-2M \
    target=192.168.111.0/24
add max-limit=20M/20M name=LIMIT-VIP-LT-1 queue=PCQ-DOWNLOAD-2M/PCQ-UPLOAD-2M \
    target=192.168.111.253/32
/interface bridge port
add bridge=br-lan interface=ether2
add bridge=br-lan interface=ether3
/interface l2tp-server server
set enabled=yes ipsec-secret=<REDACTED> use-ipsec=yes
/ip address
add address=192.168.88.1/24 interface=br-lan network=192.168.88.0
add address=192.168.111.1/24 comment=DHCP interface=ether4 network=\
    192.168.111.0
/ip dhcp-client
add interface=wifi1 name=client1
/ip dhcp-server lease
add address=192.168.88.253 client-id=<REDACTED> mac-address=\
    XX:XX:XX:XX:XX:XX server=dhcp1
/ip dhcp-server network
add address=192.168.88.0/24 gateway=192.168.88.1
add address=192.168.111.0/24 gateway=192.168.111.1
/ip firewall address-list
add address=192.168.111.0/24 list="IP-CLIENT "
add address=192.168.222.0/24 list="IP-CLIENT "
add address=192.168.88.0/24 list="IP-CLIENT "
add address=facebook.com list=IP-SOSMED
add address=instragam.com list=IP-SOSMED
add address=x.com list=IP-SOSMED
add address=tiktok.com list="IP-CLIENT "
add address=youtube.com list=YOUTUBE
add address=idn.id list=IP-IDN
/ip firewall filter
add action=drop chain=input dst-port=51122,51928,51180 log=yes log-prefix=\
    ACCESS-ROUTER protocol=tcp src-address=!192.168.111.253
add action=reject chain=forward comment=BLOCK-SOSMED dst-address-list=\
    IP-SOSMED reject-with=icmp-network-unreachable src-address-list=\
    "IP-CLIENT "
add action=reject chain=forward comment=BLOCK-YOUTUBE dst-address-list=\
    YOUTUBE reject-with=icmp-network-unreachable src-address-list=\
    "IP-CLIENT "
add action=reject chain=forward comment=BLOCK-IDN dst-address-list=IP-IDN \
    reject-with=icmp-network-unreachable src-address-list="IP-CLIENT "
/ip firewall nat
add action=masquerade chain=srcnat out-interface=wifi1
/ip route
add check-gateway=ping disabled=no distance=1 dst-address=192.168.222.0/24 \
    gateway=10.10.10.2 routing-table=main scope=30 target-scope=10
/ip service
set ftp disabled=yes
set telnet disabled=yes
set reverse-proxy disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh port=51122
set www port=51180
set winbox port=51928
/ppp secret
add local-address=10.10.10.1 name=pppL2TP password=<REDACTED> remote-address=\
    10.10.10.2
add name=wfh password=<REDACTED> profile=PROFILE-VPN-WFH
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=MTCNA-BASA
