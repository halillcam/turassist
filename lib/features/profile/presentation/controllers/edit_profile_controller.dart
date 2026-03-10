import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/update_profile_use_case.dart';

class EditProfileController extends GetxController {
  EditProfileController({UpdateProfileUseCase? updateProfileUseCase})
    : _updateProfileUseCase = updateProfileUseCase ?? UpdateProfileUseCase(ProfileRepositoryImpl());

  final UpdateProfileUseCase _updateProfileUseCase;
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, String>?;
    if (args != null) {
      fullNameController.text = args['fullName'] ?? '';
      emailController.text = args['email'] ?? '';
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> updateProfile() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    if (fullName.isEmpty || email.isEmpty) {
      throw Exception('Ad Soyad ve E-posta alanları boş bırakılamaz');
    }
    if (!GetUtils.isEmail(email)) {
      throw Exception('Geçerli bir e-posta adresi giriniz');
    }

    isLoading.value = true;
    try {
      await _updateProfileUseCase.execute(fullName: fullName, email: email);
      Get.back(result: true);
    } finally {
      isLoading.value = false;
    }
  }
}
