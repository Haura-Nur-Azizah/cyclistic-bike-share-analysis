# cyclistic-bike-share-analysis
Studi kasus Google Data Analytics Capstone. Analisis 5,5 juta data perjalanan sepeda di Chicago (tahun 2021) memakai MySQL dan Tableau Public.
![Dashboard](images/Dashboard.png)

## Business Task
Cyclistic, perusahaan bike-share di Chicago, ingin mengubah pengguna casual menjadi annual member karena annual member lebih menguntungkan bagi perusahaan. Pertanyaan bisnis yang saya jawab adalah: “Bagaimana annual member dan pengguna casual memakai sepeda Cyclistic secara berbeda?” Untuk menjawabnya, saya menganalisis pola penggunaan berdasarkan jam, hari, dan musim, serta durasi perjalanan dan lokasi awal, agar diketahui kapan dan di mana pengguna casual paling aktif. Analisis ini diminta oleh Lily Moreno, Director of Marketing Cyclistic. Hasilnya akan dipakai tim marketing untuk merancang strategi, dan rekomendasinya akan dipresentasikan kepada tim eksekutif Cyclistic untuk disetujui.

## Sumber Data
1. Data Perjalanan Divvy 2021, 12 file csv bulanan Januari 2021 sampai Desember 2021 dengan total 5.595.063 baris.
2. Kolom utama: `ride_id`, `rideable_type`, `started_at`, `ended_at`, `start_station_name`, `start_station_id`, `end_station_name`, `end_station_id`, `start_lat`, `start_lng`, `end_lat`, `end_lng`, `member_casual`.
3. Data Perjalanan Divvy merupakan data publik yang tidak memuat data pribadi.
4. Data Perjalanan publik Divvy (Chicago) periode Januari sampai Desember 2021, diunduh dari [divvy-tripdata](https://divvy-tripdata.s3.amazonaws.com/index.html). Data tersedia berdasarkan Divvy Data License Agreement. Dataset ini dipakai dalam studi kasus Cyclistic di Google Data Analytics Certificate.

## Proses Pembersihan Data
Semua langkah tersedia di sql/cyclistic_latihan.sql. Data mentah tidak diubah, pembersihan dilakukan di tabel salinan ride_trip_clean.
| Proses | Temuan | Keputusan |
|---|---|---|
|jajaj|hhahahaaaaaaaaa|ahahah|
