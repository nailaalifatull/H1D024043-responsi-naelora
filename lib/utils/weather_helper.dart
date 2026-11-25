import 'package:flutter/material.dart';

class WeatherHelper {
  static String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Sebagian Berawan';
      case 3:
        return 'Mendung / Berawan';
      case 45:
        return 'Berkabut';
      case 48:
        return 'Kabut Tebal Berembun';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Dingin / Es';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Deras';
      case 66:
      case 67:
        return 'Hujan Es Beku';
      case 71:
        return 'Salju Ringan';
      case 73:
        return 'Salju Sedang';
      case 75:
        return 'Salju Lebat';
      case 77:
        return 'Hujan Butiran Salju';
      case 80:
        return 'Hujan Singkat Ringan';
      case 81:
        return 'Hujan Singkat Sedang';
      case 82:
        return 'Hujan Singkat Deras';
      case 85:
      case 86:
        return 'Hujan Salju Singkat';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir Disertai Hujan Es';
      default:
        return 'Cuaca Tidak Diketahui';
    }
  }

  static IconData getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
        return Icons.wb_cloudy_rounded;
      case 3:
        return Icons.cloud_rounded;
      case 45:
      case 48:
        return Icons.blur_on_rounded;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit_rounded;
      case 80:
      case 81:
      case 82:
        return Icons.shower_rounded;
      case 85:
      case 86:
        return Icons.cloudy_snowing;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  static List<Color> getWeatherGradient(int code) {
    switch (code) {
      case 0:
      case 1:
        // Cerah / Sunny Sky
        return [
          const Color(0xFF2193B0),
          const Color(0xFF6DD5ED),
        ];
      case 2:
      case 3:
        // Berawan / Cloudy
        return [
          const Color(0xFF4B6CB7),
          const Color(0xFF182848),
        ];
      case 45:
      case 48:
        // Foggy
        return [
          const Color(0xFF606C88),
          const Color(0xFF3F4C6B),
        ];
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        // Rainy
        return [
          const Color(0xFF1F4068),
          const Color(0xFF162447),
        ];
      case 95:
      case 96:
      case 99:
        // Stormy
        return [
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ];
      case 71:
      case 73:
      case 75:
      case 77:
        // Snowy
        return [
          const Color(0xFF83A4D4),
          const Color(0xFFB6FBFF),
        ];
      default:
        return [
          const Color(0xFF2980B9),
          const Color(0xFF6DD5FA),
        ];
    }
  }
}
