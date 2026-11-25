import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  static const String _keyFavorites = 'naelora_favorites';
  static const String _keyHistory = 'naelora_history';
  static const String _keyLastLocation = 'naelora_last_location';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Mendapatkan daftar lokasi favorit
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await _prefs;
    final List<String>? rawList = prefs.getStringList(_keyFavorites);
    if (rawList == null) return [];
    return rawList.map((item) => LocationModel.fromJsonString(item)).toList();
  }

  /// Menyimpan daftar lokasi favorit
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await _prefs;
    final List<String> rawList = favorites.map((loc) => loc.toJsonString()).toList();
    await prefs.setStringList(_keyFavorites, rawList);
  }

  /// Menambah atau menghapus favorit
  Future<bool> toggleFavorite(LocationModel location) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((loc) =>
        loc.latitude == location.latitude && loc.longitude == location.longitude);

    bool isNowFav;
    if (index >= 0) {
      favorites.removeAt(index);
      isNowFav = false;
    } else {
      favorites.add(location);
      isNowFav = true;
    }

    await saveFavorites(favorites);
    return isNowFav;
  }

  /// Cek apakah suatu lokasi ada di daftar favorit
  Future<bool> isFavorite(LocationModel location) async {
    final favorites = await getFavorites();
    return favorites.any((loc) =>
        loc.latitude == location.latitude && loc.longitude == location.longitude);
  }

  /// Mendapatkan riwayat pencarian
  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await _prefs;
    final List<String>? rawList = prefs.getStringList(_keyHistory);
    if (rawList == null) return [];
    return rawList.map((item) => LocationModel.fromJsonString(item)).toList();
  }

  /// Menambahkan lokasi ke riwayat pencarian (maksimal 10 terakhir, tanpa duplikasi di posisi teratas)
  Future<void> addSearchHistory(LocationModel location) async {
    final history = await getSearchHistory();
    history.removeWhere((loc) =>
        loc.latitude == location.latitude && loc.longitude == location.longitude);
    history.insert(0, location);
    if (history.length > 15) {
      history.removeRange(15, history.length);
    }
    final prefs = await _prefs;
    final rawList = history.map((loc) => loc.toJsonString()).toList();
    await prefs.setStringList(_keyHistory, rawList);
  }

  /// Menghapus satu item riwayat
  Future<void> removeSearchHistory(LocationModel location) async {
    final history = await getSearchHistory();
    history.removeWhere((loc) =>
        loc.latitude == location.latitude && loc.longitude == location.longitude);
    final prefs = await _prefs;
    final rawList = history.map((loc) => loc.toJsonString()).toList();
    await prefs.setStringList(_keyHistory, rawList);
  }

  /// Menghapus semua riwayat pencarian
  Future<void> clearSearchHistory() async {
    final prefs = await _prefs;
    await prefs.remove(_keyHistory);
  }

  /// Menyimpan lokasi terakhir yang sedang dibuka pengguna
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastLocation, location.toJsonString());
  }

  /// Mengambil lokasi terakhir yang disimpan
  Future<LocationModel?> getLastLocation() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyLastLocation);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LocationModel.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }
}
