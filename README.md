# Jarkom-Modul-2-2026-K-34

# Member
--- 

| NO  |             Nama              |    NRP     |
| :-: | :---------------------------: | :--------: |
|  1  | Muhammad Syadzili Abdul Muhyi | 5027251030 |
|  2  | Bambang Nasarillah Kurniawan  | 5027251110 |

# Laporan
---
##### 1. Sebagai pusat kesadaran The Mesh, rootkit harus merentangkan koneksinya ke lima gerbang utama (Switch). Tetapkan alamat IP dan default gateway untuk seluruh Entitas, mulai dari para operator [...]

![Asset Image 0001](Asset/image_0001%201.png)

Disini kami membuat topologi jaringan sesuai dengan yang diminta oleh soal, yaitu dengan menggunakan beberapa konfigurasi berikut:

- **NAT** : digunakan sebagai gateway untuk mendapatkan akses internet dan memberikan koneksi jaringan eksternal.
- **Router Eru** : digunakan sebagai router utama yang menghubungkan jaringan NAT dengan seluruh jaringan internal.
- **Switch 1** : digunakan sebagai penghubung antara Router Eru dengan jaringan **Prab, Tedd, dan jaringan bawah**.
- **Switch 2** : digunakan sebagai penghubung antara jaringan **Prab/Tedd** dengan **Obladi, Oblada, dan Desmond**.
- **Switch 3** : digunakan sebagai penghubung antara Router Eru dengan jaringan **Penny, Molly, dan Epsilon**.
- **Switch 4** : digunakan sebagai penghubung antara Router Eru dengan **Abbey**.
- **Switch 5** : digunakan sebagai penghubung antara Router Eru dengan **Penny dan Molly**.
- **Switch 6** : digunakan sebagai penghubung antara Router Eru dengan **Alpha, Beta, dan Gamma**.
- **Alpha, Beta, Gamma** : merupakan client pada jaringan bagian atas dengan alamat jaringan **192.228.20.x**.
- **Delta, Epsilon** : merupakan client pada jaringan sebelah kanan dengan alamat jaringan **192.228.30.x**.
- **Abbey** : merupakan client pada jaringan **192.228.40.x**.
- **Penny, Molly** : merupakan client pada jaringan **192.228.50.x**.
- **Prab, Tedd** : merupakan server pada jaringan **192.228.10.x**.
- **Obladi, Oblada, Desmond** : merupakan client/server pada jaringan **192.228.10.x** bagian bawah.

##### 2. Meskipun The Mesh beroperasi dalam bayang-bayang, Rootkit menyadari bahwa Entitas di dalamnya masih membutuhkan asupan paket dari dunia luar. Buka jalur menuju NAT dengan memastikan antarmuka[...]

Di sini kita membuat script yang bernama `power.sh` yang dimana dia digunakan untuk mengonfigurasi node Rootkit sebagai router utama, mulai dari mengatur IP pada interface eth1–eth5, mengaktifka[...]

Mari kita cek menggunakan client alpha ngeping ke google dan ke host beta dengan ip seperti dibawah
![Pasted Image](Asset/Pasted%20image%2020261001213902.png)


##### 3. Jaringan rahasia tidak akan berfungsi tanpa sinkronisasi antar divisi. Pastikan seluruh Entitas dapat saling terhubung dan berkomunikasi lintas jalur (routing internal via rootkit berfung[...]

