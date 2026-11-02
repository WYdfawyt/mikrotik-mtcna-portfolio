# Day 2 - Hardening Management Access, Bridge, Dua Router, dan Bandwidth Management

> Platform: MikroTik hAP ax lite (dua router, R1 dan R2), RouterOS v7, WinBox · Training MTCNA, 20 Okt 2026

## 1. Tujuan

Mengamankan akses manajemen router, menggabungkan port LAN dengan bridge, membangun jaringan dua router dengan routing statis, lalu membatasi bandwidth per segmen dan per pengguna dengan Simple Queue dan PCQ.

## 2. Topologi dan alamat

Soal lab dari instruktur: dua router dihubungkan ether1 ke ether1, masing-masing punya LAN dan DHCP server sendiri.

```
Laptop A -- [R1: ether2/3 = br-lan] -- ether1 ===== ether1 -- [R2] -- ether4 -- Laptop C
              192.168.88.1/24       10.10.10.1/30   10.10.10.2/30          192.168.222.1/24
            [R1: ether4 192.168.111.1/24] -- Laptop B (LAN-B)
```

| Router | Interface | Alamat | Keterangan |
|--------|-----------|--------|------------|
| R1 | ether1 | 10.10.10.1/30 | Link ke R2 |
| R1 | br-lan (ether2, ether3) | 192.168.88.1/24 | LAN-A, DHCP server dhcp1 |
| R1 | ether4 | 192.168.111.1/24 | LAN-B, DHCP server dhcp2 |
| R1 | wifi1 | DHCP client | Uplink internet |
| R2 | ether1 | 10.10.10.2/30 | Link ke R1 |
| R2 | ether4 | 192.168.222.1/24 | LAN-C |

## 3. Langkah pengerjaan

1. Review layanan IP (`IP > Services`), nonaktifkan yang tidak dipakai, ganti port SSH, WinBox, dan WWW
2. Batasi WinBox hanya dari segmen admin (field *Available From*)
3. Review user dan group manajemen
4. Pelajari DHCP lease, jadikan lease static, DHCP client, dan tabel ARP
5. Buat bridge `br-lan`, masukkan ether2 dan ether3, pindahkan DHCP server ke bridge
6. Konfigurasi dua router sesuai soal: IP di ether1 dan ether4, DHCP server baru di ether4
7. Tambah routing statis R1 ke LAN-C (192.168.222.0/24) lewat 10.10.10.2
8. Bandwidth management: Simple Queue 10 Mbps untuk LAN-B, PCQ 2 Mbps per pengguna, dan limit VIP 20 Mbps

## 4. Konfigurasi

```
# Hardening akses manajemen
/ip service set ftp disabled=yes
/ip service set telnet disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set ssh port=51122
/ip service set winbox port=51928
/ip service set www port=51180
/ip service set winbox address=192.168.88.0/24

# Bridge dan DHCP
/interface bridge add name=br-lan
/interface bridge port add bridge=br-lan interface=ether2
/interface bridge port add bridge=br-lan interface=ether3
/ip address add address=192.168.88.1/24 interface=br-lan
/ip dhcp-server add name=dhcp1 interface=br-lan address-pool=dhcp_pool0
/ip dhcp-server add name=dhcp2 interface=ether4 address-pool=dhcp_pool1

# Link dan routing antar router (R1)
/ip address add address=10.10.10.1/30 interface=ether1
/ip address add address=192.168.111.1/24 interface=ether4
/ip route add dst-address=192.168.222.0/24 gateway=10.10.10.2

# Bandwidth management
/queue type add name=PCQ-DOWNLOAD-2M kind=pcq pcq-classifier=dst-address pcq-rate=2M
/queue type add name=PCQ-UPLOAD-2M kind=pcq pcq-classifier=src-address pcq-rate=2M
/queue simple add name=LIMIT-LAN-LT-1 target=192.168.111.0/24 max-limit=10M/10M
/queue simple add name=LIMIT-VIP-LT-1 target=192.168.111.253/32 max-limit=20M/20M
```

## 5. Penjelasan

