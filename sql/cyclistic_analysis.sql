-- =====================================================================
-- PROJEK: Cyclistic Bike-Share (Google Data Analytics Capstone)
-- Database : cyclistic_db
-- Tabel    : ride_trip_raw (mentah), ride_trip_clean (bersih)
-- Pertanyaan bisnis: Bagaimana annual member dan casual rider
--                    memakai sepeda Cyclistic secara berbeda?
-- =====================================================================


-- =====================================================================
-- 1. EKSPLORASI & VERIFIKASI DATA MENTAH
-- =====================================================================

-- Total baris (hasil saya: 5.595.063)
SELECT COUNT(*) FROM cyclistic_db.ride_trip_raw;

-- Cek rentang koordinat (untuk menentukan tipe kolom DECIMAL)
SELECT MIN(start_lat), MAX(start_lat), MIN(start_lng), MAX(start_lng)
FROM cyclistic_db.ride_trip_raw;


-- =====================================================================
-- 2. CEK DATA TIDAK VALID 
-- =====================================================================

-- 2a. Durasi negatif: waktu selesai lebih awal dari waktu mulai (hasil: 147)
SELECT COUNT(*)
FROM cyclistic_db.ride_trip_raw
WHERE ended_at < started_at;

-- 2b. Ride kurang dari 1 menit (hasil: 85.233, sudah termasuk yang negatif)
SELECT COUNT(*)
FROM cyclistic_db.ride_trip_raw
WHERE TIMESTAMPDIFF(MINUTE, started_at, ended_at) < 1;

-- 2c. Ride lebih dari 24 jam (hasil: 1.315)
SELECT COUNT(*)
FROM cyclistic_db.ride_trip_raw
WHERE TIMESTAMPDIFF(HOUR, started_at, ended_at) > 24;

-- 2d. Cek bias penghapusan: ride < 1 menit per kelompok
-- (hasil: member 51.120 = sekitar 60%, casual 34.113 = sekitar 40%)
SELECT member_casual, COUNT(*) AS total
FROM cyclistic_db.ride_trip_raw
WHERE TIMESTAMPDIFF(MINUTE, started_at, ended_at) < 1
GROUP BY member_casual;

-- 2e. Pembanding: proporsi member vs casual seluruh data (hasil: member 54,8%)
-- Catatan: SUM(...) OVER () butuh MySQL 8.0 ke atas
SELECT member_casual,
       COUNT(*) AS total_ride,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS persen
FROM cyclistic_db.ride_trip_raw
GROUP BY member_casual;
-- Kesimpulan: selisih kecil (60% vs 54,8%), penghapusan tidak membiaskan hasil.


-- =====================================================================
-- 3. MEMBUAT TABEL BERSIH
-- Aturan: buang durasi < 1 menit dan > 24 jam (termasuk durasi negatif)
-- ride_length dalam MENIT; day_of_week: 1 = Minggu ... 7 = Sabtu
-- =====================================================================
CREATE TABLE cyclistic_db.ride_trip_clean AS
SELECT *,
       TIMESTAMPDIFF(MINUTE, started_at, ended_at) AS ride_length,
       DAYOFWEEK(started_at) AS day_of_week
FROM cyclistic_db.ride_trip_raw
WHERE TIMESTAMPDIFF(MINUTE, started_at, ended_at) >= 1
  AND TIMESTAMPDIFF(HOUR, started_at, ended_at) <= 24;

-- Verifikasi jumlah baris
-- Hasil: 5.508.515 (5.595.063 - 86.548 = 85.233 + 1.315 dibuang, sekitar 1,5%)
SELECT COUNT(*) FROM cyclistic_db.ride_trip_clean;


-- =====================================================================
-- 4. CEK KUALITAS TABEL BERSIH
-- =====================================================================

-- 4a. Duplikat ride_id (idealnya 0)
SELECT COUNT(*) - COUNT(DISTINCT ride_id) AS duplikat
FROM cyclistic_db.ride_trip_clean;

-- 4b. Data kosong (hasil: stasiun awal 670.450, stasiun akhir 714.735,
--     koordinat akhir 4.587). Tidak dihapus, hanya disaring saat analisis stasiun.
SELECT
  SUM(start_station_name IS NULL OR start_station_name = '') AS start_station_kosong,
  SUM(end_station_name   IS NULL OR end_station_name   = '') AS end_station_kosong,
  SUM(end_lat IS NULL)                                       AS end_koordinat_kosong
FROM cyclistic_db.ride_trip_clean;

-- 4c. Siapa yang tidak punya stasiun? (hasil: 100% electric_bike,
--     member 363.501 + casual 306.949 = 670.450)
SELECT rideable_type, member_casual, COUNT(*) AS total
FROM cyclistic_db.ride_trip_clean
WHERE start_station_name IS NULL OR start_station_name = ''
GROUP BY rideable_type, member_casual;

