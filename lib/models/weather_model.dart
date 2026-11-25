class CurrentWeather {
  final double temperature; // temperature_2m
  final int relativeHumidity; // relative_humidity_2m (%)
  final double apparentTemperature; // apparent_temperature (°C)
  final double precipitation; // precipitation (mm)
  final int weatherCode; // weather_code
  final double windSpeed; // wind_speed_10m (km/h)
  final DateTime time;

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double temperatureMax; // temperature_2m_max
  final double temperatureMin; // temperature_2m_min
  final int precipitationProbabilityMax; // precipitation_probability_max (%)

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
  });
}

class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>? ?? {};
    final dailyMap = json['daily'] as Map<String, dynamic>? ?? {};

    final current = CurrentWeather.fromJson(currentMap);

    final List<DailyForecast> dailyList = [];
    final timeList = dailyMap['time'] as List<dynamic>? ?? [];
    final codeList = dailyMap['weather_code'] as List<dynamic>? ?? [];
    final maxTempList = dailyMap['temperature_2m_max'] as List<dynamic>? ?? [];
    final minTempList = dailyMap['temperature_2m_min'] as List<dynamic>? ?? [];
    final precipList = dailyMap['precipitation_probability_max'] as List<dynamic>? ?? [];

    for (int i = 0; i < timeList.length; i++) {
      dailyList.add(DailyForecast(
        date: DateTime.parse(timeList[i] as String),
        weatherCode: i < codeList.length ? (codeList[i] as num).toInt() : 0,
        temperatureMax: i < maxTempList.length ? (maxTempList[i] as num).toDouble() : 0.0,
        temperatureMin: i < minTempList.length ? (minTempList[i] as num).toDouble() : 0.0,
        precipitationProbabilityMax:
            i < precipList.length && precipList[i] != null ? (precipList[i] as num).toInt() : 0,
      ));
    }

    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'auto',
      current: current,
      daily: dailyList,
    );
  }
}
