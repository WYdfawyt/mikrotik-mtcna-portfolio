# MikroTik MTCNA Portfolio: Lab Training RouterOS v7

Portofolio praktik **MikroTik RouterOS v7**: dokumentasi tiga hari training MTCNA di perangkat nyata. Setiap lab berisi tujuan, topologi, tabel alamat, konfigurasi, penjelasan, bukti verifikasi, troubleshooting, dan hal yang dipelajari.

> **Sertifikasi:** MikroTik Certified Network Associate (MTCNA), lulus ujian 21 Oktober 2026.

## Isi repositori

| Bagian | Isi | Status |
|--------|-----|--------|
| [01-training-mtcna](01-training-mtcna) | Laporan Day 1 - Day 3 dengan screenshot lab hardware (MikroTik hAP ax lite) | Selesai |
| [configs](configs) | Konfigurasi akhir router training (sudah disanitasi) | Selesai |

## Topik yang dicakup

| Topik | Hari |
|-------|:----:|
| Wi-Fi station, DHCP client | Day 1 |
| DHCP server, NAT masquerade | Day 1, 2 |
| Hardening layanan manajemen (port, available-from, user) | Day 2 |
| Bridge, DHCP lease, ARP | Day 2 |
| Dua router dan routing statis (link /30) | Day 2 |
| Simple Queue dan PCQ | Day 2 |
| Firewall filter (input dan forward), address list | Day 3 |
| VPN L2TP/IPsec (site-to-site dan remote access) | Day 3 |

## Teknologi

MikroTik RouterOS v7 (hAP ax lite), WinBox, subnetting /30 untuk link point-to-point, Windows (ipconfig, arp, ping).

## Keamanan

- Password Wi-Fi, secret IPsec, dan password PPP **tidak ada** di repositori (diganti `<REDACTED>` atau placeholder)
- File backup biner (`.backup`) tidak diunggah dan masuk `.gitignore`
- Screenshot yang menampilkan password, daftar jaringan Wi-Fi lain, foto orang, atau IP publik tidak disertakan atau sudah dipotong

## Portofolio lain

- [ccna-network-portfolio](https://github.com/WYdfawyt/ccna-network-portfolio): lab Cisco Packet Tracer (HSRP, Inter-VLAN, dan lainnya)
- [zabbix-nms-lab](https://github.com/WYdfawyt/zabbix-nms-lab): monitoring server dan jaringan dengan Zabbix, Docker, dan alert Telegram

## Penulis

CAHAYA JAYA PRABASA | LinkedIn: https://www.linkedin.com/in/cahaya-jaya-prabasa | Email: cahayaprabasa@gmail.com
