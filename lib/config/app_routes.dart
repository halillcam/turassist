import 'package:get/get.dart';

import '../features/announcements/presentation/screens/customer_announcements_screen.dart';
import '../features/announcements/presentation/screens/guide_announcements_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/guide_login_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/chat/presentation/screens/customer_chat_screen.dart';
import '../features/chat/presentation/screens/guide_chat_screen.dart';
import '../features/city_choice/presentation/screens/city_choice_screen.dart';
import '../features/guide/presentation/screens/guide_dashboard_screen.dart';
import '../features/guide/presentation/screens/guide_participants_screen.dart';
import '../features/guide/presentation/screens/guide_qr_scanner_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/qr/presentation/screens/my_qr_screen.dart';
import '../features/tours/presentation/screens/my_tours_screen.dart';
import '../features/tours/presentation/screens/tour_detail_screen.dart';
import '../features/tours/presentation/screens/tour_list_screen.dart';
import '../core/models/tour_model.dart';

/// Uygulama içi rota sabitleri.
abstract class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String guideLogin = '/guide-login';
  static const String citySelection = '/city-selection';
  static const String guideDashboard = '/guide-dashboard';
  static const String tourList = '/tour-list';
  static const String tourDetail = '/tour-detail';
  static const String myTours = '/my-tours';
  static const String myQrs = '/my-qrs';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String tourAnnouncements = '/tour-announcements';
  static const String tourManagerHome = '/tour-manager-home';
  static const String tourManagerAnnouncements = '/tour-manager-announcements';
  static const String qrScanner = '/qr-scanner';
  static const String tourManagerChat = '/tour-manager-chat';
  static const String tourManagerCustomers = '/tour-manager-customers';
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
      page: () => const ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.guideLogin,
      page: () => const GuideLoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.citySelection,
      page: () => const CityChoiceScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.guideDashboard,
      page: () => const GuideDashboardScreen(),
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
      page: () {
        final args = Get.arguments;
        final list = args is List ? List<TourModel>.from(args) : [args as TourModel];
        return TourDetailScreen(toursInSeries: list);
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tourManagerHome,
      page: () => const GuideDashboardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.tourManagerAnnouncements,
      page: () => const GuideAnnouncementsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.qrScanner,
      page: () => const GuideQrScannerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.tourManagerChat,
      page: () => const GuideChatScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tourManagerCustomers,
      page: () => const GuideParticipantsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const CustomerChatScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tourAnnouncements,
      page: () => const CustomerAnnouncementsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