Jadi kita terlebih dahulu melakukan pengecekan apakah ada name server default yang dimiliki client cara untuk mengeceknya adalah dengan command
```
cat /etc/resolv.conf
```
Jika tidak ada maka kita memasukkan dengan command line seperti ini 
```
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
tapi dalam kasus kita yang dimana ketika node mati maka hilang jadi kita akan menaruhnya di configuration seperti contoh pada client abe ini![Image Date](Asset/2026-10-01_21-42.png)

![Asset Image 0002](Asset/image_0002.png)

#####  4. Penjaga Direktori mulai menuliskan hukum The Mesh. Pada node prab, bangun zona xxxx.com sebagai authoritative dengan SOA yang menunjuk ke prab.xxxx.com, serta tambahkan catatan NS untuk [...]

mengarah ke gerbang aplikasi dinamis (penny). Aktifkan fitur notify dan allow-transfer ke tedd, lalu set forwarders ke 192.168.122.1. Di node tedd, tarik zona xxxx.com dari master dan pastikan ser[...]
Berdasarkan konfigurasi yang telah dibuat (master.sh) pada node prab, DNS Master untuk zona K34.com telah dikonfigurasi menggunakan BIND9. Konfigurasi tersebut menetapkan prab sebagai authoritativ[...]

![Asset Image 0003](Asset/image_0003%203.png)

Setelah DNS Master pada prab berhasil dikonfigurasi, tahap selanjutnya adalah mengatur tedd sebagai DNS Slave untuk zona K34.com. Konfigurasi ini bertujuan agar tedd dapat mengambil dan menyimpan [...]
.
![Asset Image 0004](Asset/image_0004.png)

Pengujian host name:
![Asset Image 0005](Asset/image_0005.png)

Uji dari client ke server:
![Asset Image 0008](Asset/image_0008.png)

Client berhasil melakukan DNS query menggunakan dig K34.com tanpa menentukan IP DNS server secara langsung. Query diteruskan kepada DNS resolver yang terdaftar pada konfigurasi resolver client, ya[...]

Pengetesan jika prab mati maka tedd bakal menjadi DNS cadangan
![Asset Image 0007](Asset/image_0007.png)


##### 5. Entitas tanpa identitas adalah anomali," pesan Rootkit. Namai semua Entitas (hostname) sesuai glosarium: rootkit, alpha, beta, gamma, delta, epsilon, prab, tedd, abbey, penny, obladi, des[...]

Kita melakukan config di configuration clien terlebih dahulu 
![Asset Image 0009](Asset/image_0009.png)
![Asset Image 0010](Asset/image_0010.png)

Konfigurasi DNS pada node prab kemudian diperbarui dengan menambahkan A record untuk setiap Entitas sesuai dengan hostname dan alamat IP masing-masing. Selain itu, serial pada SOA dinaikkan untuk [...]
![Asset Image 0012](Asset/image_0012%201.png)
![Asset Image 0013](Asset/image_0013.png)![Asset Image 0011](Asset/image_0011.png)

##### 6.Pastikan zone transfer berjalan, pastikan tedd telah menerima salinan zona terbaru dari prab. Nilai serial SOA di keduanya harus sama karena keduanya tidak bisa dipisahkan dan saling melen[...]

untuk memastikannya, kita akan mengecek node tedd untuk membuktikan "apakah benar kalau tedd sudah menerima salinan zona terbaru dari prab?"
```
ls -l /var/cache/bind/ 
```
![Asset Image 0014](Asset/image_0014.png)
disini terbukti bahwa tedd telah menerima file K34.com

Kesamaan output pada kedua node ini, khususnya pada nilai serial number yang menunjukkan angka 1, itu bukti bahwa proses zone transfer berhasil.

![Asset Image 0015](Asset/image_0015%201.png)![Asset Image 0016](Asset/image_0016.png)

##### 7. abbey dan penny sebagai gerbang utama, obladi dan desmond sebagai web statis, oblada dan molly sebagai web dinamis. Tambahkan pada zona xxxx.com A record untuk vault.xxxx.com (IP obladi [...]
* www.xxxx.com → penny.xxxx.com
* static.xxxx.com → abbey.xxxx.com
Verifikasi dari dua klien berbeda bahwa seluruh hostname tersebut ter-resolve ke tujuan yang benar dan konsisten.

disini kami membuat script setup7.sh yang berarti setup untuk no 7
script ini berfungsi untuk menambahkan A record secara otomatis ke dalam file konfigurasi zona DNS (K34.com). Penambahan ini bertujuan untuk memetakan domain vault ke IP server statis (obladi dan[...]

![Asset Image 0017](Asset/image_0017.png)![Asset Image 0018](Asset/image_0018.png)

Setelah script dieksekusi dan layanan DNS di-restart, kami melakukan verifikasi pengujian DNS dari sisi klien. Berdasarkan screenshotan di atas yang dilakukan pada klien alpha dan beta, dapat dip[...]

1. Pemanggilan vault.K34.com dan core.K34.com berhasil memunculkan dua alamat IP secara bersamaan, membuktikan bahwa satu hostname berhasil mengenali dua server berbeda.
2. Pemanggilan [www.K34.com](https://www.K34.com) dan static.K34.com berhasil memberikan respons pengalihan (alias) ke hostname yang tepat beserta resolusi IP-nya.

```
IP_OBLADI="192.228.10.6"
IP_DESMOND="192.228.10.7"
IP_OBLADA="192.228.10.5"
IP_MOLLY="192.228.10.4"

