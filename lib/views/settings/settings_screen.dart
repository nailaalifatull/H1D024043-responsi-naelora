import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/weather_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTempUnit = 'Celsius (°C)';
  String _selectedWindUnit = 'Kilometer/jam (km/j)';
  bool _autoRefresh = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, child) {
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
              'Pengaturan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // 1. Bagian Preferensi Tampilan
              _buildSectionTitle('Preferensi Unit'),
              Container(
                decoration: _cardBoxDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: _buildSettingIcon(Icons.thermostat_rounded, const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
                      title: const Text('Satuan Suhu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(_selectedTempUnit, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                      onTap: () => _showTempUnitDialog(),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    ListTile(
                      leading: _buildSettingIcon(Icons.air_rounded, const Color(0xFF9333EA), const Color(0xFFF3E8FF)),
                      title: const Text('Satuan Angin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(_selectedWindUnit, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                      onTap: () => _showWindUnitDialog(),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    SwitchListTile(
                      secondary: _buildSettingIcon(Icons.autorenew_rounded, const Color(0xFF059669), const Color(0xFFD1FAE5)),
                      title: const Text('Auto Refresh Cuaca', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Perbarui saat aplikasi dibuka', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      value: _autoRefresh,
                      activeThumbColor: const Color(0xFF0284C7),
                      onChanged: (val) {
                        setState(() {
                          _autoRefresh = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Bagian Penyimpanan & Data
              _buildSectionTitle('Data & Penyimpanan Lokal'),
              Container(
                decoration: _cardBoxDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: _buildSettingIcon(Icons.history_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
                      title: const Text('Hapus Riwayat Pencarian', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text('${vm.history.length} riwayat tersimpan', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      onTap: () => _confirmClearHistory(context, vm),
                    ),
                    const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                    ListTile(
                      leading: _buildSettingIcon(Icons.refresh_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                      title: const Text('Sinkronisasi Cuaca', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('Muat ulang data dari Open-Meteo', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                      onTap: () async {
                        await vm.refreshWeather();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data cuaca berhasil diperbarui!'), duration: Duration(seconds: 1)),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Bagian Tentang Aplikasi
              _buildSectionTitle('Tentang Aplikasi'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardBoxDecoration(),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFC7E9FB), Color(0xFFFCE7F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cloud_rounded, size: 36, color: Color(0xFF0284C7)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Naelora Weather',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Versi 1.0.0 (Responsi Flutter)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 12),
                    _buildInfoRow('Arsitektur', 'MVVM (Model-View-ViewModel)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Penyedia API', 'Open-Meteo REST API (Free)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Penyimpanan', 'Local SharedPreferences'),
                    const SizedBox(height: 8),
                    _buildInfoRow('State Management', 'Provider (ChangeNotifier)'),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  BoxDecoration _cardBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSettingIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      ],
    );
  }

  void _showTempUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Satuan Suhu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitOption('Celsius (°C)', _selectedTempUnit, (val) {
                setState(() => _selectedTempUnit = val);
                Navigator.pop(context);
              }),
              _buildUnitOption('Fahrenheit (°F)', _selectedTempUnit, (val) {
                setState(() => _selectedTempUnit = val);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  void _showWindUnitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Satuan Angin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitOption('Kilometer/jam (km/j)', _selectedWindUnit, (val) {
                setState(() => _selectedWindUnit = val);
                Navigator.pop(context);
              }),
              _buildUnitOption('Meter/detik (m/s)', _selectedWindUnit, (val) {
                setState(() => _selectedWindUnit = val);
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitOption(String value, String currentValue, ValueChanged<String> onSelected) {
    final isSelected = value == currentValue;
    return ListTile(
      title: Text(
        value,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0284C7))
          : const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFFCBD5E1)),
      onTap: () => onSelected(value),
    );
  }

  void _confirmClearHistory(BuildContext context, WeatherViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hapus Riwayat?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: const Text('Seluruh riwayat pencarian kota Anda akan dihapus dari penyimpanan lokal.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                vm.clearAllHistory();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat pencarian berhasil dibersihkan'), duration: Duration(seconds: 1)),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
