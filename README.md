# cyclistic-bike-share-analysis
Studi kasus Google Data Analytics Capstone. Analisis 5,5 juta data perjalanan sepeda di Chicago (tahun 2021) memakai MySQL dan Tableau Public.
![Dashboard](images/Dashboard.png)

## Business Task
Cyclistic, perusahaan bike-share di Chicago, ingin mengubah ride casual menjadi annual member karena annual member lebih menguntungkan bagi perusahaan. Pertanyaan bisnis yang saya jawab adalah: “Bagaimana annual member dan ride casual memakai sepeda Cyclistic secara berbeda?” Untuk menjawabnya, saya menganalisis pola penggunaan berdasarkan jam, hari, dan musim, serta durasi perjalanan dan lokasi awal, agar diketahui kapan dan di mana ride casual paling aktif. Analisis ini diminta oleh Lily Moreno, Director of Marketing Cyclistic. Hasilnya akan dipakai tim marketing untuk merancang strategi, dan rekomendasinya akan dipresentasikan kepada tim eksekutif Cyclistic untuk disetujui.

## Sumber Data
1. Data Perjalanan Divvy 2021, 12 file csv bulanan Januari 2021 sampai Desember 2021 dengan total 5.595.063 baris.
2. Kolom utama: `ride_id`, `rideable_type`, `started_at`, `ended_at`, `start_station_name`, `start_station_id`, `end_station_name`, `end_station_id`, `start_lat`, `start_lng`, `end_lat`, `end_lng`, `member_casual`.
3. Data Perjalanan Divvy merupakan data publik yang tidak memuat data pribadi.
4. Data Perjalanan publik Divvy (Chicago) periode Januari sampai Desember 2021, diunduh dari [divvy-tripdata](https://divvy-tripdata.s3.amazonaws.com/index.html). Data tersedia berdasarkan Divvy Data License Agreement. Dataset ini dipakai dalam studi kasus Cyclistic di Google Data Analytics Certificate.

## Proses Pembersihan Data
Semua langkah tersedia di sql/cyclistic_latihan.sql. Data mentah tidak diubah, pembersihan dilakukan di tabel salinan ride_trip_clean.
| Langkah | Temuan | Keputusan |
|---|---|---|
|Durasi negatif `ended_at < started_at`|147|Dihapus karena tidak akan memengaruhi hasil|
|Ride kurang dari 1 menit|85.086|Dihapus, dianggap salah ketik|
|Ride lebih dari 24 jam|1.315|Dihapus, kemungkinan sepeda tidak dikembalikan|
|Cek apakah ride kurang dari 1 menit berat sebelah|Dari ride kurang dari 1 menit yang dibuang, 60% member. Di seluruh data, member 54,8%|Selisih kecil, jadi pembuangan tidak membuat perbandingan member vs casual menjadi miring|
|Cek duplikat|0|Tidak ada tindakan|
|Nama stasiun awal kosong|670.450 baris|Semuanya sepeda elektrik yang bisa diparkir di mana saja, jadi memang tidak punya stasiun|Tidak dibuang karena datanya tetap valid. Baris ini hanya dikeluarkan saat analisis stasiun|
|Karakter tersembunyi `\r` di `member_casual`|Seluruh Baris, terbawa dari format file CSV|Dibuat kolom baru `member_type` yang sudah bersih, kolom asli tidak diubah|
|Label `docked bike` dan `classic bike`|Merujuk pada hasil yang sama yaitu `classic bike`|`docked bike` digabung menjadi `classic bike`|

Hasil: 5.595.063 baris menjadi 5.508.515 baris sekitar 1,5% dibuang.
Kolom tambahan: ride_length, day_of_week, month, start_hour.

## Temuan Utama
**1. Member punya lebih banyak ride, casual berkendara lebih lama.**
Member: 3.014.936 ride (54,7%), rata-rata durasi 13,4 menit. Casual: 2.493.579 ride (45,3%), rata-rata durasi 28,0 menit.

**2. Casual lebih ramai di akhir pekan, sedangkan ride member ramai di hari kerja**
Hari Sabtu sebanyak 550.170 dan hari Minggu sebanyak 474.218 merupakan hari tersibuk  casual, sedangkan hari tersibuk bagi ride member adalah hari Rabu yaitu sebanyak 469.601.

**3. Member menunjukkan pola commuter**
Di hari kerja, ride member punya dua puncak jam 7-8 pagi dan jam 17 yaitu sebanyak 257.874 ride. Pola ini hilang di akhir pekan, saat ride casual lebih banyak dari ride member sepanjang siang sampai malam.

**4. Aktivitas casual sangat dipengaruhi musim**
Jumlah ride casual naik tajam dari 9.945 di bulan Februari menjadi 435.746 di bulan Juli, dan melampaui member selama Juni sampai Agustus. Saat musim dingin, member lebih stabil: pada Januari ada 77.573 ride member dibanding 17.829 ride casual. Pola ini mungkin berkaitan dengan cuaca hangat dan musim liburan, tetapi data tidak mencatat alasan perjalanan.

**5. Casual terkonsentrasi di lokasi wisata dan rekreasi**
Stasiun awal teratas ride casual: Streeter Dr & Grand Ave (65.522), Millennium Park (33.152), Michigan Ave & Oak St (29.423), Shedd Aquarium (22.940), Theater on the Lake (21.085)

**6. Tipe sepeda bukan pembeda utama**
Kedua kelompok lebih banyak memakai sepeda classic dengan persentase sekitar 65% ride member dan 63% ride casual.

## Rekomendasi
Melihat dari pola yang terlihat, berikut merupakan rekomendasi saya atas pertanyaan bisnis yang diajukan;
1. Berikan promo membership pada akhir pekan serta bulan puncak yaitu pada musim panas bulan Juli ride casual menggunakan sepeda. Jalankan kampanye promo membership saat menjelang akhir pekan dan musim panas saat ride casual banyak mengendarai sepeda.
2. Tonjolkan penghematan biaya saat ride panjang. Melihat dari rata-rata, ride casual lebih lama mengendarai sepeda jika dibandingkan dengan ride member, tonjolkan paket yang menekankan biaya per ride lebih murah dibanding bayar per perjalanan agar ride casual tertarik dengan membership.
3. Pasang penawaran membership di titik yang ramai dipakai casual. Dengan begitu, ride casual akan jauh lebih mudah melihat tawarannya.

## Keterbatasan
1. Data hanya meliputi satu tahun yaitu tahun 2021, pola musim belum tentu sama di tahun lain.
2. Sekitar 12% ride tidak punya nama stasiun yang di mana semuanya adalah sepeda elektrik, sehingga analisis stasiun kurang mewakili pengguna sepeda elektrik.
3. Tidak ada ID pengguna, sehingga tidak bisa melacak satu casual rider yang berulang kali membeli pass.
4. Data tidak memuat tujuan perjalanan.

## Alat yang Dipakai
MySQL Workbench (pembersihan dan analisis), Tableau Public (dashboard), GitHub (dokumentasi).
