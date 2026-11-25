# Naelora - Aplikasi Cuaca Terkini (Weather App)

---

## Identitas Mahasiswa

| Informasi | Keterangan |
| :--- | :--- |
| **Nama Lengkap** | Naila Alifatul |
| **NIM** | H1D024043 |
| **Program Studi** | Informatika |
| **Fakultas** | Fakultas Teknik |
| **Mata Kuliah** | Praktikum Pemrograman Bergerak |
| **Link Repository** | https://github.com/nailaalifatull/H1D024043-responsi-naelora |
| **Link Youtube** | https://youtu.be/7rcvEJNeeeY |

---

## 📱 Tangkapan Layar Aplikasi (Screenshots)

Berikut adalah dokumentasi visual dari setiap layar (*screen*) dan fitur utama aplikasi Naelora:

### 1. Halaman Cuaca Utama & Rekomendasi Cerdas
| Cuaca Terkini (Home) | Detail Cuaca & Saran Hari Ini | Perkiraan Cuaca Harian |
| :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/2eb933c6-d54c-470d-93da-9e7bc4839690" width="230" alt="Home Screen" /><br><sub><b>Cuaca Terkini & Hero Card</b></sub> | <img src="https://github.com/user-attachments/assets/efa76b84-a31a-479b-af6b-ce53e53a3998" width="230" alt="Detail & Saran" /><br><sub><b>4 Metrik & Saran Hari Ini</b></sub> | <img src="https://github.com/user-attachments/assets/3f28f3ff-2d06-4138-865d-291185cf7f94" width="230" alt="Ramalan Harian" /><br><sub><b>Perkiraan Cuaca 7 Hari</b></sub> |

### 2. Fitur Pencarian, Kota Favorit, & Pengaturan
| Pencarian & Rekomendasi | Hasil Pencarian API | Halaman Kota Favorit | Halaman Pengaturan |
| :---: | :---: | :---: | :---: |
| <img src="https://github.com/user-attachments/assets/aa2102ee-0a98-44b1-86a8-35934626dc8c" width="200" alt="Search Screen" /><br><sub><b>Cari Kota & Populer</b></sub> | <img src="https://github.com/user-attachments/assets/3f76c691-3e74-4f90-a2aa-3f64ab98cc7c" width="200" alt="Hasil Pencarian" /><br><sub><b>Hasil Geocoding API</b></sub> | <img src="https://github.com/user-attachments/assets/bd2edecd-c099-4acb-aee4-0f80670f7024" width="200" alt="Kota Favorit" /><br><sub><b>Daftar Kota Favorit</b></sub> | <img src="https://github.com/user-attachments/assets/ebeff259-015d-44d0-a428-14509cdb62c6" width="200" alt="Pengaturan" /><br><sub><b>Menu Pengaturan</b></sub> |

---

## Penerapan Pola Arsitektur MVVM (Model-View-ViewModel)

Aplikasi Naelora dibangun dengan menerapkan standar arsitektur **Model-View-ViewModel (MVVM)** menggunakan pustaka **Provider (`ChangeNotifier`)** sebagai pengendali state reaktif. Arsitektur ini memisahkan kode menjadi lapisan-lapisan yang independen dan modular:

```
                  ┌───────────────────────────────────────────┐
                  │                VIEW (UI)                  │
                  │  HomeScreen, SearchScreen,                │
                  │  FavoritesScreen, SettingsScreen          │
                  └─────────────────────▲─────────────────────┘
                                        │ Observes State &
                                        │ Dispatches Events
                  ┌─────────────────────┴─────────────────────┐
                  │             VIEWMODEL (State)             │
                  │             WeatherViewModel              │
                  │        (ChangeNotifier & Provider)        │
                  └──────────┬─────────────────────┬──────────┘
           Calls API Request │                     │ Reads / Writes
                             ▼                     ▼ Local Cache
        ┌─────────────────────────┐   ┌─────────────────────────┐
        │    WeatherApiService    │   │     StorageService      │
        │    (Open-Meteo REST)    │   │   (SharedPreferences)   │
        └────────────┬────────────┘   └────────────┬────────────┘
         Maps JSON   │                 Serializes  │
                     ▼                             ▼
        ┌───────────────────────────────────────────────────────┐
        │                      MODEL LAYER                      │
        │       WeatherData, CurrentWeather, DailyForecast,     │
        │                      LocationModel                    │
        └───────────────────────────────────────────────────────┘
```

