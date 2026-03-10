import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/session/session_cleanup_service.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/logout_use_case.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_use_case.dart';

class ProfileController extends GetxController {
  ProfileController({GetProfileUseCase? getProfileUseCase})
    : _getProfileUseCase = getProfileUseCase ?? GetProfileUseCase(ProfileRepositoryImpl());

  final GetProfileUseCase _getProfileUseCase;
  final LogoutUseCase _logoutUseCase = LogoutUseCase(AuthRepositoryImpl(), SessionCleanupService());

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool notificationsEnabled = true.obs;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  bool get isGoogleOnlyUser {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;
    final isGoogle = currentUser.providerData.any(
      (provider) => provider.providerId == 'google.com',
    );
    final hasPassword = currentUser.providerData.any(
      (provider) => provider.providerId == 'password',
    );
    return isGoogle && !hasPassword;
  }

  bool get isSyntheticUser {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return email.endsWith('@guide.turassist') || email.endsWith('@customer.turassist');
  }

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    user.value = isLoggedIn ? await _getProfileUseCase.execute() : null;
    isLoading.value = false;
  }

  String getInitials() {
    final name = user.value?.fullName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  Future<void> logout() {
    user.value = null;
    return _logoutUseCase.execute(redirectRoute: AppRoutes.tourList);
  }
}