| Konfigurasi | Fungsi |
|-------------|--------|
| Ganti port SSH, WinBox, WWW | Mengurangi pemindaian dan percobaan login otomatis pada port default |
| `Available From` pada service | Hanya IP atau segmen tertentu yang boleh mengakses layanan tersebut |
| Bridge `br-lan` | Beberapa port fisik menjadi satu segmen Layer 2 dengan satu IP gateway |
| Link /30 antar router | Subnet terkecil untuk dua host (hemat alamat, praktik umum link point-to-point) |
| Static route | Memberi tahu R1 bahwa LAN-C berada di belakang 10.10.10.2 |
| Simple Queue `max-limit` | Batas total bandwidth untuk target (segmen atau satu IP) |
| PCQ | Membagi bandwidth merata per pengguna (`pcq-rate`), berdasarkan src-address untuk upload dan dst-address untuk download |

## 6. Verifikasi

**Hardening akses manajemen**

[![IP > Services bawaan: port 22, 23, 21, 8291, 80 aktif](images/day2/01-ip-service-default.jpeg)](images/day2/01-ip-service-default.jpeg)

*IP > Services bawaan: port 22, 23, 21, 8291, 80 aktif*

[![Layanan yang tidak dipakai dinonaktifkan](images/day2/02-ip-service-nonaktif.jpeg)](images/day2/02-ip-service-nonaktif.jpeg)

*Layanan yang tidak dipakai dinonaktifkan*

[![Port baru: SSH 51122, WinBox 51928, WWW 51180](images/day2/03-ip-service-port-baru.jpeg)](images/day2/03-ip-service-port-baru.jpeg)

*Port baru: SSH 51122, WinBox 51928, WWW 51180*

[![WinBox dibatasi dari 192.168.88.0/24 (Available From)](images/day2/04-winbox-available-from.jpeg)](images/day2/04-winbox-available-from.jpeg)

*WinBox dibatasi dari 192.168.88.0/24 (Available From)*

[![Review user admin dan group full](images/day2/05-user-admin.jpeg)](images/day2/05-user-admin.jpeg)

*Review user admin dan group full*


**DHCP, ARP, dan bridge**

[![Tabel DHCP lease](images/day2/06-dhcp-leases.jpeg)](images/day2/06-dhcp-leases.jpeg)

*Tabel DHCP lease*

[![Lease dijadikan static (Make Static)](images/day2/07-make-static-lease.jpeg)](images/day2/07-make-static-lease.jpeg)

*Lease dijadikan static (Make Static)*

[![DHCP client wifi1 berstatus bound](images/day2/08-dhcp-client-wifi1.jpeg)](images/day2/08-dhcp-client-wifi1.jpeg)

*DHCP client wifi1 berstatus bound*

[![Tabel ARP di laptop (`arp -a`), gateway 192.168.88.1 dinamis](images/day2/09-arp-laptop.jpeg)](images/day2/09-arp-laptop.jpeg)

*Tabel ARP di laptop (`arp -a`), gateway 192.168.88.1 dinamis*

[![Membuat bridge br-lan](images/day2/10-bridge-br-lan.jpeg)](images/day2/10-bridge-br-lan.jpeg)

*Membuat bridge br-lan*

[![Port bridge: ether2 dan ether3](images/day2/11-bridge-ports.jpeg)](images/day2/11-bridge-ports.jpeg)

*Port bridge: ether2 dan ether3*

[![DHCP server dhcp1 berjalan pada br-lan](images/day2/12-dhcp-server-br-lan.jpeg)](images/day2/12-dhcp-server-br-lan.jpeg)

*DHCP server dhcp1 berjalan pada br-lan*


**Dua router, DHCP baru, dan routing statis**

[![Soal lab dari instruktur (foto layar presentasi)](images/day2/13-soal-topologi-r1-r2.jpeg)](images/day2/13-soal-topologi-r1-r2.jpeg)

*Soal lab dari instruktur (foto layar presentasi)*

[![Alamat R1: 10.10.10.1/30 (ether1), 192.168.88.1/24 (br-lan), 192.168.111.1/24 (ether4), wifi1 dari DHCP](images/day2/14-alamat-ip-r1.jpeg)](images/day2/14-alamat-ip-r1.jpeg)