# Pastikan path ini sesuai dengan lokasi file zone K34.com milikmu
FILE_ZONE="/etc/bind/K34.com" 

cat <<EOF >> $FILE_ZONE

; [Konfigurasi Soal Nomor 7]
vault   IN  A       $IP_OBLADI
vault   IN  A       $IP_DESMOND
core    IN  A       $IP_OBLADA
core    IN  A       $IP_MOLLY
www     IN  CNAME   penny
static  IN  CNAME   abbey
EOF

echo "Penambahan record selesai!"

```

##### 8. Di prab (ns1) deklarasikan reverse zone untuk segmen jaringan  tempat abbey, penny, area vault, dan area core berada. Di tedd (ns2) tarik reverse zone tersebut sebagai slave, isi PTR unt[...]

di sini kita bikin kebalikan dari DNS biasanya. Kalau sebelumnya kita cari IP pakai nama domain, sekarang kita dites buat bikin Reverse DNS jadi kita cari tahu nama hostname cukup dari alamat IPn[...]

![Asset Image 0019](Asset/image_0019.png)![Asset Image 0020](Asset/image_0020.png)

Kayak yang keliatan di SS terminal alpha sama beta di atas, pas kita coba tes pakai perintah host ke masing-masing IP (kayak 192.228.40.2 atau 192.228.10.6), hasilnya langsung keluar dengan mulus[...]

##### 9.Jalankan layanan web statis pada hostname di node area vault (menggunakan apache). Buka folder direktori /arsip/ dan aktifkan fitur autoindex (directory listing) pada konfigurasi Apache s[...]

kita diminta buat nge-deploy layanan web statis pakai Apache di node area vault (yang di-handle sama si obladi dan desmond). Gak cuma sekadar nyalain web server, kita juga harus bikin direktori k[...]

akses pengujiannya wajib pakai hostname (vault.K34.com), bukan pakai alamat IP 
![Asset Image 0021](Asset/image_0021.png)
Dengan aktifnya modul autoindex (Options Indexes) pada konfigurasi virtual host/direktori Apache, klien dalam jaringan (alpha) dapat langsung menelusuri, melihat daftar file (directory listing), [...]


##### 10. Jalankan layanan web dinamis (PHP-FPM) pada hostname di node core (menggunakan nginx). Buat sebuah aplikasi sederhana yang memuat halaman beranda dan halaman profil. Terapkan aturan rew[...]

Kami menggunakan script otomatis setup10_nginx_core.sh untuk menginstal layanan, memastikan socket PHP berjalan, dan membuat dua halaman PHP sederhana (index.php dan profil.php).

ini kita cek dulu isi dari html di server, terdapat 2 file yaitu profil.php dan index.php, selanjutnya baru kita test apakah nginxnya bekerja dengan cara nge curl webnya

![Asset Image 0023](Asset/image_0023.png)![Asset Image 0024](Asset/image_0024.png)

Dari hasil tes pakai klien alpha, konfigurasinya sudah running dengan banar. Waktu kita test akses http://core.K34.com/, halaman berandanya langsung muncul. Terus, pas kita coba buka http://core.[...]

##### 11. Konfigurasikan Penny (menggunakan Apache) sebagai reverse proxy yang mengarah ke semua node di area vault (Obladi & Desmond). Sementara itu, konfigurasikan Abbey (menggunakan Nginx) seb[...]

Konfigurasi dilakukan menggunakan script Power[namaclient].sh pada masing-masing gateway. Script Penny berisi instalasi dan konfigurasi Apache sebagai reverse proxy menuju Obladi dan Desmond, sed[...]

Sebelum pengujian distribusi trafik, dilakukan verifikasi pada Penny (Apache) dan Abbey/Epsilon (Nginx) untuk memastikan konfigurasi telah valid dan kedua reverse proxy berjalan dengan baik.

**Penny**
![Asset Image 0022](Asset/image_0022%201.png)

**Abbey**
![Asset Image 0026](Asset/image_0026.png)

Penny
Setelah konfigurasi backend selesai dijalankan menggunakan script backupend.sh dari masing masing client, dilakukan pengujian koneksi dari Penny ke Obladi dan Desmond, kemudian pengujian melalui [...]
![Asset Image 0027](Asset/image_0027%201.png)
kemudian kita melakukan pada client dengan cmd 

```
for i in 1 2 3 4 5 6; do
    curl -s http://192.228.50.2
    echo
