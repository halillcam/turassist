import 'package:get/get.dart';

import '../services/local_notification_service.dart';

/// Çıkış sırasında kullanıcı oturumuna bağlı canlı state'i temizler.
class SessionCleanupService {
  Future<void> clearActiveSession() async {
    await LocalNotificationService.instance.clearUserSession();
    Get.closeAllSnackbars();
    Get.deleteAll(force: true);
  }
}
