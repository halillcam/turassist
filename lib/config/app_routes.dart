import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/city/city_choice_screen.dart';
import '../screens/my_tours/my_tours_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qr/my_qr_screen.dart';
import '../screens/qr/qr_scanner_screen.dart';
import '../screens/test/test_tour_screen.dart';
import '../screens/tour/tour_detail_screen.dart';
import '../screens/tour/tour_list_screen.dart';
import '../screens/tour_manager/tour_manager_announcements_screen.dart';
import '../screens/tour_manager/tour_manager_chat_screen.dart';
import '../screens/tour_manager/tour_manager_customers_screen.dart';
import '../screens/tour_manager/tour_manager_home_screen.dart';

/// Uygulama içi rota sabitleri.
abstract class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String guideLogin = '/guide-login';
  static const String citySelection = '/city-selection';
  static const String guideDashboard = '/guide-dashboard';
  static const String tourList = '/tour-list';
  static const String tourDetail = '/tour-detail';
  static const String myTours = '/my-tours';
  static const String myQrs = '/my-qrs';
  static const String profile = '/profile';
  static const String tourManagerHome = '/tour-manager-home';
  static const String tourManagerAnnouncements = '/tour-manager-announcements';
  static const String qrScanner = '/qr-scanner';
  static const String tourManagerChat = '/tour-manager-chat';
  static const String tourManagerCustomers = '/tour-manager-customers';
  static const String testTour = '/test-tour';
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), transition: Transition.fadeIn),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => Scaffold(body: Center(child: Text('Forgot Password Screen - Todo'))),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.guideLogin,
      page: () => Scaffold(body: Center(child: Text('Guide Login Screen - Todo'))),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.citySelection,
      page: () => const CityChoiceScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.guideDashboard,
      page: () => Scaffold(body: Center(child: Text('Guide Dashboard Screen - Todo'))),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.tourList,
      page: () => const TourListScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.myTours,
      page: () => const MyToursScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: AppRoutes.myQrs, page: () => const MyQrScreen(), transition: Transition.fadeIn),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.tourDetail,
      page: () => TourDetailScreen(tour: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tourManagerHome,
      page: () => const TourManagerHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.tourManagerAnnouncements,
      page: () => const TourManagerAnnouncementsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.tourManagerChat,
      page: () => const TourManagerChatScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tourManagerCustomers,
      page: () => const TourManagerCustomersScreen(),
      transition: Transition.rightToLeft,
    ),
    // Test
    GetPage(
      name: AppRoutes.testTour,
      page: () => const TestTourScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