done

```

![Asset Image 0025](Asset/image_0025.png)

Abbey
Setelah konfigurasi Penny sebagai reverse proxy menggunakan Apache berhasil dilakukan, tahap berikutnya adalah mengonfigurasi Abbey menggunakan Nginx sebagai reverse proxy untuk area core. Konfig[...]
*untuk script bisa dicek di folder Script*

Abbey setelah menjalankan script![Asset Image 0028](Asset/image_0028.png)
Mengecekan di client menggunakan cmd program loop pada client delta
```
for i in 1 2 3 4 5 6; do
    curl -s http://192.228.40.2
    echo
done

```
![Asset Image 0029](Asset/image_0029%201.png)

##### 12. Terdapat ruang khusus di penny yang yang menyimpan dokumen rahasia sindikat, oleh karena itu terapkan perlindungan basic authentication untuk path /admin. Akses ke jalur tersebut harus [...]

| Username | Password                 |
| -------- | ------------------------ |
| prabs    | pakar_pinter_jadi_gob*** |
Pada tahap ini kita akan melakukan penerapan Basic Authentication pada path /admin di server Penny sebagai mekanisme perlindungan terhadap dokumen rahasia. Konfigurasi diterapkan agar akses menuj[...]

Setelah kita menjalankan script 12.sh yang sudah dibuat maka dapat dilihat kita berhasil melakukannya
![Asset Image 0030](Asset/image_0030%201.png)

##### 13. Setiap entitas dari luar harus memanggil gerbang dengan nama kanoniknya. Jika ada yang mencoba mengakses IP penny dan domain  penny.xxx.com, paksa sistem untuk melakukan redirect secara[...]

Pada tahap ini kita akan melakukan konfigurasi redirect pada Penny dan Abbey agar akses dari entitas luar menggunakan nama kanonik yang telah ditentukan. Penny dikonfigurasi untuk memberikan redi[...]

Sebelum melakukan pengujian, konfigurasi DNS untuk Penny dan Abbey telah dipastikan dapat mengenali domain masing-masing. Selanjutnya, diterapkan mekanisme redirect nama kanonik, yaitu Penny meng[...]

![Asset Image 0031](Asset/image_0031.png)
![Asset Image 0033](Asset/image_0033.png)

#####  14. Di dalam The Mesh, rekam jejak tidak boleh dipalsukan oleh sistem. Pastikan access log pada setiap server web di area vault maupun area core mencatat alamat IP asli milik client (pengu[...]

Obladi 
Jadi kalau ingin cek si IP listening maka kita jalanin di backup obdabila yang sudah kita set pada awal2 dengan command
```
tail -f /var/log/apache2/access.log
```
apache2/nginx tergantung si client make apa anjayyyy 
Kemudian kalau kita ingin mengecek sesuai dengan yang sudah disetup maka kita harus menambahkan variable atau command baru
```
curl -H "Host: www.K34.com" http://192.228.50.2/
```
![Asset Image 0034](Asset/image_0034%201.png)
Dia bisa masuk obladi terus karena si desmound belum kita jalankan sehingga dia masuk ke backup Obladi, sekarang kita masuk ke desmoubd

Desmond
Sekarang Desmound udah jalan, gaskan kita jalankan terlebih dahulu dengan command yang sama
![Asset Image 0032](Asset/image_0032.png)

##### 15. Rootkit menginstruksikan pembuatan jalur proxy khusus yang berdiri sendiri. Pada penny buat reverse proxy untuk path /eternal yang menyajikan directory /var/www/eternal, dan pastikan pa[...]

Pada tahap ini, kami mengonfigurasi dua jalur proxy khusus pada gateway. Pada Penny, dibuat path `/eternal` yang mengarah ke directory `/var/www/eternal` dengan dukungan rendering PHP, sedangkan [...]

**Penny**
Jadi langkah pertama adalah kita harus menjalankan script `setup_eternal.sh` dan  ` proxyconf.sh` kemudian ikuti step by step berikut

1.Buat folder eternal di penny
```
mkdir -p /var/www/eternal
```
2.Masukin confignya
```
cat > /var/www/eternal/index.php <<'EOF'
<?php
echo "<h1>Eternal PHP Server</h1>";
echo "<p>PHP berhasil di-render.</p>";
echo "<p>PHP Version: " . phpversion() . "</p>";
?>
EOF

