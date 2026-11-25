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

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, WeatherViewModel vm) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      vm.searchLocations(query);
      if (query.trim().isNotEmpty && _tabController.index != 0) {
        _tabController.animateTo(0);
      }
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cari Lokasi'),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF2563EB),
              indicatorWeight: 3,
              tabs: [
                Tab(
                  icon: const Icon(Icons.search, size: 20),
                  text: 'Hasil (${vm.searchResults.length})',
                ),
                Tab(
                  icon: const Icon(Icons.star_rounded, size: 20),
                  text: 'Favorit (${vm.favorites.length})',
                ),
                Tab(
                  icon: const Icon(Icons.history_rounded, size: 20),
                  text: 'Riwayat (${vm.history.length})',
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search Input Box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Ketik nama kota (misal: Bandung, Tokyo)...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF64748B)),
                            onPressed: () {
                              _searchController.clear();
                              vm.clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    setState(() {});
                    _onSearchChanged(val, vm);
                  },
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Hasil Pencarian
                    _buildSearchResultsTab(context, vm),
                    // Tab 2: Lokasi Favorit
                    _buildFavoritesTab(context, vm),
                    // Tab 3: Riwayat Pencarian
                    _buildHistoryTab(context, vm),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tab 1: Tampilan Hasil Pencarian
  Widget _buildSearchResultsTab(BuildContext context, WeatherViewModel vm) {
    if (vm.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 12),
            Text(
              'Mencari lokasi di Open-Meteo...',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (vm.searchStatus == SearchStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              const Text(
                'Gagal Mencari Lokasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                vm.searchErrorMessage ?? 'Terjadi kesalahan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.searchStatus == SearchStatus.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 54, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              'Kota "${vm.lastSearchQuery}" tidak ditemukan',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba gunakan ejaan lain atau nama kota terdekat',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (vm.searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore_rounded, size: 56, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'Cari kota untuk melihat perkiraan cuaca',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.searchResults.length,
      separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final loc = vm.searchResults[index];
        final isFav = vm.isFavorite(loc);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_city, color: Color(0xFF2563EB)),
          ),
          title: Text(
            loc.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            loc.displayName,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFav ? Colors.amber : const Color(0xFF94A3B8),
              size: 26,
            ),
            onPressed: () {
              vm.toggleFavorite(loc);
            },
          ),
          onTap: () => _selectLocation(context, vm, loc),
        );
      },
    );
  }

  /// Tab 2: Tampilan Daftar Lokasi Favorit
  Widget _buildFavoritesTab(BuildContext context, WeatherViewModel vm) {
    if (vm.favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline_rounded, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'Belum ada lokasi favorit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tekan ikon bintang pada hasil pencarian atau halaman utama',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.favorites.length,
      separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (context, index) {
        final loc = vm.favorites[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star_rounded, color: Colors.amber),
          ),
          title: Text(
            loc.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            loc.displayName,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: 'Hapus dari favorit',
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: () {
              vm.toggleFavorite(loc);
            },
          ),
          onTap: () => _selectLocation(context, vm, loc),
        );
      },
    );
  }

  /// Tab 3: Tampilan Riwayat Pencarian
  Widget _buildHistoryTab(BuildContext context, WeatherViewModel vm) {
    if (vm.history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 56, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'Belum ada riwayat pencarian',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Kota yang pernah Anda pilih akan tersimpan otomatis di sini',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terakhir Dicari (${vm.history.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              TextButton(
                onPressed: () => vm.clearAllHistory(),
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.history.length,
            separatorBuilder: (_, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final loc = vm.history[index];
              final isFav = vm.isFavorite(loc);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history, color: Color(0xFF64748B)),
                ),
                title: Text(
                  loc.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  loc.displayName,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFav ? Colors.amber : const Color(0xFF94A3B8),
                        size: 24,
                      ),
                      onPressed: () {
                        vm.toggleFavorite(loc);
                      },
                    ),
                    IconButton(
                      tooltip: 'Hapus dari riwayat',
                      icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        vm.removeHistory(loc);
                      },
                    ),
                  ],
                ),
                onTap: () => _selectLocation(context, vm, loc),
              );
            },
          ),
        ),
      ],
    );
  }
}
