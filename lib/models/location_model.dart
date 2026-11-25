import 'dart:convert';

class LocationModel {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // Provinsi / State
  final String? countryCode;

  LocationModel({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.countryCode,
  });

  String get displayName {
    final parts = [name];
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      parts.add(admin1!);
    }
    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'country_code': countryCode,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory LocationModel.fromJsonString(String source) =>
      LocationModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          (id != null && other.id != null
              ? id == other.id
              : (name == other.name &&
                  latitude == other.latitude &&
                  longitude == other.longitude));

  @override
  int get hashCode => id?.hashCode ?? Object.hash(name, latitude, longitude);
}
