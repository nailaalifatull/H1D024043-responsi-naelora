// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:naelora/services/weather_api_service.dart';

void main() {
  test('Test Live Open-Meteo API connection and data parsing', () async {
    final service = WeatherApiService(client: http.Client());

    // 1. Uji Fetch Weather Purwokerto (lat: -7.4243, lon: 109.2302)
    final weather = await service.fetchWeather(-7.4243, 109.2302);
    expect(weather, isNotNull);
    expect(weather.current.temperature, isA<double>());
    expect(weather.current.relativeHumidity, isA<int>());
    expect(weather.daily.isNotEmpty, true);

    print('✓ Live Weather Data Purwokerto:');
    print('  Suhu: ${weather.current.temperature}°C');
    print('  Kelembapan: ${weather.current.relativeHumidity}%');
    print('  Kecepatan Angin: ${weather.current.windSpeed} km/h');
    print('  Jumlah Hari Perkiraan: ${weather.daily.length}');

    // 2. Uji Geocoding Search Purwokerto
    final searchResults = await service.searchLocations('Purwokerto');
    expect(searchResults.isNotEmpty, true);
    print('✓ Live Search Geocoding Data:');
    print('  Kota Ditemukan: ${searchResults.first.displayName}');
    print('  Koordinat: (${searchResults.first.latitude}, ${searchResults.first.longitude})');
  });
}
