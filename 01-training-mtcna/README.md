# Training MikroTik MTCNA (hardware nyata)

Dokumentasi tiga hari training **MikroTik Certified Network Associate (MTCNA)**, 19 - 21 Oktober 2026, memakai perangkat MikroTik hAP ax lite, RouterOS v7, dan WinBox. Semua screenshot berasal dari lab langsung, lalu dirapikan menjadi laporan per hari.

| Hari | Topik | Dokumen |
|------|-------|---------|
| Day 1 | Uplink Wi-Fi (station), DHCP client dan server, NAT masquerade, versi RouterOS | [day1-internet-dhcp-nat.md](day1-internet-dhcp-nat.md) |
| Day 2 | Hardening layanan manajemen, DHCP lease dan ARP, bridge, dua router dengan routing statis, Simple Queue dan PCQ | [day2-management-bridge-routing-qos.md](day2-management-bridge-routing-qos.md) |
| Day 3 | Firewall filter (input dan forward), address list, blokir situs, VPN L2TP/IPsec | [day3-firewall-vpn.md](day3-firewall-vpn.md) |

Konfigurasi akhir router (sudah disanitasi): [`../configs/training-router-sanitized.rsc`](../configs/training-router-sanitized.rsc)

## Catatan koreksi konfigurasi

Saat meninjau ulang hasil lab, ada dua hal yang sebaiknya diperbaiki jika konfigurasi ini dipakai lagi:

- **Address list:** satu entri domain terdaftar pada list dengan nama yang diakhiri spasi (`"IP-CLIENT "`) dan satu domain salah ketik, sehingga tidak masuk list yang dipakai rule blokir.
- **Queue type:** pada Simple Queue, urutan tipe antrean adalah *upload/download*. Pada lab, tipe PCQ berbasis `dst-address` terpasang di sisi upload. Sebaiknya upload memakai `src-address` dan download memakai `dst-address`.
