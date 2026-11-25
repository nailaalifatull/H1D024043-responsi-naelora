import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../utils/weather_helper.dart';

class DailyForecastItem extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const DailyForecastItem({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = isToday ? 'Hari Ini' : DateFormat('EEEE', 'id_ID').format(forecast.date);
    final dateString = DateFormat('d MMM', 'id_ID').format(forecast.date);
    final weatherDesc = WeatherHelper.getWeatherDescription(forecast.weatherCode);
    final weatherIcon = WeatherHelper.getWeatherIcon(forecast.weatherCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFF93C5FD), width: 1.5)
            : Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hari & Tanggal
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    color: isToday ? const Color(0xFF1D4ED8) : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Ikon & Kondisi Cuaca
          Icon(
            weatherIcon,
            color: const Color(0xFF2563EB),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherDesc,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (forecast.precipitationProbabilityMax > 0)
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 11, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 2),
                      Text(
                        '${forecast.precipitationProbabilityMax}% hujan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Suhu Min - Max
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${forecast.temperatureMax.round()}°',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${forecast.temperatureMin.round()}°',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
