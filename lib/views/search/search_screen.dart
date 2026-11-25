import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherViewModel vm) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      vm.searchLocations(query);
    });
  }

  void _selectLocation(BuildContext context, WeatherViewModel vm, LocationModel location) {
    vm.selectLocation(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, child) {
        final hasQuery = _searchController.text.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFFBFBFD),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            title: const Text(
              'Cari Kota & Favorit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Cari nama kota (misal: Purwokerto, Jakarta)...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Color(0xFF475569)),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                vm.clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      _onSearchChanged(val, vm);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Section: Lokasi Favorit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lokasi Favorit',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${vm.favorites.length} tersimpan',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List Kartu Favorit (Pastel Cards)
                if (vm.favorites.isEmpty)
                  _buildEmptyFavoritesNotice()
                else
                  ...List.generate(vm.favorites.length, (index) {
                    final fav = vm.favorites[index];
                    return _buildFavoriteCard(context, vm, fav, index);
                  }),

                const SizedBox(height: 24),

                // 3. Section: Hasil Pencarian / Rekomendasi Populer
                const Text(
                  'Hasil Pencarian',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                // Info Banner jika query masih kosong
                if (!hasQuery)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF3E8FF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            size: 18,
                            color: Color(0xFF7E22CE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Ketik nama kota di kolom atas untuk mencari cuaca terbaru, atau pilih dari kota populer di bawah ini.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B21A8),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Status Pencarian atau Rekomendasi
                if (hasQuery && vm.isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                    ),
                  )
                else if (hasQuery && vm.searchStatus == SearchStatus.empty)
                  _buildNoResultsFound(vm.lastSearchQuery)
                else if (hasQuery && vm.searchResults.isNotEmpty)
                  // Hasil dari Open-Meteo Geocoding
                  ...vm.searchResults.map((loc) => _buildCityItemCard(context, vm, loc))
                else
                  // Rekomendasi Kota Populer
                  ...WeatherViewModel.popularCities
                      .map((loc) => _buildCityItemCard(context, vm, loc)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Kartu Lokasi Favorit Pastel (seperti Purwokerto biru, Kebumen pink di gambar)
  Widget _buildFavoriteCard(
    BuildContext context,
    WeatherViewModel vm,
    LocationModel location,
    int index,
  ) {
    final isBlue = index % 2 == 0;
    final bgColor = isBlue ? const Color(0xFFE0F2FE) : const Color(0xFFFCE7F3);
    final borderColor = isBlue ? const Color(0xFFBAE6FD) : const Color(0xFFFBCFE8);
    final temp = vm.favoriteTemps['${location.latitude}_${location.longitude}'];
    final tempString = temp != null ? '${temp.round()}°' : '27°';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: InkWell(
        onTap: () => _selectLocation(context, vm, location),
        child: Row(
          children: [
            // Nama Kota & Wilayah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Mini Weather Pill (Putih)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isBlue ? Icons.grain_rounded : Icons.wb_sunny_rounded,
                    size: 15,
                    color: isBlue ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tempString,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Tombol Bintang Kuning Favorit
            GestureDetector(
              onTap: () => vm.toggleFavorite(location),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF08A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFB45309),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu Item Kota (Hasil Pencarian / Populer)
  Widget _buildCityItemCard(
    BuildContext context,
    WeatherViewModel vm,
    LocationModel location,
  ) {
    final isFav = vm.isFavorite(location);

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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nama Kota & Wilayah
          Expanded(
            child: InkWell(
              onTap: () => _selectLocation(context, vm, location),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.displayName,
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
          ),

          // Tombol Bintang Favorit Bulat Abu/Kuning
          GestureDetector(
            onTap: () => vm.toggleFavorite(location),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isFav ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? const Color(0xFFB45309) : const Color(0xFF64748B),
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol Panah Biru Bulat untuk Pilih Lokasi
          GestureDetector(
            onTap: () => _selectLocation(context, vm, location),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF0284C7),
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Text(
        'Belum ada lokasi favorit tersimpan.',
        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }

  Widget _buildNoResultsFound(String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              'Kota "$query" tidak ditemukan',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
