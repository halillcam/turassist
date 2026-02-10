import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tour_model.dart';

/// Test amaçlı tur verisi ekleme servisi.
/// Üretim ortamında kullanılmayacak, test sonrası silinecektir.
class TestTourService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore'a yeni bir tur ekler (POST).
  /// Başarılı olursa oluşturulan document ID'yi döner.
  /// Hata olursa exception fırlatır.
  Future<String> addTour(TourModel tour) async {
    try {
      final docRef = await _firestore.collection('tours').add(tour.toJson());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw TestTourException(message: 'Firebase hatası: ${e.message}', code: e.code);
    } catch (e) {
      throw TestTourException(message: 'Beklenmeyen hata: $e');
    }
  }

  /// Birden fazla tur ekler (Batch POST).
  /// Her biri için sonuç döner.
  Future<List<TestTourResult>> addMultipleTours(List<TourModel> tours) async {
    final results = <TestTourResult>[];

    for (final tour in tours) {
      try {
        final docId = await addTour(tour);
        results.add(TestTourResult(tourTitle: tour.title, docId: docId, success: true));
      } catch (e) {
        results.add(TestTourResult(tourTitle: tour.title, error: e.toString(), success: false));
      }
    }

    return results;
  }

  /// Tüm test turlarını siler (companyId = 'test_company' olanlar).
  /// Alt koleksiyonları (program) da siler.
  Future<int> deleteTestTours() async {
    try {
      final snapshot = await _firestore
          .collection('tours')
          .where('companyId', isEqualTo: 'test_company')
          .get();

      for (final doc in snapshot.docs) {
        // Önce program alt koleksiyonunu sil
        final programSnapshot = await doc.reference.collection('program').get();
        for (final programDoc in programSnapshot.docs) {
          await programDoc.reference.delete();
        }
        // Sonra turu sil
        await doc.reference.delete();
      }

      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      throw TestTourException(message: 'Silme hatası: ${e.message}', code: e.code);
    }
  }

  /// Tura program günleri ekler.
  /// [tourId] - Programın ekleneceği turun ID'si
  /// [days] - Her gün için: title, day, order, activities listesi
  Future<void> addTourProgram(String tourId, List<Map<String, dynamic>> days) async {
    try {
      final programRef = _firestore.collection('tours').doc(tourId).collection('program');

      for (final day in days) {
        await programRef.add(day);
      }
    } on FirebaseException catch (e) {
      throw TestTourException(message: 'Program ekleme hatası: ${e.message}', code: e.code);
    } catch (e) {
      throw TestTourException(message: 'Program ekleme hatası: $e');
    }
  }
}

/// Test tur servisi için özel exception sınıfı.
class TestTourException implements Exception {
  final String message;
  final String? code;

  TestTourException({required this.message, this.code});

  @override
  String toString() => 'TestTourException($code): $message';
}

/// Toplu tur ekleme sonuç modeli.
class TestTourResult {
  final String tourTitle;
  final String? docId;
  final String? error;
  final bool success;

  TestTourResult({required this.tourTitle, this.docId, this.error, required this.success});
}
