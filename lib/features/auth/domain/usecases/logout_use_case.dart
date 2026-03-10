import 'package:get/get.dart';

import '../../../../core/session/session_cleanup_service.dart';
import '../repositories/auth_repository.dart';

/// Çıkışı tek merkezden yöneten use case.
class LogoutUseCase {
  LogoutUseCase(this._repository, this._cleanupService);

  final AuthRepository _repository;
  final SessionCleanupService _cleanupService;

  factory LogoutUseCase.createDefault() {
    throw UnimplementedError('Use AuthController or construct with dependencies.');
  }

  Future<void> execute({required String redirectRoute}) async {
    await _repository.signOut();
    await _repository.clearGuideSession();
    await _cleanupService.clearActiveSession();
    Get.offAllNamed(redirectRoute);
  }
}
