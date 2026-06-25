# Panduan Build & Jalanin App di iPhone (untuk Pemula)

Halo! Panduan ini buat kamu yang **bukan programmer**. Ikutin pelan-pelan, urut dari atas.
Tujuannya: app **RakaatDetector** jalan di iPhone kamu. Gak perlu ngerti coding — cukup
ikutin langkah & copy-paste kalau diminta.

> ⏱️ Perkiraan waktu pertama kali: 30–60 menit (paling lama nunggu install).

---

## A. Yang kamu butuhin (siapin dulu)

| Barang | Keterangan | Link |
|--------|------------|------|
| **Mac** | Komputer Apple (MacBook/iMac). | — |
| **Xcode** | Aplikasi buat build app iOS. Katanya udah kamu download. | https://apps.apple.com/app/xcode/id497799835 |
| **Apple ID** | Akun Apple **GRATIS**. Kemungkinan kamu udah punya (yang dipake App Store). | https://appleid.apple.com |
| **iPhone** | HP fisik beneran. **Penting:** sensor & kamera **gak jalan di simulator**, wajib iPhone asli. | — |
| **Kabel USB** | Buat colok iPhone ke Mac (kabel charge biasa). | — |

> 💡 **Apple ID gratis sudah cukup** buat install ke iPhone kamu sendiri. Gak perlu bayar
> $99/tahun — itu cuma kalau mau sebar app ke orang lain. Konsekuensinya: app "expired"
> tiap ~7 hari, tinggal di-**Run** ulang dari Xcode (gampang, lihat bagian H).

Pastikan **Xcode sudah kebuka minimal sekali** dan udah selesai "Installing components"
(kadang minta install komponen tambahan pas pertama buka — biarin sampai selesai).

---

## B. Ambil kode proyeknya

Pilih **salah satu** (cara ZIP paling gampang, gak perlu Terminal):

### Cara 1 — Download ZIP (disarankan)
1. Buka halaman proyek di GitHub (link dikasih sama yang ngirim panduan ini).
2. Klik tombol hijau **`< > Code`** → **Download ZIP**.
3. Buka folder Downloads → **klik kanan file ZIP → Extract** (atau double-click).
4. Pindahin folder hasil extract ke **Desktop** biar gampang dicari. Misal jadi:
   `Desktop/shalat-tracker`.

### Cara 2 — git clone (kalau kamu nyaman Terminal)
```
git clone <URL-repo-nya>
```

---

## C. Bikin "project Xcode" — pilih SATU jalur

App ini perlu "dijadiin project Xcode" dulu. Ada 2 cara. **Jalur 1 lebih otomatis & minim
salah** (tapi pakai Terminal sebentar). **Jalur 2 tanpa Terminal** tapi langkahnya lebih
banyak & lebih gampang kelewat. Pilih yang kamu nyaman.

---

### 🟢 JALUR 1 — Otomatis (XcodeGen) — DISARANKAN

Buka **Terminal**: tekan `Cmd (⌘) + Spasi`, ketik **Terminal**, Enter.

**Langkah 1 — Install Homebrew** (sekali seumur hidup; kalau udah punya, skip).
Copy-paste baris ini ke Terminal, Enter:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
- Nanti diminta **password Mac** (yang dipake login komputer). Ketik (gak keliatan di layar,
  itu normal), Enter.
- Tunggu sampai selesai. Kalau di akhir muncul tulisan "Next steps" minta jalanin 2 baris
  `echo ...` dan `eval ...`, copy-paste juga baris itu satu per satu (biar perintah `brew`
  dikenali). Kalau gak ada, lanjut aja.

**Langkah 2 — Install XcodeGen.** Di Terminal:
```
brew install xcodegen
```

**Langkah 3 — Masuk ke folder proyek.** Ketik `cd ` (ada spasi setelah cd), terus **drag
folder proyek dari Finder ke jendela Terminal** (otomatis ngisi alamatnya), Enter. Contoh:
```
cd ~/Desktop/shalat-tracker
```

**Langkah 4 — Bikin project-nya.** Di Terminal:
```
xcodegen generate
```
Kalau sukses muncul tulisan "Created project at .../RakaatDetector.xcodeproj".

**Langkah 5 — Buka project.** Di Terminal:
```
open RakaatDetector.xcodeproj
```
Xcode kebuka. **➡️ Lanjut ke bagian D.**

---

### 🟡 JALUR 2 — Manual lewat menu Xcode (tanpa Terminal)

1. Buka **Xcode** → menu atas **File → New → Project…**
2. Pilih tab **iOS** → **App** → **Next**.
3. Isi:
   - **Product Name:** `RakaatDetector`
   - **Interface:** `SwiftUI`
   - **Language:** `Swift`
   - **Next** → simpan di tempat yang gampang (mis. Desktop).
4. Tambah kode inti (package lokal): menu **File → Add Package Dependencies…** → kiri bawah
   klik **Add Local…** → pilih **folder proyek yang kamu download** (folder yang ADA file
   `Package.swift`-nya) → **Add Package** → centang **RakaatCore** buat target
   `RakaatDetector` → **Add Package**.
5. Tambah file app: buka **Finder**, dari folder download buka folder **`iOSApp`**. Drag
   sub-folder ini ke panel kiri Xcode (navigator): **App, Camera, Vision, Sensors, UI**.
   - Pas muncul dialog: centang **Copy items if needed** dan centang target
     **RakaatDetector** → **Finish**.
   - ⚠️ **Pastikan folder `Sensors` ikut ke-drag** (isinya `ProximityManager.swift` — ini
     bagian sensor jarak).