-- 4d. Cek panjang teks member_casual (hasil: 7 = ada karakter tersembunyi \r
--     dari format baris Windows di file CSV)
SELECT member_casual, LENGTH(member_casual) AS panjang, COUNT(*)
FROM cyclistic_db.ride_trip_clean
GROUP BY member_casual;


-- =====================================================================
-- 5. KOLOM TURUNAN (kolom otomatis, jauh lebih cepat daripada UPDATE)
-- Catatan: UPDATE ke 5,5 juta baris sempat timeout (Error 2013) dan
-- kena safe update mode (Error 1175), jadi dipakai generated column.
-- =====================================================================
ALTER TABLE cyclistic_db.ride_trip_clean
  ADD COLUMN month INT AS (MONTH(started_at)),
  ADD COLUMN start_hour INT AS (HOUR(started_at)),
  ADD COLUMN member_type VARCHAR(10) AS (TRIM(TRAILING '\r' FROM member_casual));

-- Verifikasi: bulan 1-12, jam 0-23
SELECT started_at, month, start_hour
FROM cyclistic_db.ride_trip_clean
LIMIT 5;

-- Verifikasi member_type (panjang harus 6)
SELECT member_type, LENGTH(member_type) AS panjang, COUNT(*)
FROM cyclistic_db.ride_trip_clean
GROUP BY member_type;


-- =====================================================================
-- 6. ANALISIS (member vs casual)
-- =====================================================================

-- 6a. Ringkasan: jumlah ride dan rata-rata durasi (menit)
-- Hasil: member 3.014.936 ride / 13,4 menit; casual 2.493.579 ride / 28,0 menit
SELECT member_type,
       COUNT(*) AS total_ride,
       ROUND(AVG(ride_length), 1) AS rata2_menit
FROM cyclistic_db.ride_trip_clean
GROUP BY member_type;

-- 6b. Per hari dalam seminggu (1 = Minggu ... 7 = Sabtu), format pivot
SELECT day_of_week,
       SUM(CASE WHEN member_type = 'member' THEN 1 ELSE 0 END) AS member,
       SUM(CASE WHEN member_type = 'casual' THEN 1 ELSE 0 END) AS casual
FROM cyclistic_db.ride_trip_clean
GROUP BY day_of_week
ORDER BY day_of_week;

-- 6c. Rata-rata durasi per hari
SELECT day_of_week, member_type,
       ROUND(AVG(ride_length), 1) AS rata2_menit
FROM cyclistic_db.ride_trip_clean
GROUP BY day_of_week, member_type
ORDER BY day_of_week, member_type;

-- 6d. Per jam mulai (0-23)
SELECT start_hour,
       SUM(CASE WHEN member_type = 'member' THEN 1 ELSE 0 END) AS member,
       SUM(CASE WHEN member_type = 'casual' THEN 1 ELSE 0 END) AS casual
FROM cyclistic_db.ride_trip_clean
GROUP BY start_hour
ORDER BY start_hour;

-- 6e. Per bulan (pola musim)
SELECT month,
       SUM(CASE WHEN member_type = 'member' THEN 1 ELSE 0 END) AS member,
       SUM(CASE WHEN member_type = 'casual' THEN 1 ELSE 0 END) AS casual
FROM cyclistic_db.ride_trip_clean
GROUP BY month
ORDER BY month;

-- 6f. Per tipe sepeda (docked_bike = classic_bike, label lama dan baru, digabung)
SELECT CASE WHEN rideable_type IN ('docked_bike', 'classic_bike') THEN 'classic_bike'
            ELSE rideable_type END AS tipe_sepeda,
       SUM(CASE WHEN member_type = 'member' THEN 1 ELSE 0 END) AS member,
       SUM(CASE WHEN member_type = 'casual' THEN 1 ELSE 0 END) AS casual
FROM cyclistic_db.ride_trip_clean
GROUP BY tipe_sepeda
ORDER BY tipe_sepeda;

-- 6g. 10 stasiun awal terpopuler untuk casual 
SELECT start_station_name, COUNT(*) AS total_ride
FROM cyclistic_db.ride_trip_clean
WHERE member_type = 'casual'
  AND start_station_name IS NOT NULL AND start_station_name <> ''
GROUP BY start_station_name
ORDER BY total_ride DESC
LIMIT 10;

-- 6h. Titik ramai berdasarkan koordinat
-- Pembulatan 3 desimal = kotak sekitar 100 meter, mencakup sepeda elektrik tanpa stasiun
SELECT ROUND(start_lat, 3) AS lat, ROUND(start_lng, 3) AS lng,
       member_type, COUNT(*) AS total
FROM cyclistic_db.ride_trip_clean
GROUP BY lat, lng, member_type;
