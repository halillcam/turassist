import 'package:get/get.dart';

/// NOT: Tur Sorumlusu ID/PW oluşturma Web Admin Panel'de yapılır (ayrı proje)
/// Mobile App'te Tur Sorumlusu sadece giriş yapar - LoginController.guideLogin()
///
/// Web Admin Panel'de:
/// - Şirket Admin'i ilgili tur için tur sorumlusuna ID/PW oluşturur
/// - Tur sorumlusuna bu bilgileri iletir
///
/// Mobile App'te:
/// - Tur sorumlusu LoginController.guideLogin(guideId, password) ile giriş yapar
/// - App'in arayüzü değişir: /guide-dashboard açılır [cite: 18, 21]
class TourSetupController extends GetxController {
  // Web Admin Panel'de tur sorumlusu oluşturulur
  // Mobile app'te kullanılmaz
  // Bu controller ileride yapılar için placeholder'dır
}
