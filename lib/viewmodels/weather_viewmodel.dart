import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_api_service.dart';

enum WeatherStatus { initial, loading, success, error }
enum SearchStatus { initial, loading, success, error, empty }

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final StorageService _storageService;

  WeatherViewModel({
    WeatherApiService? apiService,
    StorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? StorageService();

  // State Cuaca
  WeatherStatus _weatherStatus = WeatherStatus.initial;
  WeatherData? _weatherData;
  LocationModel? _currentLocation;
  String? _weatherErrorMessage;

  // State Pencarian
  SearchStatus _searchStatus = SearchStatus.initial;
  List<LocationModel> _searchResults = [];
  String? _searchErrorMessage;
  String _lastSearchQuery = '';

  // State Data Lokal
  List<LocationModel> _favorites = [];
  List<LocationModel> _history = [];

  // Getters Cuaca
  WeatherStatus get weatherStatus => _weatherStatus;
  bool get isLoadingWeather => _weatherStatus == WeatherStatus.loading;
  bool get isWeatherSuccess => _weatherStatus == WeatherStatus.success;
  bool get isWeatherError => _weatherStatus == WeatherStatus.error;
  WeatherData? get weatherData => _weatherData;
  LocationModel? get currentLocation => _currentLocation;
  String? get weatherErrorMessage => _weatherErrorMessage;

  // Getters Pencarian
  SearchStatus get searchStatus => _searchStatus;
  bool get isSearching => _searchStatus == SearchStatus.loading;
  List<LocationModel> get searchResults => _searchResults;
  String? get searchErrorMessage => _searchErrorMessage;
  String get lastSearchQuery => _lastSearchQuery;

  // Getters Data Lokal
  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get history => _history;

  /// Default Lokasi (Jakarta) jika belum pernah ada riwayat atau preferensi
  static final LocationModel defaultLocation = LocationModel(
    name: 'Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
    country: 'Indonesia',
    admin1: 'DKI Jakarta',
  );

  /// Inisialisasi awal saat aplikasi dibuka
  Future<void> init() async {
    await loadFavorites();
    await loadHistory();

    // Muat lokasi terakhir yang disimpan atau gunakan default
    final savedLocation = await _storageService.getLastLocation();
    final targetLocation = savedLocation ?? defaultLocation;

    await fetchWeatherForLocation(targetLocation);
  }

  /// Memuat data cuaca untuk lokasi tertentu
  Future<void> fetchWeatherForLocation(LocationModel location) async {
    _currentLocation = location;
    _weatherStatus = WeatherStatus.loading;
    _weatherErrorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchWeather(location.latitude, location.longitude);
      _weatherData = data;
      _weatherStatus = WeatherStatus.success;

      // Simpan lokasi ini sebagai lokasi aktif terakhir
      await _storageService.saveLastLocation(location);
    } catch (e) {
      _weatherStatus = WeatherStatus.error;
      _weatherErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Muat ulang data cuaca saat ini (Pull to refresh)
  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await fetchWeatherForLocation(_currentLocation!);
    }
  }

  /// Memilih lokasi (misal dari pencarian atau favorit)
  Future<void> selectLocation(LocationModel location) async {
    await _storageService.addSearchHistory(location);
    await loadHistory();
    await fetchWeatherForLocation(location);
  }

  /// Melakukan pencarian lokasi ke Open-Meteo Geocoding API
  Future<void> searchLocations(String query) async {
    final trimmed = query.trim();
    _lastSearchQuery = trimmed;

    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchStatus = SearchStatus.initial;
      _searchErrorMessage = null;
      notifyListeners();
      return;
    }

    _searchStatus = SearchStatus.loading;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      final results = await _apiService.searchLocations(trimmed);
      _searchResults = results;
      _searchStatus = results.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } catch (e) {
      _searchStatus = SearchStatus.error;
      _searchErrorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Bersihkan hasil pencarian
  void clearSearch() {
    _searchResults = [];
    _searchStatus = SearchStatus.initial;
    _searchErrorMessage = null;
    _lastSearchQuery = '';
    notifyListeners();
  }

  /// Memuat daftar favorit dari storage
  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  /// Cek apakah suatu lokasi adalah favorit
  bool isFavorite(LocationModel location) {
    return _favorites.any((loc) =>
        loc.latitude == location.latitude && loc.longitude == location.longitude);
  }

  /// Toggle status favorit suatu lokasi
  Future<void> toggleFavorite(LocationModel location) async {
    await _storageService.toggleFavorite(location);
    await loadFavorites();
  }

  /// Memuat riwayat pencarian dari storage
  Future<void> loadHistory() async {
    _history = await _storageService.getSearchHistory();
    notifyListeners();
  }

  /// Menghapus satu entri riwayat
  Future<void> removeHistory(LocationModel location) async {
    await _storageService.removeSearchHistory(location);
    await loadHistory();
  }

  /// Menghapus seluruh riwayat
  Future<void> clearAllHistory() async {
    await _storageService.clearSearchHistory();
    _history = [];
    notifyListeners();
  }
}
