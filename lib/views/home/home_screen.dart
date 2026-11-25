import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_helper.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/daily_forecast_item.dart';
import '../../widgets/metric_card.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, child) {
        final location = vm.currentLocation;
        final isFav = location != null && vm.isFavorite(location);

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await vm.refreshWeather();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Custom AppBar
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 22),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            location?.name ?? 'Naelora Weather',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      // Tombol Toggle Favorit
                      if (location != null)
                        IconButton(
                          tooltip: isFav ? 'Hapus dari favorit' : 'Simpan sebagai favorit',
                          icon: Icon(
                            isFav ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isFav ? Colors.amber : const Color(0xFF64748B),
                            size: 28,
                          ),
                          onPressed: () {
                            vm.toggleFavorite(location);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFav
                                      ? '${location.name} dihapus dari favorit'
                                      : '${location.name} disimpan ke favorit',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      // Tombol Search
                      IconButton(
                        tooltip: 'Cari Kota',
                        icon: const Icon(Icons.search_rounded, color: Color(0xFF0F172A)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SearchScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // Content Body berdasarkan Status
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris Kota Favorit Cepat (Quick Access)
                          if (vm.favorites.isNotEmpty) _buildFavoritesBar(context, vm),

                          // Status Tampilan
                          if (vm.isLoadingWeather)
                            _buildLoadingState()
                          else if (vm.isWeatherError)
                            _buildErrorState(vm)
                          else if (vm.weatherData != null)
                            _buildWeatherContent(vm.weatherData!)
                          else
                            _buildEmptyState(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Baris chip akses cepat kota favorit
  Widget _buildFavoritesBar(BuildContext context, WeatherViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vm.favorites.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final fav = vm.favorites[index];
          final isSelected = vm.currentLocation?.latitude == fav.latitude &&
              vm.currentLocation?.longitude == fav.longitude;

          return FilterChip(
            selected: isSelected,
            label: Text(fav.name),
            avatar: const Icon(Icons.star, size: 14, color: Colors.amber),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : const Color(0xFF334155),
            ),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              ),
            ),
            onSelected: (_) {
              if (!isSelected) {
                vm.selectLocation(fav);
              }
            },
          );
        },
      ),
    );
  }

  /// Tampilan Loading Indikator
  Widget _buildLoadingState() {
    return Container(
      height: 380,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2563EB),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Mengambil data cuaca...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan Error ketika API gagal
  Widget _buildErrorState(WeatherViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 56,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal Memuat Cuaca',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.weatherErrorMessage ?? 'Terjadi kendala saat menghubungi server Open-Meteo.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => vm.refreshWeather(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan jika belum ada data sama sekali
  Widget _buildEmptyState() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: const Text(
        'Belum ada data cuaca. Silakan cari lokasi.',
        style: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }

  /// Konten Cuaca Lengkap saat sukses memuat data
  Widget _buildWeatherContent(WeatherData weather) {
    final current = weather.current;
    final weatherDesc = WeatherHelper.getWeatherDescription(current.weatherCode);
    final weatherIcon = WeatherHelper.getWeatherIcon(current.weatherCode);
    final gradientColors = WeatherHelper.getWeatherGradient(current.weatherCode);

    // Hari dan tanggal terkini
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(current.time);

    // Peluang hujan hari ini dari data daily
    final todayPrecipProb =
        weather.daily.isNotEmpty ? weather.daily.first.precipitationProbabilityMax : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tanggal
        Text(
          todayFormatted,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Hero Card Cuaca Terkini
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Suhu Saat Ini
                      Text(
                        '${current.temperature.round()}°',
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Deskripsi Kondisi Cuaca
                      Text(
                        weatherDesc,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // Ikon Cuaca
                  Icon(
                    weatherIcon,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Suhu yang dirasakan (apparent temperature)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.thermostat, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Terasa seperti ${current.apparentTemperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Section Title: Metrik Informasi Tambahan
        const Text(
          'Detail Cuaca',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Grid Metrik Cuaca (Kelembapan, Kecepatan Angin, Peluang Hujan, Curah Hujan)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            MetricCard(
              icon: Icons.water_drop_rounded,
              label: 'Kelembapan',
              value: '${current.relativeHumidity}%',
              iconColor: const Color(0xFF0284C7),
            ),
            MetricCard(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${current.windSpeed} km/j',
              iconColor: const Color(0xFF0D9488),
            ),
            MetricCard(
              icon: Icons.umbrella_rounded,
              label: 'Peluang Hujan',
              value: '$todayPrecipProb%',
              iconColor: const Color(0xFF6366F1),
            ),
            MetricCard(
              icon: Icons.grain_rounded,
              label: 'Curah Hujan',
              value: '${current.precipitation} mm',
              iconColor: const Color(0xFF3B82F6),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Section Title: Perkiraan Beberapa Hari ke Depan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Perkiraan Cuaca Harian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${weather.daily.length} Hari',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List Daily Forecast
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weather.daily.length,
          itemBuilder: (context, index) {
            final item = weather.daily[index];
            return DailyForecastItem(
              forecast: item,
              isToday: index == 0,
            );
          },
        ),
      ],
    );
  }
}