```
3.Berikan akses 
```
chown -R www-data:www-data /var/www/eternal
chmod -R 755 /var/www/eternal

```
4.Lakukan pengecekan
```
ls -l /var/www/eternal/
```
Pastikan harus ada index.php
5.Aktifkan
```
a2enmod alias
a2enmod proxy
a2enmod proxy_fcgi

```
6.Lakukan configurasi
```
cat > /etc/apache2/sites-available/reverse-proxy.conf <<'EOF'
<VirtualHost *:80> 

    ProxyPreserveHost On

    # ==========================================
    # REDIRECT KANONIK PENNY
    # ==========================================

    RewriteEngine On

    RewriteCond %{HTTP_HOST} ^192\.228\.50\.2$ [OR]
    RewriteCond %{HTTP_HOST} ^penny\.K34\.com$ [NC]
    RewriteRule ^/$ http://www.K34.com/ [R=301,L]


    # ==========================================
    # BASIC AUTH /admin
    # ==========================================

    Alias /admin /var/www/admin

    <Directory /var/www/admin>
        AuthType Basic
        AuthName "Restricted Area"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    ProxyPass /admin !


    # ==========================================
    # ETERNAL - PHP
    # ==========================================

    ProxyPass /eternal !

    Alias /eternal /var/www/eternal

    <Directory /var/www/eternal>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
        DirectoryIndex index.php
    </Directory>

    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php8.4-fpm.sock|fcgi://localhost/"
    </FilesMatch>


    # ==========================================
    # REVERSE PROXY VAULT
    # ==========================================

    <Proxy "balancer://vault">
        BalancerMember http://192.228.10.6
        BalancerMember http://192.228.10.7
    </Proxy>

    ProxyPass        / balancer://vault/
    ProxyPassReverse / balancer://vault/


    # ==========================================
    # FORWARD CLIENT IDENTITY
    # ==========================================

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

</VirtualHost>
EOF

```

7.Nyalakan dan cek2 
```
apache2ctl -S
```
```
ls -l /etc/apache2/sites-enabled/
```
```
grep -n -A20 -B5 "ETERNAL" /etc/apache2/sites-enabled/reverse-proxy.conf
```
 8.Pastikan semua berjalan baik di penny dan di client dan di sini kita ngetesnya di alpha 

Untuk di penny
```
curl -i http://127.0.0.1/eternal/
```
Akhirnya kita ngetes di client
```
curl -i http://192.228.50.2/eternal/
```
![Asset Image 0035](Asset/image_0035.png)

**Abbey**

Di abbey kita ngebuat Orion dan awal2 kita ngejalanin script2 yang ada di Abbey, lalu ikutin step by step berikut

1.Buat folder untuk orion
```
mkdir -p /var/www/orion
```
2.Konfigurasi dengan index html
```
cat > /var/www/orion/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Orion</title>
</head>
<body>
    <h1>Orion Static Server</h1>
    <p>Orion berhasil diakses secara statis.</p>
</body>
</html>
EOF
```
3.Set hirarki
```
chown -R www-data:www-data /var/www/orion
chmod -R 755 /var/www/orion

```
4.Config sites-avaiable untuk orion
```
cat > /etc/nginx/sites-available/orion <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name 192.228.40.2 abbey.K34.com;

    location /orion/ {
        alias /var/www/orion/;
        index index.html;
    }
}
EOF

