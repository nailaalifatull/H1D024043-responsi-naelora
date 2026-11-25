import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherAdvice {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final List<String> tags;

  WeatherAdvice({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.tags,
  });
}

class WeatherAdviceHelper {
  static WeatherAdvice getAdvice(WeatherData weather) {
    final current = weather.current;
    final code = current.weatherCode;
    final temp = current.temperature;
    final rainProb = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;
    final wind = current.windSpeed;

    // 1. Kondisi Badai Petir
    if (code >= 95) {
      return WeatherAdvice(
        title: 'Waspada Badai Petir!',
        description:
            'Hindari aktivitas di tempat terbuka. Cabut alat elektronik yang rentan dan cari tempat berlindung yang aman.',
        icon: Icons.thunderstorm_rounded,
        iconColor: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        tags: ['Tetap di Rumah', 'Hindari Pohon Tinggi', 'Waspada Petir'],
      );
    }

    // 2. Kondisi Hujan / Gerimis / Peluang Hujan Sangat Tinggi
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82) || rainProb >= 70) {
      return WeatherAdvice(
        title: 'Sedia Payung atau Jas Hujan!',
        description:
            'Hujan berpotensi turun hari ini. Pastikan membawa payung atau jas hujan jika bepergian dan berkendara dengan hati-hati.',
        icon: Icons.umbrella_rounded,
        iconColor: const Color(0xFF0284C7),
        bgColor: const Color(0xFFE0F2FE),
        tags: ['Bawa Payung', 'Jas Hujan', 'Jalanan Licin'],
      );
    }

    // 3. Kondisi Suhu Panas / Terik (> 31°C atau cerah 0-1)
    if (temp >= 31 || (code == 0 && temp >= 28)) {
      return WeatherAdvice(
        title: 'Cuaca Cukup Terik!',
        description:
            'Gunakan tabir surya (sunscreen) saat keluar ruangan. Perbanyak minum air putih agar tubuh tetap terhidrasi dengan baik.',
        icon: Icons.wb_sunny_rounded,
        iconColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        tags: ['Minum Air Putih', 'Gunakan Sunscreen', 'Pakaian Tipis'],
      );
    }

    // 4. Kondisi Angin Kencang (> 15 km/j)
    if (wind >= 15) {
      return WeatherAdvice(
        title: 'Angin Bertiup Kencang!',
        description:
            'Waspadai dahan pohon atau baliho saat berada di luar. Kenakan jaket penahan angin (windbreaker) bila mengendarai motor.',
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF0D9488),
        bgColor: const Color(0xFFCCFBF1),
        tags: ['Gunakan Jaket', 'Hati-hati Berkendara', 'Angin Kencang'],
      );
    }

    // 5. Kondisi Suhu Dingin (< 22°C)
    if (temp <= 22) {
      return WeatherAdvice(
        title: 'Udara Cukup Dingin!',
        description:
            'Suhu terasa sejuk hingga dingin. Sangat disarankan memakai jaket hangat dan nikmati minuman hangat favorit Anda.',
        icon: Icons.coffee_rounded,
        iconColor: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFEDD5),
        tags: ['Kenakan Jaket', 'Minuman Hangat', 'Jaga Imun'],
      );
    }

    // 6. Kondisi Berawan / Mendung Sejuk
    return WeatherAdvice(
      title: 'Cuaca Sejuk & Nyaman!',
      description:
          'Kondisi ideal untuk beraktivitas atau berolahraga di luar ruangan. Udara terasa bersahabat sepanjang hari.',
      icon: Icons.mood_rounded,
      iconColor: const Color(0xFFBE185D),
      bgColor: const Color(0xFFFCE7F3),
      tags: ['Cocok Beraktivitas', 'Olahraga Sore', 'Tetap Nyaman'],
    );
  }
}
