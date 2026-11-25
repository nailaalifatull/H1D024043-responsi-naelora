import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../utils/weather_helper.dart';

class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;
  final int index;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    required this.index,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = isToday ? 'Hari Ini' : DateFormat('EEEE', 'id_ID').format(forecast.date);
    final dateString = DateFormat('d MMM', 'id_ID').format(forecast.date);
    final title = '$dayName · $dateString';
    final weatherDesc = WeatherHelper.getWeatherDescription(forecast.weatherCode);
    final weatherIcon = WeatherHelper.getWeatherIcon(forecast.weatherCode);

    // Dynamic pastel color themes for list items
    final colors = _getItemColors(index, forecast.weatherCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pastel Icon Circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              weatherIcon,
              size: 22,
              color: colors.iconColor,
            ),
          ),
          const SizedBox(width: 14),

          // Day & Condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weatherDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Rain Probability Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.pillBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${forecast.precipitationProbabilityMax}% hujan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.pillText,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Temperature Range (e.g. 33° / 26°)
          Text(
            '${forecast.temperatureMax.round()}° / ${forecast.temperatureMin.round()}°',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  _ItemColors _getItemColors(int idx, int code) {
    final mod = idx % 4;
    switch (mod) {
      case 0:
        // Blue palette (Gerimis/Hujan)
        return _ItemColors(
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          pillBg: const Color(0xFFE0F2FE),
          pillText: const Color(0xFF0369A1),
        );
      case 1:
        // Purple palette (Hujan Sedang)
        return _ItemColors(
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          pillBg: const Color(0xFFF3E8FF),
          pillText: const Color(0xFF7E22CE),
        );
      case 2:
        // Pink palette (Berawan Cerah)
        return _ItemColors(
          iconBg: const Color(0xFFFCE7F3),
          iconColor: const Color(0xFFDB2777),
          pillBg: const Color(0xFFFCE7F3),
          pillText: const Color(0xFFBE185D),
        );
      case 3:
      default:
        // Yellow palette (Cerah Berawan)
        return _ItemColors(
          iconBg: const Color(0xFFFEF9C3),
          iconColor: const Color(0xFFCA8A04),
          pillBg: const Color(0xFFFEF9C3),
          pillText: const Color(0xFFA16207),
        );
    }
  }
}

class _ItemColors {
  final Color iconBg;
  final Color iconColor;
  final Color pillBg;
  final Color pillText;

  _ItemColors({
    required this.iconBg,
    required this.iconColor,
    required this.pillBg,
    required this.pillText,
  });
}
