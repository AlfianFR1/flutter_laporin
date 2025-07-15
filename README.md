# 📱 Lapor.in

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Build](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)

**Lapor.in** adalah aplikasi mobile berbasis Flutter untuk mengelola pelaporan kejadian atau permasalahan di sekitar pengguna secara efisien. Aplikasi ini memungkinkan pengguna membuat laporan, melihat perkembangan status, dan mendapatkan notifikasi secara real-time.

---

## 🚀 Fitur Utama

- 🔐 **Autentikasi Pengguna**
  - Login dengan Email & Password
  - Login dengan Google (Google Sign-In)

- 📝 **Pengajuan Laporan**
  - Form pelaporan dengan deskripsi, gambar, dan lokasi
  - Riwayat laporan pengguna

- 🔄 **Manajemen Status Laporan**
  - Status: `Pending`, `On Progress`, `Resolved`, `Rejected`, `Canceled`
  - Admin dapat memberikan komentar dan mengubah status

- 🔔 **Notifikasi Real-Time**
  - Integrasi Firebase Cloud Messaging (FCM)

- 📦 **Backend Terintegrasi**
  - Backend dibangun dengan **Express.js + MySQL**
  - REST API untuk komunikasi antara frontend dan backend

---

## 🖼️ Cuplikan Layar

| Beranda | Detail Laporan | Login |
|--------|----------------|-------|
| ![home](screenshots/home.png) | ![detail](screenshots/detail.png) | ![login](screenshots/login.png) |

---

## ⚙️ Teknologi yang Digunakan

| Flutter App               | Backend API                 |
|--------------------------|-----------------------------|
| Flutter 3.x              | Express.js (Node.js)        |
| Provider (State Mgmt)    | Sequelize ORM (MySQL)       |
| Firebase Auth & FCM      | JWT Authentication          |
| HTTP REST API            | Role-based Access Control   |

---

## 📂 Struktur Folder (Client - Flutter)

```bash
lib/
├── main.dart
├── screens/           # Tampilan UI
├── providers/         # Provider state management
├── services/          # API service, Firebase service
├── models/            # Model-data (User, Report, dst.)
└── utils/             # Helper (format tanggal, dll.)
```

## 🛠️ Instalasi & Menjalankan Aplikasi
```bash
git clone https://github.com/AlfianFR1/flutter_laporin.git
cd laporin
flutter pub get
flutter run
```

## 🔔 Catatan Penting
Pastikan file berikut sudah tersedia:

```bash
android/app/google-services.json → dari Firebase Console
Internet aktif (dibutuhkan untuk autentikasi Firebase & koneksi ke API backend)
```
## 👨‍💻 Author

**Alfian Fathur Rohman**  