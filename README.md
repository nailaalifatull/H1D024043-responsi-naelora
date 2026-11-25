# Naelora - Aplikasi Cuaca Terkini (Weather App)

**Naelora** adalah aplikasi perkiraan cuaca modern berbasis Flutter yang terintegrasi langsung secara *live* dengan REST API **Open-Meteo** (Forecast & Geocoding API). Aplikasi ini dibangun dengan menerapkan standar arsitektur **Model-View-ViewModel (MVVM)**, manajemen state reaktif menggunakan **Provider**, serta penyimpanan lokal data favorit dan riwayat menggunakan **SharedPreferences**.

---

## 📱 Tangkapan Layar (Screenshots)

| Home / Weather Screen | Search / Location Screen | Detail Cuaca & Favorit |
| :---: | :---: | :---: |
| *(Letakkan screenshot Home di sini)*<br>`assets/screenshots/home_screen.png` | *(Letakkan screenshot Search di sini)*<br>`assets/screenshots/search_screen.png` | *(Letakkan screenshot Favorit di sini)*<br>`assets/screenshots/favorites_tab.png` |

> *Tip: Simpan gambar screenshot hasil running pada folder `assets/screenshots/` dan tautkan ke README.*

---

## 🌟 Fitur Utama Sesuai Ketentuan Responsi

### 1. Home / Weather Screen
- **Nama Kota Terpilih**: Menampilkan nama lokasi aktif saat ini (disimpan otomatis untuk dimuat kembali ketika aplikasi dibuka ulang).
- **Kondisi Cuaca Terkini**: Menampilkan status cuaca dinamis (Cerah, Berawan, Hujan, Badai Petir, dll.) sesuai WMO Weather Interpretation Code dengan latar belakang gradien adaptif.
- **Suhu Saat Ini**: Menampilkan suhu real-time dalam derajat Celsius (°C) dari `current.temperature_2m`.
- **Detail Metrik Tambahan**:
  - Suhu yang dirasakan (*feels like*) (`current.apparent_temperature`)
  - Kelembapan udara (`current.relative_humidity_2m` %)
  - Kecepatan angin (`current.wind_speed_10m` km/j)
  - Curah hujan (`current.precipitation` mm)
  - Peluang hujan maksimum harian (`daily.precipitation_probability_max` %)
- **Perkiraan Cuaca Harian**: Ramalan cuaca 7 hari ke depan dengan info hari, tanggal, ikon cuaca, suhu maksimum & minimum (`daily.temperature_2m_max` & `daily.temperature_2m_min`), serta kemungkinan hujan.
- **Quick Favorites Chips**: Akses instan berpindah antar kota favorit hanya dengan satu ketukan.
- **Pull to Refresh**: Geser ke bawah untuk memperbarui data cuaca terkini secara real-time.
- **Handling Lengkap**: Indikator loading halus, empty state, dan tampilan error responsif dengan tombol "Coba Lagi".

### 2. Search / Location Screen
- **Pencarian Kota Real-time**: Input teks dilengkapi sistem *debounce* untuk melakukan *request* ke Open-Meteo Geocoding API.
- **Daftar Hasil Pencarian**: Menampilkan daftar kota beserta provinsi dan negara.
- **Penyimpanan Favorit**: Tombol bintang untuk menandai atau membatalkan kota favorit (tersimpan persisten di Local Storage).
- **Riwayat Pencarian**: Menyimpan riwayat lokasi yang pernah dipilih, dapat dihapus per-item maupun dikosongkan sekaligus.
- **Pemilihan Lokasi**: Memilih lokasi akan langsung mengalihkan aplikasi ke Home Screen dan memperbarui data cuaca kota tersebut.

---

## 🏛️ Arsitektur Aplikasi (MVVM Pattern)

Aplikasi Naelora memisahkan kode secara modular dan bersih ke dalam 3 lapisan arsitektur:

```
                  ┌───────────────────────────────┐
                  │          VIEW (UI)            │
                  │  HomeScreen, SearchScreen,    │
                  │  MetricCard, DailyForecast    │
                  └──────────────▲────────────────┘
                                 │ Observes &
                                 │ Dispatches Actions
                  ┌──────────────┴────────────────┐
                  │       VIEWMODEL (State)       │
                  │       WeatherViewModel        │
                  │   (ChangeNotifier & Provider) │
                  └───────┬───────────────┬───────┘
     Calls API            │               │  Reads / Writes
     Requests             ▼               ▼  Local Cache
       ┌──────────────────────┐      ┌──────────────────────┐
       │   WeatherApiService  │      │    StorageService    │
       │   (Open-Meteo REST)  │      │ (SharedPreferences)  │
       └──────────┬───────────┘      └──────────┬───────────┘
                  │ Maps JSON                   │ Serializes
                  ▼                             ▼
       ┌────────────────────────────────────────────────────┐
       │                   MODEL LAYER                      │
       │     WeatherData, CurrentWeather, DailyForecast,     │
       │                   LocationModel                    │
       └────────────────────────────────────────────────────┘
```

