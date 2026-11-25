import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/weather_api_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const NaeloraApp());
}

class NaeloraApp extends StatelessWidget {
  const NaeloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            apiService: WeatherApiService(),
            storageService: StorageService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Naelora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