```
5.Jalankan dengan command ini
```
ln -sf /etc/nginx/sites-available/orion /etc/nginx/sites-enabled/orion
```
```
ls -l /etc/nginx/sites-enabled/
```


```
curl -i http://192.228.40.2/orion/
```
![Asset Image 0037](Asset/image_0037.png)

##### 16. Ketahanan gerbang The Mesh harus diuji untuk menghadapi bombardir permintaan. Salah satu Klien (misal: Alpha) bertugas melakukan stress test benchmark menggunakan ApacheBench. Lakukan 2[...]

Kita testnya di client ALPHA jalankan dulu scriptnya (stress.sh)
pengujian dilakukan untuk menguji ketahanan gerbang The Mesh terhadap bombardir permintaan menggunakan ApacheBench dari client Alpha. Pengujian dilakukan pada endpoint www.K34.com dan static.K34.[...]

![Asset Image 0038](Asset/image_0038.png)
![Asset Image 0039](Asset/image_0039%201.png)

##### 17. Tambahkan TXT record pada DNS untuk semua klien sayap kiri dan sayap kanan (Alpha, Beta, Gamma, Delta, Epsilon). Jika DNS di-query TXT terhadap nama domain mereka (contoh: alpha.xxxx.co[...]

buat script di prab karna node prab bertindak sebagai DNS Master yang memegang file konfigurasi zona utama untuk domain K34.com. Seluruh penambahan record DNS baru wajib dipusatkan di node ini ag[...]

```
echo "Test dari client:  dig -t txt \(hostname).ZONE +short"

