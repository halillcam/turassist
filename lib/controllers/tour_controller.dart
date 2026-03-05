import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/tour_model.dart';
import '../services/firebase_service.dart';

/// Tur listesi ve tur detaylarını yöneten controller.
///
/// Sorumlulukları:
/// - Şehre göre tur listeleme ve filtreleme
/// - Seri bazlı tur gruplama (aynı turun farklı tarihleri)
/// - Bölge bazlı gruplama (UI sırasıyla)
/// - Tur güncelleme ve bitirme
class TourController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  /// Tüm aktif turları tutan reaktif liste.
  var tours = <TourModel>[].obs;
  var isLoading = true.obs;

  /// Seçili çıkış şehri.
  var selectedCity = ''.obs;

  // Bölge sıralaması (sabit)
  static const List<String> regionOrder = [
    'Marmara',
    'Ege',
    'Akdeniz',
    'Karadeniz',
    'İç Anadolu',
    'Doğu Anadolu',
    'Güneydoğu Anadolu',
    'Günü Birlik',
    'Yurtdışı',
  ];

  // İlk açılışta otomatik fetch yapılmaz;
  // şehir seçildiğinde [filterByCity] çağrılır.

  /// Silinmemiş tüm aktif turları getirir.
  void fetchTours() async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getActiveTours();
      tours.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// Şehre göre turları Firestore'dan getirir ve [tours]'u günceller.
  void filterByCity(String city) async {
    try {
      isLoading.value = true;
      selectedCity.value = city;
      var result = await _firebaseService.getToursByCity(city);
      tours.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  /// seriesId'ye göre grupla; her seri için ilk turu "display" olarak kullan.
  /// UI'da tek kart göstermek için.
  List<TourModel> get displayTours {
    final bySeries = <String, List<TourModel>>{};
    for (final tour in tours) {
      final key = tour.seriesId ?? tour.id;
      bySeries.putIfAbsent(key, () => []).add(tour);
    }
    return bySeries.values.map((list) {
      list.sort((a, b) {
        final ad = a.departureDate;
        final bd = b.departureDate;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      });
      return list.first;
    }).toList();
  }

  /// Verilen display tour'a ait serideki tüm turları döner.
  List<TourModel> getToursInSeries(TourModel displayTour) {
    if (displayTour.seriesId == null) return [displayTour];
    return tours.where((t) => t.seriesId == displayTour.seriesId).toList()..sort((a, b) {
      final ad = a.departureDate;
      final bd = b.departureDate;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
  }

  // Turları region'a göre grupla (sıralı) - displayTours kullanır
  Map<String, List<TourModel>> get toursByRegion {
    final grouped = <String, List<TourModel>>{};
    for (var tour in displayTours) {
      final region = tour.region.isEmpty ? 'Diğer' : tour.region;
      if (!grouped.containsKey(region)) grouped[region] = [];
      grouped[region]!.add(tour);
    }
    final sorted = <String, List<TourModel>>{};
    for (var region in regionOrder) {
      if (grouped.containsKey(region)) sorted[region] = grouped.remove(region)!;
    }
    sorted.addAll(grouped);
    return sorted;
  }

  /// Tur detayını ID ile getirir.
  Future<TourModel?> getTourDetail(String tourId) async {
    try {
      isLoading.value = true;
      var result = await _firebaseService.getTourById(tourId);
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Tur katılımcılarını getirir.
  Future<List<dynamic>> getTourParticipants(String tourId) async {
    try {
      var result = await _firebaseService.getTourParticipants(tourId);
      return result;
    } catch (e) {
      debugPrint('Katılımcıları yüklerken hata: $e');
      return [];
    }
  }

  /// Turu bitirme talebi gönderir.
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      isLoading.value = true;
      await _firebaseService.finishTour(tourId, guideId);
    } catch (e) {
      debugPrint('Turu bitirirken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Turu Firestore'da günceller ve lokal listeyi senkronize eder.
  Future<void> updateTour(String tourId, TourModel updatedTour) async {
    try {
      isLoading.value = true;
      await _firebaseService.updateTour(tourId, updatedTour);
      // Lokaldeki listeyi de güncelle
      final index = tours.indexWhere((t) => t.id == tourId);
      if (index != -1) {
        tours[index] = updatedTour;
      }
    } catch (e) {
      debugPrint('Turu güncellerken hata: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