### 1. Model Layer (`lib/models/`)
Mendefinisikan entitas data murni dan memetakan serialisasi data:
- `LocationModel` ([lib/models/location_model.dart](lib/models/location_model.dart)): Memodelkan entitas kota dari Geocoding API (nama, koordinat lintang/bujur, provinsi, negara) serta serialisasi JSON String untuk disimpan ke Local Storage.
- `WeatherModel` ([lib/models/weather_model.dart](lib/models/weather_model.dart)): 
  - `CurrentWeather`: Memetakan data cuaca terkini (`temperature_2m`, `relative_humidity_2m`, `apparent_temperature`, `precipitation`, `weather_code`, `wind_speed_10m`).
  - `DailyForecast`: Memetakan data ramalan harian 7 hari (`temperature_2m_max`, `temperature_2m_min`, `precipitation_probability_max`).
  - `WeatherData`: Wrapper utama yang menaungi data cuaca terkini dan daftar perkiraan harian.

### 2. Service Layer (`lib/services/`)
Bertanggung jawab atas komunikasi eksternal dan isolasi I/O:
- `WeatherApiService` ([lib/services/weather_api_service.dart](lib/services/weather_api_service.dart)): Menjalankan HTTP GET request ke Open-Meteo REST API, menangani validasi status kode HTTP, batas waktu (*timeout* 12 detik), dan proteksi putus koneksi (*SocketException*).
- `StorageService` ([lib/services/storage_service.dart](lib/services/storage_service.dart)): Mengelola penyimpanan data lokal persisten berbasis `SharedPreferences` untuk menyimpan daftar lokasi favorit, riwayat pencarian, dan lokasi aktif terakhir.

### 3. ViewModel Layer (`lib/viewmodels/`)
Sebagai otak logika aplikasi yang menghubungkan View dan Service:
- `WeatherViewModel` ([lib/viewmodels/weather_viewmodel.dart](lib/viewmodels/weather_viewmodel.dart)): Mewarisi `ChangeNotifier`. Mengatur state status cuaca (`WeatherStatus`: *initial*, *loading*, *success*, *error*) dan status pencarian (`SearchStatus`). Ketika data selesai diunduh atau lokasi diubah, ViewModel memanggil `notifyListeners()` sehingga UI diperbarui secara otomatis.

### 4. View Layer (`lib/views/` & `lib/widgets/`)
Antarmuka pengguna berbasis Flutter Material 3 yang bersifat reaktif:
- Menggunakan widget `Consumer<WeatherViewModel>` untuk mendengarkan perubahan data di ViewModel tanpa memuat ulang (*rebuild*) seluruh layar.

---

## Implementasi REST API (Open-Meteo)

Aplikasi Naelora terhubung langsung secara *live* dengan **Open-Meteo REST API** (tanpa API key):

### 1. Weather Forecast API
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Metode**: `GET`
- **Parameter Request**:
  | Parameter | Nilai / Format | Keterangan |
  | :--- | :--- | :--- |
  | `latitude` | `double` (misal: `-7.4243`) | Koordinat lintang lokasi |
  | `longitude` | `double` (misal: `109.2302`) | Koordinat bujur lokasi |
  | `current` | `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m` | Parameter cuaca terkini |
  | `daily` | `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max` | Parameter ramalan harian |
  | `timezone` | `auto` | Zona waktu otomatis sesuai lokasi |

