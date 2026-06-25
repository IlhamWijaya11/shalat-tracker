# Build iOS Tanpa Punya Mac (Cloud Mac)

Lu develop di Windows. Tahap build/run iOS dilakukan di **Mac sewaan di cloud**.
Panduan ini langkah demi langkah.

## Yang dibutuhkan

- **Cloud Mac** — pilih salah satu:
  - [MacinCloud](https://www.macincloud.com) — sewa per jam / bulanan, akses Remote Desktop.
  - [MacStadium](https://www.macstadium.com) — lebih pro, bulanan.
- **Apple Developer Account** — $99/tahun, wajib buat install ke iPhone fisik &
  TestFlight. ([developer.apple.com](https://developer.apple.com))
- **iPhone fisik** (Vision + kamera tidak jalan di simulator).

## Langkah

### 1. Pindahkan kode ke cloud Mac
- Push folder `shalat tracker` ke GitHub dari Windows, lalu `git clone` di Mac.
- Atau upload lewat fitur file-transfer Remote Desktop.

### 2. Test logika inti dulu (cepat, tanpa Xcode UI)
Di Terminal Mac, dalam folder `shalat tracker`:
```
swift test
```
Harus lulus semua (classifier, state machine, inference, tracker). Ini bukti
logika rakaat benar **sebelum** repot bikin UI.

### 3. Buat project Xcode
1. Buka **Xcode** → File → New → Project → **App** (SwiftUI, nama `RakaatDetector`).
2. File → Add Package Dependencies → **Add Local…** → pilih folder `shalat tracker`
   (paket `RakaatCore`). Tambahkan ke target app.
3. Tarik semua file di `iOSApp/` ke dalam target app (App/, Camera/, Vision/, UI/).
4. (Opsional) Add Package → `https://github.com/batoulapps/adhan-swift` untuk
   waktu shalat dari lokasi. Sambungkan di `PrayerTimeProvider.swift`.

### 4. Info.plist (izin)
Tambahkan:
- `NSCameraUsageDescription` = "Mendeteksi gerakan shalat di HP. Tidak merekam."
- `NSLocationWhenInUseUsageDescription` = "Menentukan waktu shalat dari lokasi."

### 5. Signing
- Tab **Signing & Capabilities** → pilih Team (Apple Developer account lu).
- Xcode urus provisioning otomatis.

### 6. Run di iPhone
- Colok iPhone ke Mac (kalau cloud Mac ga bisa colok USB, pakai **TestFlight**:
  Archive → upload ke App Store Connect → install via app TestFlight di iPhone).
- Test pertama: arahkan kamera ke orang berdiri → **skeleton overlay nempel**.

## Urutan verifikasi di device

1. Skeleton overlay nempel ke badan saat bergerak. (PoseEstimator jalan)
2. Peragakan tiap posisi → label "RUKU"/"SUJUD"/dll benar. (PostureClassifier)
3. Peragakan shalat 2 & 4 rakaat → counter cocok, salam/duduk lama → selesai.
4. Jam Subuh + 2 rakaat → hasil "Subuh". (PrayerTypeInference)
5. Ruku buru-buru → muncul peringatan tuma'ninah. (MovementValidator)

## Tips hemat biaya cloud Mac

- Selesaikan & test **semua logika di Windows** (baca kode) dulu.
- Sewa Mac cuma pas mau build UI + test device → matikan kalau ga dipakai.
- `swift test` ringan; sesi UI testing yang makan waktu.