6. Hindari dobel: di project baru tadi Xcode bikin file `RakaatDetectorApp.swift` &
   `ContentView.swift` bawaan. Karena proyek kita udah punya `RakaatDetectorApp.swift`
   sendiri (di `iOSApp/App/`), **hapus 2 file bawaan itu**: klik kanan di navigator →
   **Delete → Move to Trash**. (Kalau gak dihapus, error "dobel @main".)
7. Izin: klik **RakaatDetector** (paling atas, ikon biru) → tab **Info** → arahkan ke
   bagian list, klik kanan → **Add Row**, tambahkan 2 ini:
   - `Privacy - Camera Usage Description` → isi: `Mendeteksi gerakan shalat di HP. Tidak merekam.`
   - `Privacy - Location When In Use Usage Description` → isi: `Menentukan waktu shalat.`

**➡️ Lanjut ke bagian D.**

---

## D. Atur "Signing" (pakai Apple ID gratis)

Ini bikin iPhone percaya sama app-nya.

1. Di Xcode, klik **RakaatDetector** (ikon biru paling atas di panel kiri).
2. Klik tab **Signing & Capabilities**.
3. Centang **Automatically manage signing**.
4. Di **Team**, klik dropdown → **Add an Account…** → login pakai **Apple ID** kamu →
   tutup jendela akun → balik ke Team, pilih nama kamu **(Personal Team)**.
5. Kalau muncul error merah **"bundle identifier is not available"**: ganti kotak
   **Bundle Identifier** jadi unik, misal `com.namakamu.rakaatdetector` (bebas, yang penting
   beda). Error-nya hilang.

---

## E. Jalanin di iPhone

1. **Colok iPhone** ke Mac pakai kabel USB. Di iPhone muncul **"Trust This Computer?"** →
   tap **Trust** → masukin passcode iPhone.
2. **iPhone iOS 16 ke atas** wajib aktifin **Developer Mode**:
   - Di iPhone: **Settings → Privacy & Security → Developer Mode → ON**.
   - iPhone minta **restart** → restart → setelah nyala, konfirmasi **Turn On**.
   - (Kalau menu "Developer Mode" belum muncul, colok ke Mac & buka Xcode dulu sekali, nanti
     muncul.)
3. Di Xcode bagian **atas tengah**, ada nama device. Klik → pilih **iPhone kamu** (BUKAN yang
   ada tulisan "Simulator").
4. Tekan tombol **▶ (Run)** di kiri atas (atau `Cmd + R`). Tunggu build ("Building…").
5. **Pertama kali**, iPhone bakal nolak dengan pesan **"Untrusted Developer"**. Benerin:
   - Di iPhone: **Settings → General → VPN & Device Management** → tap **Apple ID kamu** di
     bawah "Developer App" → **Trust** → **Trust** lagi.
   - Balik ke Xcode, tekan **▶ Run** sekali lagi. Sekarang app kebuka di iPhone. 🎉

---

## F. Tes mode "Sajadah" (sensor jarak) — gak butuh ruang/kamera

Ini mode yang baru: hitung rakaat dari sensor jarak, cocok tempat sempit.

1. Di app: **Pilih mode → Sajadah (sensor)** → **Mulai**.
2. Taruh iPhone di meja, **layar menghadap atas**.
3. **Tutup sensor atas** (deket lubang speaker telinga, bagian atas layar) pakai telapak
   tangan **±2 detik**, lalu lepas. Itu dihitung **1 sujud**.
4. Ulangi:
   - **2x tutup = 1 rakaat**
   - **4x tutup = 2 rakaat**
5. Tekan **Selesai** → hasilnya masuk ke **Riwayat**.

> Pas dipakai shalat beneran: taruh HP di sajadah di **titik dahi mendarat** saat sujud
> (BUKAN di bawah dagu — kalau sujudnya nyodok jauh ke depan, dagu lewat di atas sensor &
> gak kehitung). Ujung atas HP (sensornya) menghadap ke arah kepala.

---

## G. (Opsional) Tes logika tanpa iPhone

Mau cek "otak" penghitung rakaat bener tanpa HP? Di **Terminal**, masuk folder proyek
(`cd ~/Desktop/shalat-tracker`), jalanin:
```
swift test
```
Harus muncul semua **passed**, termasuk `ProximityRakaatCounterTests`.

---

## H. Kalau ada masalah (Troubleshooting)

| Masalah | Solusi |
|--------|--------|
| "Developer Mode required" | Bagian **E langkah 2** — aktifin Developer Mode di iPhone. |
| "Untrusted Developer" pas buka app | Bagian **E langkah 5** — Trust di Settings → General → VPN & Device Management. |
| Setelah ~7 hari app gak bisa dibuka / "expired" | Wajar buat Apple ID gratis. Colok iPhone, buka Xcode, tekan **▶ Run** lagi. Beres. |
| "Failed to register bundle identifier" | Ganti **Bundle Identifier** jadi unik (Bagian **D langkah 5**). |
| Mode Sajadah gak nambah hitungan | Pastikan nutup **sensor ATAS** (deket speaker telinga), tahan **≥1 detik**, baru lepas. |
| `brew: command not found` (Jalur 1) | Homebrew belum kepasang bener — jalanin lagi baris `echo`/`eval` yang muncul di akhir install Homebrew, atau tutup-buka Terminal. |
| Xcode error "dobel @main" / "Invalid redeclaration" | (Jalur 2) Belum hapus file `RakaatDetectorApp.swift`/`ContentView.swift` bawaan. Bagian **C Jalur 2 langkah 6**. |

---

Selamat! Kalau app udah jalan & mode Sajadah ngitung rakaat, berarti sukses. 🟢
