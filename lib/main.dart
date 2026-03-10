import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'firebase_options.dart';
import 'services/local_notification_service.dart';

bool get _supportsFirebaseMessaging {
  if (kIsWeb) return true;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (_supportsFirebaseMessaging) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await initializeDateFormatting('tr_TR', null);
  await LocalNotificationService.instance.initialize();

  // Şehir seçimi yapılmış mı kontrol et
  final prefs = await SharedPreferences.getInstance();
  final savedCity = prefs.getString('selected_city');
  final hasCity = savedCity != null && savedCity.isNotEmpty;
  final isGuideSession = prefs.getBool('is_guide_session') ?? false;
  final guideId = prefs.getString('guide_id') ?? '';

  final initialRoute = (isGuideSession && guideId.isNotEmpty)
      ? AppRoutes.guideDashboard
      : (hasCity ? AppRoutes.tourList : AppRoutes.citySelection);

  runApp(TurAssistApp(initialRoute: initialRoute));
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
