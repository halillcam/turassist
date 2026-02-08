import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/city/city_choice_screen.dart';
import '../screens/tour/tour_list_screen.dart';
import '../screens/tour/tour_detail_screen.dart';
import '../screens/test/test_tour_screen.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String guideLogin = '/guide-login';
  static const String citySelection = '/city-selection';
  static const String guideDashboard = '/guide-dashboard';
  static const String tourList = '/tour-list';
  static const String tourDetail = '/tour-detail';
  static const String testTour = '/test-tour'; // 🧪 Test - sonra silinecek
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
      name: AppRoutes.tourDetail,
      page: () => TourDetailScreen(tour: Get.arguments),
      transition: Transition.rightToLeft,
    ),
    // 🧪 Test route - sonra silinecek
    GetPage(
      name: AppRoutes.testTour,
      page: () => const TestTourScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
