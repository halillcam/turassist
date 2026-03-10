import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/change_password_use_case.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController({ChangePasswordUseCase? changePasswordUseCase})
    : _changePasswordUseCase =
          changePasswordUseCase ?? ChangePasswordUseCase(ProfileRepositoryImpl());

  final ChangePasswordUseCase _changePasswordUseCase;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool showCurrentPassword = false.obs;
  final RxBool showNewPassword = false.obs;
  final RxBool showConfirmPassword = false.obs;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      throw Exception('Tüm alanları doldurunuz');
    }
    if (newPassword.length < 6) {
      throw Exception('Yeni şifre en az 6 karakter olmalıdır');
    }
    if (newPassword != confirmPassword) {
      throw Exception('Yeni şifreler eşleşmiyor');
    }
    if (currentPassword == newPassword) {
      throw Exception('Yeni şifre mevcut şifre ile aynı olamaz');
    }

    isLoading.value = true;
    try {
      await _changePasswordUseCase.execute(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      Get.offAllNamed(AppRoutes.profile);
    } finally {
      isLoading.value = false;
    }
  }
}