```

Setelah script berhasil dieksekusi di node prab, kami melakukan verifikasi dari sisi klien (misalnya klien alpha) dengan script verify17.sh

![Asset Image 0040](Asset/image_0040.png)![Asset Image 0041](Asset/image_0041.png)

Berdasarkan hasil pengujian dari klien, query TXT ke alpha.K34.com hingga epsilon.K34.com berhasil mengembalikan teks berupa nama hostname masing-masing. Jawaban datang dari prab dengan flag aa ([...]

![Asset Image 0042](Asset/image_0042.png)

Untuk memastikan konfigurasi di sisi server berhasil, pada node prab dijalankan tiga pemeriksaan. Pertama, grep -n "TXT" /etc/bind/K34.com menunjukkan bahwa lima TXT record untuk alpha, beta, gam[...]

###### 18. Ubah A record DNS milik abbey.xxx.com ke alamat IP yang fiktif (ubah secara random namun pastikan format IP valid). Naikkan nilai serial SOA di prab dan pastikan tedd ikut tersinkron. [...]

kali ini kami diminta modifikasi pada record DNS untuk domain abbey.K34.com dengan mengarahkannya ke IP fiktif (10.99.99.99) dan secara spesifik menerapkan batas waktu cache atau Time To Live (TT[...]

1. Fase 1 (Sebelum Perubahan): Pada kondisi awal, klien mengenali domain dengan IP aslinya, yaitu 192.228.40.2.
2. Fase 2 (Masa Tahan Cache): Setelah IP diubah menjadi IP fiktif pada DNS Master (prab), hasil query klien selama 14 detik pertama masih mengembalikan IP lama (192.228.40.2). Hal ini membuktikan[...]
3. Fase 3 (TTL Kedaluwarsa): Memasuki detik ke-16 (setelah batas waktu TTL 15 detik terlewati), masa berlaku cache klien habis. Klien secara otomatis melakukan query ulang ke server otoritatif da[...]


![Asset Image 0043](Asset/image_0043.png)

Untuk memastikan bahwa batas waktu cache juga berhasil diterapkan, eksekusi perintah dig abbey.K34.com secara lengkap dilakukan. Pada bagian ANSWER SECTION, terlihat jelas bahwa rekam DNS untuk a[...]

![Asset Image 0044](Asset/image_0044.png)

##### 19. Last? But not least? Buat CNAME record yang melakukan binding dari domain internal outbound.xxx.com menuju domain eksternal http.badssl.com, Lakukan perintah curl ke http://outbound.xxx[...]

Di tahap ini, kita diminta untuk bikin shortcut (CNAME) dari domain internal kita (outbound.K34.com) supaya langsung nyambung ke website luar, yaitu http.badssl.com.

Caranya, kita nambahin satu baris konfigurasi di DNS Master (prab) dengan format outbound IN CNAME http.badssl.com.. Jangan lupa kasih tanda titik di paling belakang ya, biar server DNS tahu kala[...]

pertama kita running dulu setupnya, jika ada yang bermasalah di tedd, running script fixtedd19.sh buat ngefix dan lanjut verify

Pada tahap ini, kami mengonfigurasi CNAME record pada DNS Master (prab) untuk mengarahkan domain internal outbound.K34.com ke domain eksternal http.badssl.com. Jika terjadi kendala sinkronisasi d[...]


![Asset Image 0045](Asset/image_0045.png)

Dari hasil eksekusi script setup19.sh di DNS Master, terlihat bahwa konfigurasi CNAME berhasil ditambahkan, nomor Serial SOA otomatis naik (4 -> 5), dan proses zone transfer ke DNS Slave berjalan[...]
setelah berhasil setup kita lanjut nge verif, apalah beneran works atau engga

![Asset Image 0046](Asset/image_0046.png)

![Asset Image 0047](Asset/image_0047%202.png)

Kita mejalankan dengan sh maka akan muncul seperti ini

![Asset Image 0048](Asset/image_0048.png)

##### 20. Setelah semua penyelesaian selesai, pastikan semua service dan konfigurasi yang telah dikerjakan dari awal tetap berjalan normal dan berstatus autostart saat node di-restart (khusus unt[...]

kami membuat script `20.sh` terlebih dahulu dan menjalankannya

Penjelasan Script Server (20.sh di node prab):
* Menghapus dan Menimpa IP: Script menggunakan perintah sed untuk mencari dan menghapus baris konfigurasi IP fiktif, lalu menggunakan echo untuk menuliskan kembali IP normal abbey (192.228.40.2) [...]
* Update Serial SOA Otomatis: Perintah perl digunakan untuk mencari angka Serial SOA di dalam file zona dan menambahkannya dengan angka 1. Ini adalah syarat mutlak dalam DNS agar server cadangan [...]
* update-rc.d named defaults: Ini adalah perintah inti untuk menjawab soal "stabilitas layanan". Perintah ini mendaftarkan service BIND9 (yang bernama named) ke daftar program startup sistem oper[...]
* Validasi Akhir: Script melakukan restart service dan menjalankan dig lokal yang membuktikan bahwa IP sudah sukses kembali ke 192.228.40.2.

Penjelasan Script Klien (verify20.sh di node alpha), script ini bertugas membuktikan bahwa klien bisa menggunakan jaringan dengan lancar:
* dig outbound.K34.com: Memeriksa apakah klien bisa menanyakan rute domain eksternal ke server DNS. Hasilnya membuktikan outbound.K34.com sukses diterjemahkan (melalui record CNAME) menjadi http.[...]
* curl -I ...: Melakukan pengujian koneksi web (meminta HTTP Header) ke alamat tersebut. Munculnya balasan HTTP/1.1 200 OK membuktikan bahwa klien tidak hanya sukses menerjemahkan nama domain, te[...]

beberapa hal yang akan dilakukan pada no 20
1. ormalisasi Jaringan: Mengembalikan pengaturan IP abbey yang sempat diubah menjadi IP fiktif (pada tugas 18) kembali ke alamat IP aslinya agar seluruh rute jaringan normal kembali.
2. Stabilitas Layanan (Autostart): Memastikan aplikasi DNS server (BIND9) didaftarkan ke sistem operasi agar otomatis menyala (autostart) setiap kali mesin server menyala atau di-restart.
3. Verifikasi Akhir: Memastikan dari sisi klien bahwa terjemahan DNS untuk rute website luar (eksternal) dan koneksi jaringannya tetap berjalan sempurna setelah dikembalikan ke kondisi normal.
![Asset Image 0049](Asset/image_0049.png)![Asset Image 0050](Asset/image_0050.png)

Dari hasil eksekusi di atas, ini beberapa kesimpulan:
1. Pada node prab, konfigurasi IP abbey telah kembali normal menjadi 192.228.40.2 beserta pembaruan otomatis pada Serial SOA. Layanan DNS (BIND9) juga sukses didaftarkan ke autostart sistem agar [...]
2. Pengujian dari node alpha membuktikan resolusi CNAME eksternal untuk outbound.K34.com berjalan lancar. Konektivitas juga terbukti normal sepenuhnya dengan respons akses web HTTP/1.1 200 OK.
