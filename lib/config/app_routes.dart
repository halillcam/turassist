import 'package:get/get.dart';
import 'package:turassist/screens/city_selection_screen.dart';
import 'package:turassist/screens/tour_list_screen.dart';
import 'package:turassist/screens/tour_detail_screen.dart';
import 'package:turassist/screens/profile_screen.dart';
import 'package:turassist/screens/tour_chat_screen.dart';
import 'package:turassist/screens/guide_login_screen.dart';
import 'package:turassist/screens/guide_dashboard_screen.dart';
import 'package:turassist/screens/qr_scanner_screen.dart';
import 'package:turassist/screens/login_screen.dart';
import 'package:turassist/screens/register_screen.dart';
import 'package:turassist/screens/forgot_password_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String home = '/home';
  static const String citySelection = '/city_selection';
  static const String tourList = '/tour_list';
  static const String tourDetail = '/tour_detail';
  static const String profile = '/profile';
  static const String tourChat = '/tour_chat';
  static const String guideLogin = '/guide_login';
  static const String guideDashboard = '/guide_dashboard';
  static const String qrScanner = '/qr_scanner';

  static final routes = [
    GetPage(name: citySelection, page: () => CitySelectionScreen()),
    GetPage(name: tourList, page: () => TourListScreen()),
    GetPage(name: tourDetail, page: () => const TourDetailScreen()),
    GetPage(name: tourChat, page: () => const TourChatScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: guideLogin, page: () => const GuideLoginScreen()),
    GetPage(name: guideDashboard, page: () => const GuideDashboardScreen()),
    GetPage(name: qrScanner, page: () => const QRScannerScreen()),
  ];
}
