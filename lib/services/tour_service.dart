import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/tour_model.dart';
import '../models/tour_program_model.dart';

/// Tur verilerini Firestore üzerinden yöneten servis.
///
/// Sorumlulukları:
/// - Aktif / şehre özel tur listeleme
/// - Tur detayı ve programı getirme
/// - Rehbere atanmış tur getirme
/// - Tur katılımcılarını listeleme (yolcu adı çözümleme dahil)
/// - Tur güncelleme ve bitirme talebi oluşturma
class TourService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== TUR LİSTELEME ====================

  /// Silinmemiş (isDeleted: false) tüm aktif turları getirir.
  Future<List<TourModel>> getActiveTours() async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.map(TourModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('TourService.getActiveTours Error: $e');
      return [];
    }
  }

  /// Belirtilen şehre ait silinmemiş turları getirir.
  Future<List<TourModel>> getToursByCity(String city) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('city', isEqualTo: city)
          .where('isDeleted', isEqualTo: false)
          .get();

      return snapshot.docs.map(TourModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('TourService.getToursByCity Error: $e');
      return [];
    }
  }

  /// Tüm şehir belgelerinden şehir isimlerini getirir.
  Future<List<String>> getAllCities() async {
    try {
      final snapshot = await _firestore.collection('cities').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint('TourService.getAllCities Error: $e');
      return [];
    }
  }

  // ==================== TUR DETAYI ====================

  /// Verilen ID'ye sahip tur belgesini getirir.
  ///
  /// Tur bulunamazsa [null] döner.
  Future<TourModel?> getTourById(String tourId) async {
    try {
      final doc = await _firestore.collection('tours').doc(tourId).get();
      if (doc.exists) return TourModel.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('TourService.getTourById Error: $e');
      return null;
    }
  }

  /// Rehbere (guideId) atanmış ve silinmemiş en son oluşturulan turu getirir.
  ///
  /// Birden fazla tur atanmışsa en son oluşturulan döner.
  /// Rehberin aktif turu yoksa [null] döner.
  Future<TourModel?> getAssignedTourForGuide(String guideId) async {
    try {
      if (guideId.trim().isEmpty) return null;

      final snapshot = await _firestore
          .collection('tours')
          .where('guideId', isEqualTo: guideId)
          .where('isDeleted', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final tours = snapshot.docs.map(TourModel.fromFirestore).toList();
      tours.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tours.first;
    } catch (e) {
      debugPrint('TourService.getAssignedTourForGuide Error: $e');
      return null;
    }
  }

  /// Tur programını 'order' alanına göre artan sırayla getirir.
  Future<List<TourProgramDay>> getTourProgram(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('program')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map(TourProgramDay.fromFirestore).toList();
    } catch (e) {
      debugPrint('TourService.getTourProgram Error: $e');
      return [];
    }
  }

  // ==================== TUR YÖNETİMİ ====================

  /// Turun Firestore belgesini günceller.
  Future<void> updateTour(String tourId, TourModel tour) async {
    try {
      await _firestore.collection('tours').doc(tourId).update(tour.toJson());
    } catch (e) {
      debugPrint('TourService.updateTour Error: $e');
    }
  }

  /// Tura ait iptal edilmemiş biletlerden katılımcı listesini oluşturur.
  ///
  /// Yolcu adı eksik olan biletler için Firestore'dan kullanıcı adı çözümlenir
  /// ve ilgili bilet belgesine geri yazılır.
  Future<List<Map<String, dynamic>>> getTourParticipants(String tourId) async {
    try {
      final snapshot = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .get();

      final participants = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final status = data['status']?.toString().toLowerCase() ?? '';
          if (status == 'cancelled') return null;

          final userId = data['userId']?.toString().trim() ?? '';
          final ticketName = data['passengerName']?.toString().trim() ?? '';
          final tcNo = data['tcNo']?.toString().trim() ?? '';

          String resolvedName = ticketName;

          // Bilet üzerinde isim yoksa kullanıcı profilinden çözümle
          if (resolvedName.isEmpty && userId.isNotEmpty) {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            final userData = userDoc.data();
            final profileName = userData?['fullName']?.toString().trim() ?? '';
            final email = userData?['email']?.toString().trim() ?? '';
            final emailName = email.contains('@') ? email.split('@').first.trim() : '';

            resolvedName = profileName.isNotEmpty
                ? profileName
                : (emailName.isNotEmpty ? emailName : resolvedName);

            // Çözümlenen ismi bilete geri yaz
            if (resolvedName.isNotEmpty) {
              await doc.reference.update({'passengerName': resolvedName});
            }
          }

          return {'id': doc.id, ...data, 'passengerName': resolvedName, 'tcNo': tcNo};
        }),
      );

      return participants.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('TourService.getTourParticipants Error: $e');
      return [];
    }
  }

  /// Tur bitirme talebini Firestore'a kaydeder; tüm QR token'larını geçersizleştirir.
  ///
  /// Tur durumu 'finish_requested' olarak işaretlenir.
  /// Admin / Web paneli bu talebi görerek turu kapatır.
  Future<void> finishTour(String tourId, String guideId) async {
    try {
      // Bitirme talebi oluştur
      await _firestore.collection('tours').doc(tourId).update({
        'status': 'finish_requested',
        'finishRequestedBy': guideId,
        'finishRequestedAt': FieldValue.serverTimestamp(),
      });

      // Bu turun tüm biletlerinin QR token'ını geçersizleştir
      final tickets = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .get();

      for (final doc in tickets.docs) {
        await doc.reference.update({'qrToken': null, 'isScanned': true});
      }
    } catch (e) {
      debugPrint('TourService.finishTour Error: $e');
    }
  }
}
