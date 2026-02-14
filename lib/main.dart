import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null);

  // Şehir seçimi yapılmış mı kontrol et
  final prefs = await SharedPreferences.getInstance();
  final savedCity = prefs.getString('selected_city');
  final hasCity = savedCity != null && savedCity.isNotEmpty;

  runApp(TurAssistApp(initialRoute: hasCity ? AppRoutes.tourList : AppRoutes.citySelection));
}

class TurAssistApp extends StatelessWidget {
  final String initialRoute;

  const TurAssistApp({super.key, this.initialRoute = '/city-selection'});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TurAssist',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
    );
  }
}