*Alamat R1: 10.10.10.1/30 (ether1), 192.168.88.1/24 (br-lan), 192.168.111.1/24 (ether4), wifi1 dari DHCP*

[![Dua DHCP server: dhcp1 (br-lan) dan dhcp2 (ether4)](images/day2/15-dhcp-server-dhcp1-dhcp2.jpeg)](images/day2/15-dhcp-server-dhcp1-dhcp2.jpeg)

*Dua DHCP server: dhcp1 (br-lan) dan dhcp2 (ether4)*

[![Laptop di LAN-B mendapat 192.168.111.254, gateway 192.168.111.1](images/day2/16-ipconfig-laptop-lan-b.jpeg)](images/day2/16-ipconfig-laptop-lan-b.jpeg)

*Laptop di LAN-B mendapat 192.168.111.254, gateway 192.168.111.1*

[![Static route 192.168.222.0/24 via 10.10.10.2](images/day2/17-static-route-ke-r2.jpeg)](images/day2/17-static-route-ke-r2.jpeg)

*Static route 192.168.222.0/24 via 10.10.10.2*


**Bandwidth management**

[![Simple Queue baru](images/day2/18-simple-queue-baru.jpeg)](images/day2/18-simple-queue-baru.jpeg)

*Simple Queue baru*

[![LIMIT-LAN-LT-1: target 192.168.111.0/24, max limit 10M/10M](images/day2/19-simple-queue-limit-10m.jpeg)](images/day2/19-simple-queue-limit-10m.jpeg)

*LIMIT-LAN-LT-1: target 192.168.111.0/24, max limit 10M/10M*

[![Queue type PCQ dengan rate 2M](images/day2/20-pcq-type-2m.jpeg)](images/day2/20-pcq-type-2m.jpeg)

*Queue type PCQ dengan rate 2M*

[![Daftar queue type: PCQ-DOWNLOAD-2M dan PCQ-UPLOAD-2M](images/day2/21-queue-types.jpeg)](images/day2/21-queue-types.jpeg)

*Daftar queue type: PCQ-DOWNLOAD-2M dan PCQ-UPLOAD-2M*

[![Tab Advanced: queue type PCQ dipasang pada simple queue](images/day2/22-simple-queue-queue-type.jpeg)](images/day2/22-simple-queue-queue-type.jpeg)

*Tab Advanced: queue type PCQ dipasang pada simple queue*

[![Simple queue: limit segmen 10M dan limit VIP 20M](images/day2/23-simple-queue-list.jpeg)](images/day2/23-simple-queue-list.jpeg)

*Simple queue: limit segmen 10M dan limit VIP 20M*

[![Hasil speedtest uji pembatasan bandwidth (1)](images/day2/24-speedtest-hasil-1.jpeg)](images/day2/24-speedtest-hasil-1.jpeg)

*Hasil speedtest uji pembatasan bandwidth (1)*

[![Hasil speedtest uji pembatasan bandwidth (2)](images/day2/25-speedtest-hasil-2.jpeg)](images/day2/25-speedtest-hasil-2.jpeg)

*Hasil speedtest uji pembatasan bandwidth (2)*


## 7. Troubleshooting yang perlu dicek

| Gejala | Penyebab umum | Pengecekan |
|--------|---------------|------------|
| Tidak bisa login WinBox setelah ganti port | Port di kolom connect belum diganti | Sambung ke `IP:51928` |
| Laptop LAN-B tidak mendapat IP | DHCP server dhcp2 belum aktif atau pool kosong | `/ip dhcp-server print`, `/ip pool print` |
| Ping R1 ke LAN-C gagal | Static route salah atau R2 belum punya IP di ether4 | `/ip route print`, `/ip address print` di R2 |
| Bandwidth tidak terbatas | Target queue tidak cocok dengan IP klien, atau urutan queue | `/queue simple print stats` |

## 8. Yang dipelajari

- Layanan manajemen default adalah permukaan serangan pertama yang harus dirapikan di router baru
- Link point-to-point cukup /30, dan routing statis perlu dibuat di kedua arah atau lewat default route
- PCQ membagi bandwidth merata, sedangkan `max-limit` pada simple queue menentukan batas totalnya
