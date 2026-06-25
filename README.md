# RakaatDetector

App iOS yang menghitung **rakaat shalat** lewat kamera + pose detection, lalu
menebak **jenis shalat** (Subuh/Dzuhur/Ashar/Maghrib/Isya) dan memvalidasi
gerakan (tuma'ninah). Semua proses **on-device, tanpa merekam video**.

> Alat bantu hitung — **bukan** penentu sah/batal shalat.

## Cara kerja (singkat)

```
Kamera (AVFoundation)
  → Vision VNDetectHumanBodyPoseRequest  → joint tubuh
  → PoseFeatures (sudut torso, rasio tinggi)  → PostureClassifier
  → PostureSmoother → RakaatStateMachine (+ MovementValidator)
  → PrayerTypeInference → RakaatSession (disimpan; cuma data ringkas)
```

**Kunci hitung rakaat:** tiap rakaat = tepat 1 ruku → hitung masuknya posisi ruku.

## Struktur

- `Sources/RakaatCore/` — **logika murni, tanpa dependensi iOS.** Bisa di-build &
  di-test di platform apa pun (`swift test`). Berisi classifier, smoother, state
  machine, validator, inference, model session.
- `Tests/RakaatCoreTests/` — unit test pakai joint sintetis (tanpa kamera).
- `iOSApp/` — kode khusus iOS (Vision, AVFoundation, SwiftUI). Ditambahkan ke
  project Xcode di Mac, meng-import `RakaatCore`.

## Privasi (prinsip wajib)

- **Tidak ada video/frame disimpan.** Frame diproses di RAM lalu dibuang.
- Yang persist ke disk cuma `RakaatSession` (jenis, rakaat, validasi, waktu).
- Semua on-device, offline, tanpa server.

## Build & test

### Logika inti (di mana saja, butuh Swift toolchain)
```
swift test
```

### App iOS (butuh macOS + Xcode + iPhone fisik)
1. Buka Xcode → buat App project (SwiftUI), tambahkan paket lokal `RakaatCore`.
2. Tarik file di `iOSApp/` ke target app.
3. (Opsional) tambah Swift Package `Adhan` untuk waktu shalat dari lokasi.
4. `Info.plist`:
   - `NSCameraUsageDescription` — "Mendeteksi gerakan shalat di HP. Tidak merekam."
   - `NSLocationWhenInUseUsageDescription` — "Menentukan waktu shalat."
5. Run di **iPhone fisik** (Vision + kamera tidak jalan di simulator).

> Vision butuh device; verifikasi pertama = skeleton overlay nempel ke badan
> saat bergerak.

## Status

- [x] RakaatCore: logika + unit test
- [x] iOSApp: Camera/Vision + 7 layar SwiftUI (Onboarding, Setup, Live, Hasil,
      Riwayat, Statistik, Settings) + navigasi tab
- [x] Mockup UI 7 layar (`design/mockups.html`)
- [ ] Build & test di **cloud Mac** (lihat `docs/BUILD_ON_CLOUD_MAC.md`)
- [ ] Integrasi Adhan (waktu shalat by lokasi)
- [ ] Tuning threshold di device nyata
- [ ] (v2) CoreML Action Classifier

> Tidak punya Mac → build via cloud Mac (MacinCloud). Lihat `docs/BUILD_ON_CLOUD_MAC.md`.
