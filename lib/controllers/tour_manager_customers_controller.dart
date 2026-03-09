import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_service.dart';

/// Katılımcı verisi — ID'siz, ekran düzeyinde kullanılan basit model.
class ParticipantItem {
  final String name;
  final String subtitle;
  final bool arrived;

  const ParticipantItem({required this.name, required this.subtitle, required this.arrived});
}

/// Tur sorumlusu katılımcı listesi ekranının reaktif state yönetimi.
///
/// Yükleme durumu, tab seçimi ve katılımcı listesi burada tutulur.
/// Ekranda doğrudan [setState] kullanılmaz; bunun yerine
/// [Obx] ile reaktif bölümler dinlenir.
class TourManagerCustomersController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  /// Katılımcı yükleme durumu.
  final RxBool isLoading = true.obs;

  /// Aktif sekme: 0 = Tümü, 1 = Gelenler, 2 = Gelmeyenler.
  final RxInt selectedTab = 0.obs;

  /// Tüm katılımcılar (filtre uygulanmamış ham liste).
  final RxList<ParticipantItem> allParticipants = <ParticipantItem>[].obs;

  /// Anlık arama sorgusu — ekrandan [TextEditingController] dinlenerek güncellenir.
  final RxString searchQuery = ''.obs;

  String tourId = '';
  final RxString tourTitle = ''.obs;

  /// [selectedTab] ve [searchQuery]'ye göre filtrelenmiş katılımcı listesi.
  List<ParticipantItem> get filteredParticipants {
    var list = allParticipants.toList();
    if (selectedTab.value == 1) list = list.where((p) => p.arrived).toList();
    if (selectedTab.value == 2) list = list.where((p) => !p.arrived).toList();
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(q) || p.subtitle.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int get arrivedCount => allParticipants.where((p) => p.arrived).length;
  int get pendingCount => allParticipants.where((p) => !p.arrived).length;

  /// [tourId] ve [tourTitle] argümanlarını Set edip katılımcıları yükler.
  Future<void> init({required String tourId, required String tourTitle}) async {
    this.tourId = tourId;
    this.tourTitle.value = tourTitle;
    await loadParticipants();
  }

  /// Katılımcıları Firestore'dan yükler.
  ///
  /// tourId boşsa SharedPreferences'ten rehber ID'si alınarak atanmış tur bulunur.
  Future<void> loadParticipants() async {
    isLoading.value = true;

    if (tourId.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final isGuideSession = prefs.getBool('is_guide_session') ?? false;
      var guideId = (prefs.getString('guide_id') ?? '').trim();

      if (!isGuideSession || guideId.isEmpty) {
        guideId = FirebaseAuth.instance.currentUser?.uid ?? '';
      }

      if (guideId.isNotEmpty) {
        final assignedTour = await _firebaseService.getAssignedTourForGuide(guideId);
        if (assignedTour != null) {
          tourId = assignedTour.id;
          if (tourTitle.value.isEmpty) tourTitle.value = assignedTour.title;
        }
      }
    }

    if (tourId.isEmpty) {
      allParticipants.clear();
      isLoading.value = false;
      return;
    }

    final result = await _firebaseService.getTourParticipants(tourId);
    final parsed = result.map((item) {
      final status = item['status']?.toString().toLowerCase() ?? '';
      final scanned = item['isScanned'] == true;
      final arrived = scanned || status == 'checked_in';

      return ParticipantItem(
        name: item['passengerName']?.toString().trim().isNotEmpty == true
            ? item['passengerName'].toString()
            : 'İsimsiz Katılımcı',
        subtitle: item['tcNo']?.toString().trim().isNotEmpty == true
            ? 'TC: ${item['tcNo']}'
            : 'Kimlik bilgisi yok',
        arrived: arrived,
      );
    }).toList();

    allParticipants
      ..clear()
      ..addAll(parsed);
    isLoading.value = false;
  }
}