- **Pemetaan Field API ke UI**:
  - Suhu saat ini: `current.temperature_2m` (°C)
  - Kelembapan udara: `current.relative_humidity_2m` (%)
  - Suhu yang dirasakan: `current.apparent_temperature` (°C)
  - Curah hujan: `current.precipitation` (mm)
  - Kecepatan angin: `current.wind_speed_10m` (km/j)
  - Kondisi cuaca: `current.weather_code` (diterjemahkan melalui `WeatherHelper` ke Bahasa Indonesia dan ikon tematik)
  - Suhu harian: `daily.temperature_2m_max` & `daily.temperature_2m_min`
  - Peluang hujan: `daily.precipitation_probability_max` (%)

### 2. Geocoding API (Pencarian Lokasi)
- **Endpoint**: `https://geocoding-api.open-meteo.com/v1/search`
- **Metode**: `GET`
- **Parameter**: `name={query}&count=10&language=id&format=json`
- **Fitur Debounce**: Pencarian dilengkapi jeda *debounce* 400ms untuk mencegah pemanggilan request berlebihan saat pengguna sedang mengetik.

### 3. Penanganan Kondisi Jaringan (Resilience)
- **Loading State**: Menampilkan indikator loading halus saat data sedang diambil dari server.
- **Empty State**: Menampilkan pesan informatif jika pencarian kota tidak ditemukan.
- **Error State**: Menampilkan kartu error ramah pengguna dengan tombol **"Coba Lagi"** jika terjadi masalah jaringan atau timeout.

---

## Struktur Direktori Proyek

```
weather_app/
├── android/
│   ├── app/src/main/AndroidManifest.xml  # Izin akses internet Android
│   └── gradle.properties                 # Konfigurasi stabilitas kompilasi Kotlin
├── assets/
│   └── screenshots/                      # Tempat penyimpanan gambar dokumentasi
├── lib/
│   ├── main.dart                         # Entry point aplikasi & inisialisasi Provider
│   ├── models/
│   │   ├── location_model.dart           # Model data lokasi, koordinat, dan serialisasi
│   │   └── weather_model.dart            # Model respons cuaca terkini dan ramalan harian
│   ├── services/
│   │   ├── storage_service.dart          # Local Storage SharedPreferences
│   │   └── weather_api_service.dart      # HTTP Client request Open-Meteo
│   ├── theme/
│   │   └── app_theme.dart                # Tema Material 3 & palet warna pastel
│   ├── utils/
│   │   ├── weather_advice_helper.dart    # Algoritma cerdas fitur "Saran Hari Ini"
│   │   └── weather_helper.dart           # Penerjemah kode cuaca WMO ke ikon & teks
│   ├── viewmodels/
│   │   └── weather_viewmodel.dart        # Pengelola state logika bisnis MVVM
│   ├── views/
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart     # Layar kelola daftar kota favorit
│   │   ├── home/
│   │   │   └── home_screen.dart          # Layar utama cuaca, metrik, & ramalan harian
│   │   ├── search/
│   │   │   └── search_screen.dart        # Layar pencarian geocoding & riwayat
│   │   └── settings/
│   │       └── settings_screen.dart      # Layar pengaturan unit & manajemen data
│   └── widgets/
│       ├── cute_weather_art.dart         # Ilustrasi vektor awan kawaii custom painter
│       ├── daily_forecast_item.dart      # Widget kartu ramalan cuaca per hari
│       ├── metric_card.dart              # Widget kartu metrik responsif (FittedBox)
│       └── weather_advice_card.dart      # Widget kartu saran aktivitas & pakaian
├── test/
│   ├── api_test.dart                     # Automated integration test Open-Meteo API
│   └── widget_test.dart                  # Smoke test antarmuka Flutter
└── pubspec.yaml                          # Dependensi: provider, http, shared_preferences, intl
```

---

## Panduan Menjalankan Aplikasi

1. **Clone Repository**:
   ```bash
   git clone https://github.com/nailaalifatull/H1D024043-responsi-naelora.git
   cd H1D024043-responsi-naelora
   ```
2. **Unduh Dependensi**:
   ```bash
   flutter pub get
   ```
3. **Jalankan Pengujian API (Opsional)**:
   ```bash
   flutter test test/api_test.dart
   ```
4. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```