1. **Model Layer (`lib/models/`)**:
   - `LocationModel`: Representasi entitas lokasi geocoding dengan dukungan serialisasi JSON (`toJson`, `fromJson`, `toJsonString`, `fromJsonString`).
   - `WeatherModel`: Entitas cuaca terkini (`CurrentWeather`), ramalan harian (`DailyForecast`), dan wrapper `WeatherData`.

2. **Service Layer (`lib/services/`)**:
   - `WeatherApiService`: Bertanggung jawab atas HTTP GET request ke Open-Meteo REST API dengan penanganan timeout, validasi status code HTTP, dan pengecekan koneksi (`SocketException`).
   - `StorageService`: Mengelola penyimpanan lokal data favorit, riwayat pencarian, dan lokasi terakhir dengan `shared_preferences`.

3. **ViewModel Layer (`lib/viewmodels/`)**:
   - `WeatherViewModel`: Mewarisi `ChangeNotifier` untuk mengontrol alur data, memicu pembaruan UI via `notifyListeners()`, mengelola status cuaca (`WeatherStatus`), status pencarian (`SearchStatus`), serta koordinasi antar service.

4. **View Layer (`lib/views/` & `lib/widgets/`)**:
   - Antarmuka berbasis Material 3 yang reaktif menggunakan `Consumer<WeatherViewModel>`, memisahkan tampilan dengan logika bisnis secara tegas.

---

## 🌐 Dokumentasi Integrasi REST API (Open-Meteo)

Data cuaca dan pencarian lokasi diambil langsung dari Open-Meteo tanpa API Key (bebas diakses):

### 1. Endpoint Cuaca (Forecast API)
- **URL**: `https://api.open-meteo.com/v1/forecast`
- **Metode**: `GET`
- **Parameter Utama**:
  - `latitude`: Koordinat lintang kota
  - `longitude`: Koordinat bujur kota
  - `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  - `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  - `timezone`: `auto`

### 2. Endpoint Pencarian Lokasi (Geocoding API)
- **URL**: `https://geocoding-api.open-meteo.com/v1/search`
- **Metode**: `GET`
- **Parameter Utama**:
  - `name`: Kata kunci nama kota
  - `count`: Jumlah hasil maksimum (`10`)
  - `language`: Bahasa hasil (`id`)
  - `format`: Format respons (`json`)

---

## 📂 Struktur Direktori Proyek

```
weather_app/
├── android/
│   └── app/src/main/AndroidManifest.xml (Internet permission enabled)
├── lib/
│   ├── main.dart                      # Inisialisasi Provider, Theme, & Localizations
│   ├── models/
│   │   ├── location_model.dart        # Model data lokasi geocoding & favorit
│   │   └── weather_model.dart         # Model cuaca terkini & perkiraan harian
│   ├── services/
│   │   ├── storage_service.dart       # SharedPreferences (favorit, riwayat, sesi)
│   │   └── weather_api_service.dart   # REST API Open-Meteo client (HTTP GET)
│   ├── theme/
│   │   └── app_theme.dart             # Material 3 Styling, Colors, & Typography
│   ├── utils/
│   │   └── weather_helper.dart        # WMO Weather Code parser (ikon & deskripsi)
│   ├── viewmodels/
│   │   └── weather_viewmodel.dart     # Pengelolaan State MVVM (ChangeNotifier)
│   ├── views/
│   │   ├── home/
│   │   │   └── home_screen.dart       # Layar Utama: Cuaca terkini, metrik, harian
│   │   └── search/
│   │       └── search_screen.dart     # Layar Cari: Input kota, Favorit, Riwayat
│   └── widgets/
│       ├── daily_forecast_item.dart   # Widget card perkiraan cuaca per hari
│       └── metric_card.dart           # Widget card metrik kelembapan, angin, dll.
├── test/
│   ├── api_test.dart                  # Automated integration test REST API
│   └── widget_test.dart               # Smoke test widget Flutter
└── pubspec.yaml                       # Dependencies: provider, http, shared_preferences, intl
```

---

## 🚀 Panduan Menjalankan Aplikasi

### Persyaratan:
1. Flutter SDK (versi 3.13.0 ke atas)
2. Android Studio atau VS Code
3. Koneksi internet aktif untuk request API Open-Meteo

### Langkah-langkah:
1. Buka folder proyek ini di **Android Studio**.
2. Buka terminal atau jalankan perintah:
   ```bash
   flutter pub get
   ```
3. Sambungkan perangkat fisik Android (aktifkan USB Debugging) atau jalankan Emulator Android.
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```
5. Untuk memverifikasi integrasi API:
   ```bash
   flutter test test/api_test.dart
   ```
