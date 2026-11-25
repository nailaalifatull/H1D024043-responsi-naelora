import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  static const String _weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca berdasarkan koordinat latitude & longitude
  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
    };

    final uri = Uri.parse(_weatherBaseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(data);
      } else {
        throw HttpException('Gagal memuat cuaca (Status Code: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw TimeoutException('Koneksi waktu tunggu habis saat memuat cuaca.');
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan saat memuat data cuaca: $e');
    }
  }

  /// Mencari lokasi kota berdasarkan kata kunci
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final queryParams = {
      'name': trimmed,
      'count': '10',
      'language': 'id',
      'format': 'json',
    };

    final uri = Uri.parse(_geocodingBaseUrl).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;

        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Gagal mencari lokasi (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet untuk pencarian kota.');
    } on TimeoutException {
      throw TimeoutException('Pencarian kota melampaui batas waktu.');
    } catch (e) {
      if (e is SocketException || e is TimeoutException || e is HttpException) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan saat mencari lokasi: $e');
    }
  }
}
