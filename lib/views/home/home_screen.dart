import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_helper.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../../widgets/cute_weather_art.dart';
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
          backgroundColor: const Color(0xFFFBFBFD),
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF0284C7),
              onRefresh: () async {
                await vm.refreshWeather();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Bar
                    _buildTopHeader(context, vm, location, isFav),

                    const SizedBox(height: 16),

                    // Content Body based on ViewModel Status
                    if (vm.isLoadingWeather)
                      _buildLoadingState()
                    else if (vm.isWeatherError)
                      _buildErrorState(vm)
                    else if (vm.weatherData != null)
                      _buildWeatherContent(vm.weatherData!)
                    else
                      _buildEmptyState(),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header Atas (Pill Naelora, Lokasi, Tanggal, dan Tombol Bulat)
  Widget _buildTopHeader(
    BuildContext context,
    WeatherViewModel vm,
    dynamic location,
    bool isFav,
  ) {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Brand badge, Location pill, Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Naelora Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, size: 14, color: Color(0xFFBE185D)),
                    SizedBox(width: 5),
                    Text(
                      'Naelora',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF831843),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Location Selector Pill
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          location?.name ?? 'Purwokerto',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Tanggal
              Text(
                dateString,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),

        // Right Actions: Favorite Button & Search Button
        Row(
          children: [
            // Tombol Favorit Kuning
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                icon: Icon(
                  Icons.star_rounded,
                  color: isFav ? const Color(0xFFB45309) : const Color(0xFFD97706),
                  size: 24,
                ),
                onPressed: () {
                  if (location != null) {
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
                  }
                },
              ),
            ),
            const SizedBox(width: 10),

            // Tombol Search Bulat Putih
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Cari Kota',
                icon: const Icon(Icons.search, color: Color(0xFF0F172A), size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Konten Cuaca Lengkap saat sukses memuat data
  Widget _buildWeatherContent(WeatherData weather) {
    final current = weather.current;
    final weatherDesc = WeatherHelper.getWeatherDescription(current.weatherCode);

    // Peluang hujan hari ini dari data daily
    final todayPrecipProb =
        weather.daily.isNotEmpty ? weather.daily.first.precipitationProbabilityMax : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Weather Card (Pastel Gradient)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFC7E9FB), // Soft Sky Blue
                Color(0xFFE2D9FC), // Soft Lavender
                Color(0xFFFCE7F3), // Soft Pink
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE2D9FC).withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cute Kawaii Weather Art
              CuteWeatherArt(
                weatherCode: current.weatherCode,
                size: 105,
              ),
              const SizedBox(height: 8),

              // Large Temperature
              Text(
                '${current.temperature.round()}°',
                style: const TextStyle(
                  fontSize: 66,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),

              // Weather Description
              Text(
                weatherDesc,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),

              // Apparent Temperature Pill (Terasa seperti ...)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.thermostat, size: 16, color: Color(0xFF475569)),
                    const SizedBox(width: 6),
                    Text(
                      'Terasa seperti ${current.apparentTemperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Section Title: Detail Cuaca
        const Text(
          'Detail Cuaca',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Grid 2x2 Metrik Cuaca (Kelembapan, Kecepatan Angin, Peluang Hujan, Curah Hujan)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
          children: [
            MetricCard(
              icon: Icons.water_drop_rounded,
              label: 'Kelembapan',
              value: '${current.relativeHumidity}%',
              iconColor: const Color(0xFF0284C7),
              iconBgColor: const Color(0xFFE0F2FE),
            ),
            MetricCard(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${current.windSpeed} km/j',
              iconColor: const Color(0xFF9333EA),
              iconBgColor: const Color(0xFFF3E8FF),
            ),
            MetricCard(
              icon: Icons.umbrella_rounded,
              label: 'Peluang Hujan',
              value: '$todayPrecipProb%',
              iconColor: const Color(0xFFDB2777),
              iconBgColor: const Color(0xFFFCE7F3),
            ),
            MetricCard(
              icon: Icons.grain_rounded,
              label: 'Curah Hujan',
              value: '${current.precipitation} mm',
              iconColor: const Color(0xFFCA8A04),
              iconBgColor: const Color(0xFFFEF9C3),
            ),
          ],
        ),

        const SizedBox(height: 26),

        // 4. Section Title: Perkiraan Cuaca Harian
        const Text(
          'Perkiraan Cuaca Harian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // 5. List Daily Forecast Item
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weather.daily.length,
          itemBuilder: (context, index) {
            final item = weather.daily[index];
            return DailyForecastItem(
              forecast: item,
              index: index,
              isToday: index == 0,
            );
          },
        ),
      ],
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
            color: Color(0xFF0284C7),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Mengambil data cuaca...',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
      margin: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 54,
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
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => vm.refreshWeather(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
        'Belum ada data cuaca. Silakan pilih lokasi.',
        style: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }
}
