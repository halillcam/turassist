import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/ticket_model.dart';

/// QR doğrulama işlemi sonucunu temsil eder.
///
/// [success] — işlem başarılıysa true
/// [code]    — makine okunabilir durum kodu (örn. 'ok', 'date_mismatch')
/// [message] — kullanıcıya gösterilebilir Türkçe açıklama
/// [passengerName] — başarılı check-in'de yolcu adı
class QrConsumeResult {
  final bool success;
  final String code;
  final String message;
  final String passengerName;

  const QrConsumeResult({
    required this.success,
    required this.code,
    required this.message,
    this.passengerName = '',
  });
}

/// Bilet satın alma, QR doğrulama ve bilet yönetimi servisi.
///
/// Sorumlulukları:
/// - Bilet oluşturma ve güvenli QR token üretimi
/// - Kullanıcı biletlerini listeleme (anlık Firestore stream dahil)
/// - QR token doğrulama ve tek seferlik check-in işlemleri
///   (iki stratejili fallback mekanizması)
/// - Slot kapasitesi sorgulama
/// - Bilet durum güncellemeleri
class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _readCapacity(Map<String, dynamic>? data) {
    final raw = data?['capacity'];
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  // ==================== QR YARDIMCI METOTLARı ====================

  /// QR token string'inden baştaki/sondaki boşluk ve satır sonlarını temizler.
  String _normalizeQrToken(String token) {
    return token.trim().replaceAll('\n', '').replaceAll('\r', '');
  }

  /// Base64Url kodlu QR token'ı JSON payload'a çözer.
  ///
  /// Token geçersiz veya JSON formatına uygun değilse [null] döner.
  Map<String, dynamic>? _decodeQrPayload(String token) {
    try {
      var normalized = token.trim().replaceAll('\n', '').replaceAll('\r', '');
      final mod = normalized.length % 4;
      if (mod != 0) {
        normalized = normalized.padRight(normalized.length + (4 - mod), '=');
      }
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) return payload;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Token formatına göre ticketId çıkarır.
  ///
  /// `tk_<ticketId>_<nonce>` formatını ve Base64Url payload'ı destekler.
  String _extractTicketIdFromToken(String token) {
    final raw = token.trim();
    if (raw.startsWith('tk_')) {
      final parts = raw.split('_');
      if (parts.length >= 3) {
        return parts[1].trim();
      }
    }
    final payload = _decodeQrPayload(raw);
    return payload?['ticketId']?.toString().trim() ?? '';
  }

  /// [slotId]'nin `yyyy-MM-dd` tarih formatında olup olmadığını doğrular.
  bool _isDateSlotId(String slotId) {
    if (slotId.length != 10) return false;
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(slotId);
  }

  // ==================== SLOT KAPASİTESİ ====================

  /// Belirli bir tur + slot (tarih) için satılmış aktif bilet sayısını döndürür.
  ///
  /// İptal edilmiş ('cancelled') biletler sayılmaz.
  Future<int> getSlotTicketCount(String tourId, String slotId) async {
    try {
      final snap = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('slotId', isEqualTo: slotId)
          .where('status', whereIn: ['active', 'checked_in'])
          .get();
      return snap.docs.length;
    } catch (e) {
      debugPrint('TicketService.getSlotTicketCount HATA: $e');
      return 0;
    }
  }

  /// Birden fazla slot için toplu kapasite sorgular.
  ///
  /// Firestore `whereIn` sorgusunun 10 eleman sınırı nedeniyle chunk'lara
  /// bölünerek sorgulanır. Dönen map: `slotId → satılmış bilet sayısı`.
  Future<Map<String, int>> getSlotTicketCounts(String tourId, List<String> slotIds) async {
    final result = <String, int>{};
    for (var i = 0; i < slotIds.length; i += 10) {
      final chunk = slotIds.sublist(i, i + 10 > slotIds.length ? slotIds.length : i + 10);
      try {
        final snap = await _firestore
            .collection('tickets')
            .where('tourId', isEqualTo: tourId)
            .where('slotId', whereIn: chunk)
            .get();

        for (final doc in snap.docs) {
          final data = doc.data();
          final status = data['status']?.toString().toLowerCase() ?? '';
          if (status == 'cancelled' || status == 'completed') continue;
          final sid = data['slotId']?.toString() ?? '';
          result[sid] = (result[sid] ?? 0) + 1;
        }
      } catch (e) {
        debugPrint('TicketService.getSlotTicketCounts HATA (chunk $i): $e');
      }
    }
    return result;
  }

  // ==================== BİLET OLUŞTURMA ====================

  /// Bilet oluşturur, QR token üretir ve Firestore'a atomik olarak kaydeder.
  ///
  /// **Kritik yol:** Önce bilet belgesi garanti edilir.
  /// Tur ve kullanıcı üzerindeki ek ilişki alanları
  /// (registeredUserIds, purchasedTourIds) best-effort olarak güncellenir.
  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) async {
    try {
      debugPrint('TicketService.createTicket: userId=${ticket.userId}, tourId=${ticket.tourId}');

      final docRef = _firestore.collection('tickets').doc();
      final tourRef = _firestore.collection('tours').doc(ticket.tourId);
      final userRef = _firestore.collection('users').doc(ticket.userId);

      // QR token oluştur
      final qrToken = await generateQRToken(
        ticketId: docRef.id,
        tourId: ticket.tourId,
        userId: ticket.userId,
      );

      await _firestore.runTransaction((transaction) async {
        final tourSnap = await transaction.get(tourRef);
        if (!tourSnap.exists) {
          throw Exception('Tur bulunamadı');
        }

        final tourData = tourSnap.data();
        final currentCapacity = _readCapacity(tourData);
        if (currentCapacity <= 0) {
          throw Exception('Bu turda bos kontenjan kalmadi');
        }

        final payload = ticket.toJson();
        payload['qrToken'] = qrToken;

        transaction.set(docRef, payload);
        transaction.update(tourRef, {
          'capacity': currentCapacity - 1,
          'registeredUserIds': FieldValue.arrayUnion([ticket.userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      try {
        await userRef.set({
          'purchasedTourIds': FieldValue.arrayUnion([ticket.tourId]),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('TicketService.createTicket: user purchasedTourIds güncellenemedi: $e');
      }

      debugPrint('TicketService.createTicket: BAŞARILI → docId=${docRef.id}');
      return (ticketId: docRef.id, qrToken: qrToken);
    } catch (e) {
      debugPrint('TicketService.createTicket: HATA → $e');
      throw Exception("Bilet oluşturma başarısız: $e");
    }
  }

  // ==================== BİLET LİSTELEME ====================

  /// Giriş yapmış kullanıcının tüm biletlerini satın alma tarihine göre (yeniden eskiye) getirir.
  Future<List<TicketModel>> getUserTickets() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception("Kullanıcı giriş yapmamış");

      debugPrint('TicketService.getUserTickets: userId=$userId');

      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();

      debugPrint('TicketService.getUserTickets: ${snapshot.docs.length} bilet bulundu');

      final tickets = snapshot.docs.map(TicketModel.fromFirestore).toList();
      // Composite index gerekmeden bellekte sırala
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return tickets;
    } catch (e) {
      debugPrint('TicketService.getUserTickets: HATA → $e');
      return [];
    }
  }

  /// Kullanıcı biletlerini gerçek zamanlı olarak dinler.
  ///
  /// Rehber QR okuttuğunda `isScanned` / `status` değişikliklerini
  /// anında UI'a yansıtmak için kullanılır.
  Stream<List<TicketModel>> getUserTicketsStream() {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return const Stream.empty();

    return _firestore.collection('tickets').where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final tickets = snapshot.docs.map(TicketModel.fromFirestore).toList();
      tickets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return tickets;
    });
  }

  // ==================== QR TOKEN YÖNETİMİ ====================

  /// Benzersiz QR token üretir: `tk_<ticketId>_<nonce>` formatında.
  ///
  /// Nonce = mikrosaniye bazlı timestamp + kriptografik rastgele sayı.
  /// Token tahmin edilemez ve tekrar edilemezdir.
  Future<String> generateQRToken({
    required String ticketId,
    required String tourId,
    required String userId,
  }) async {
    try {
      final random = Random.secure();
      final nonce =
          '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
          '${random.nextInt(1 << 32).toRadixString(36)}';
      return 'tk_${ticketId}_$nonce';
    } catch (e) {
      debugPrint('TicketService.generateQRToken Error: $e');
      throw Exception("QR token oluşturulamadı");
    }
  }

  /// Belirtilen biletin qrToken alanını günceller.
  Future<void> updateTicketQRToken(String ticketId, String qrToken) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'qrToken': qrToken});
    } catch (e) {
      debugPrint('TicketService.updateTicketQRToken Error: $e');
      throw Exception('QR token kaydedilemedi: $e');
    }
  }

  /// Bilet ID'si ile QR okutma işlemi yapar (eski, sadece ID tabanlı API).
  ///
  /// Bilet zaten okutulmuşsa, iptal veya tamamlanmışsa `false` döner.
  Future<bool> updateTicketQRStatus(String ticketId) async {
    try {
      final ref = _firestore.collection('tickets').doc(ticketId);
      return await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(ref);
        if (!snapshot.exists) return false;

        final data = snapshot.data() as Map<String, dynamic>;
        final alreadyScanned = data['isScanned'] == true;
        final status = data['status']?.toString().toLowerCase() ?? '';

        if (alreadyScanned || status == 'cancelled' || status == 'completed') {
          return false;
        }

        tx.update(ref, {
          'isScanned': true,
          'status': 'checked_in',
          'scannedAt': FieldValue.serverTimestamp(),
          'qrToken': null,
        });
        return true;
      });
    } catch (e) {
      debugPrint('TicketService.updateTicketQRStatus Error: $e');
      return false;
    }
  }

  /// QR token ile bilet doğrular ve check-in yapar.
  ///
  /// [consumeTicketByQrTokenDetailed] metodunun `bool` dönen eski API sarmalayıcısı.
  Future<bool> consumeTicketByQrToken({
    required String qrToken,
    required String expectedTourId,
  }) async {
    final result = await consumeTicketByQrTokenDetailed(
      qrToken: qrToken,
      expectedTourId: expectedTourId,
    );
    return result.success;
  }

  /// QR token ile bilet doğrular, check-in yapar ve detaylı sonuç döner.
  ///
  /// **Strateji 1 (tercih edilen):** Token'dan ticketId parse edilerek
  /// doğrudan belge erişimi yapılır. Firestore Rules koleksiyon sorgusunu
  /// engellese bile genellikle çalışır.
  ///
  /// **Strateji 2 (fallback):** qrToken alanı ile koleksiyon sorgusu yapılır.
  ///
  /// **No-read fallback:** İki strateji de izin hatasıyla başarısız olursa
  /// okumadan kör güncelleme denenir (en düşük güvenlik garantisi).
  Future<QrConsumeResult> consumeTicketByQrTokenDetailed({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) async {
    final normalizedToken = _normalizeQrToken(qrToken);
    final payloadTicketId = _extractTicketIdFromToken(qrToken);

    debugPrint('consumeTicket: normalizedToken=$normalizedToken');
    debugPrint('consumeTicket: payloadTicketId=$payloadTicketId');
    debugPrint('consumeTicket: expectedTourId=$expectedTourId');

    try {
      if (normalizedToken.isEmpty || expectedTourId.trim().isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'invalid_input',
          message: 'QR verisi veya tur bilgisi boş.',
        );
      }

      // ── STRATEJİ 1: Token'dan ticketId çıkararak doğrudan belge erişimi ──
      if (payloadTicketId.isNotEmpty) {
        debugPrint('consumeTicket: Strateji 1 — doğrudan ticketId: $payloadTicketId');
        try {
          final directRef = _firestore.collection('tickets').doc(payloadTicketId);
          final txPassengerName = await _firestore.runTransaction<String?>((tx) async {
            final snapshot = await tx.get(directRef);
            if (!snapshot.exists) return null;

            final data = snapshot.data() as Map<String, dynamic>;
            final alreadyScanned = data['isScanned'] == true;
            final status = data['status']?.toString().toLowerCase() ?? '';
            final tourId = data['tourId']?.toString() ?? '';
            final tokenInDb = data['qrToken']?.toString() ?? '';
            final normalizedInDb = _normalizeQrToken(tokenInDb);
            final pName = data['passengerName']?.toString() ?? '';
            final slotId = data['slotId']?.toString() ?? '';

            if (tourId.trim() != expectedTourId.trim()) return null;
            if (normalizedInDb != normalizedToken) return null;
            if (alreadyScanned || status == 'cancelled' || status == 'completed') return null;

            // Tarih doğrulama: beklenen tarih verilmişse slotId ile karşılaştır
            if (expectedDate != null && _isDateSlotId(slotId)) {
              if (slotId != expectedDate) {
                return '__DATE_MISMATCH__$slotId';
              }
            }

            tx.update(directRef, {
              'isScanned': true,
              'status': 'checked_in',
              'scannedAt': FieldValue.serverTimestamp(),
              'qrToken': null,
            });
            return pName;
          });

          if (txPassengerName != null) {
            if (txPassengerName.startsWith('__DATE_MISMATCH__')) {
              final ticketSlot = txPassengerName.replaceFirst('__DATE_MISMATCH__', '');
              return QrConsumeResult(
                success: false,
                code: 'date_mismatch',
                message: 'Bu bilet $ticketSlot tarihli. Sizin atanmış tarihiniz $expectedDate.',
              );
            }
            debugPrint('consumeTicket: Strateji 1 BAŞARILI ✓');
            return QrConsumeResult(
              success: true,
              code: 'ok',
              message: 'QR doğrulandı.',
              passengerName: txPassengerName,
            );
          }

          return const QrConsumeResult(
            success: false,
            code: 'invalid_or_used',
            message: 'QR geçersiz, farklı tura ait veya daha önce kullanılmış.',
          );
        } on FirebaseException catch (e) {
          if (e.code != 'permission-denied') rethrow;
          debugPrint('consumeTicket: Strateji 1 permission-denied, Strateji 2 deneniyor...');
        }
      }

      // ── STRATEJİ 2: qrToken alanı ile koleksiyon sorgusu ──
      debugPrint('consumeTicket: Strateji 2 — qrToken ile sorgu');
      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('tickets')
          .where('qrToken', isEqualTo: normalizedToken)
          .limit(1)
          .get();

      DocumentReference<Map<String, dynamic>>? ref;
      if (query.docs.isNotEmpty) {
        ref = query.docs.first.reference;
      }

      // Ham token ile de dene (normalizasyon farkı olabilir)
      if (ref == null) {
        query = await _firestore
            .collection('tickets')
            .where('qrToken', isEqualTo: qrToken.trim())
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) ref = query.docs.first.reference;
      }

      if (ref == null) {
        return const QrConsumeResult(
          success: false,
          code: 'token_not_found',
          message: 'QR token bulunamadı.',
        );
      }

      final ticketRef = ref;
      final txPassengerName2 = await _firestore.runTransaction<String?>((tx) async {
        final snapshot = await tx.get(ticketRef);
        if (!snapshot.exists) return null;

        final data = snapshot.data() as Map<String, dynamic>;
        final alreadyScanned = data['isScanned'] == true;
        final status = data['status']?.toString().toLowerCase() ?? '';
        final tourId = data['tourId']?.toString() ?? '';
        final pName = data['passengerName']?.toString() ?? '';
        final slotId = data['slotId']?.toString() ?? '';

        if (tourId.trim() != expectedTourId.trim()) return null;
        if (alreadyScanned || status == 'cancelled' || status == 'completed') return null;

        if (expectedDate != null && _isDateSlotId(slotId)) {
          if (slotId != expectedDate) {
            return '__DATE_MISMATCH__$slotId';
          }
        }

        tx.update(ticketRef, {
          'isScanned': true,
          'status': 'checked_in',
          'scannedAt': FieldValue.serverTimestamp(),
          'qrToken': null,
        });
        return pName;
      });

      if (txPassengerName2 != null) {
        if (txPassengerName2.startsWith('__DATE_MISMATCH__')) {
          final ticketSlot = txPassengerName2.replaceFirst('__DATE_MISMATCH__', '');
          return QrConsumeResult(
            success: false,
            code: 'date_mismatch',
            message: 'Bu bilet $ticketSlot tarihli. Sizin atanmış tarihiniz $expectedDate.',
          );
        }
        debugPrint('consumeTicket: Strateji 2 BAŞARILI ✓');
        return QrConsumeResult(
          success: true,
          code: 'ok',
          message: 'QR doğrulandı.',
          passengerName: txPassengerName2,
        );
      }

      return const QrConsumeResult(
        success: false,
        code: 'invalid_or_used',
        message: 'QR geçersiz, farklı tura ait veya daha önce kullanılmış.',
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('consumeTicket: permission-denied, blind update fallback deneniyor');
        return _consumeTicketByPayloadNoRead(
          ticketId: payloadTicketId,
          payloadTourId: '',
          expectedTourId: expectedTourId,
        );
      }
      debugPrint('consumeTicket FirebaseError: ${e.code} ${e.message}');
      return QrConsumeResult(
        success: false,
        code: e.code,
        message: 'Firebase hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      debugPrint('consumeTicket Error: $e');
      return QrConsumeResult(
        success: false,
        code: 'unknown_error',
        message: 'Beklenmeyen hata: $e',
      );
    }
  }

  /// Firestore okuma izni olmadan yalnızca güncelleme yaparak QR'ı tüketir.
  ///
  /// Strateji 1 ve 2 `permission-denied` hatasıyla başarısız olduğunda
  /// son çare olarak kullanılır. Bilet doğrulaması yapılamaz.
  Future<QrConsumeResult> _consumeTicketByPayloadNoRead({
    required String ticketId,
    required String payloadTourId,
    required String expectedTourId,
  }) async {
    try {
      if (ticketId.trim().isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'ticket_id_missing',
          message: 'QR içinde ticketId bulunamadı.',
        );
      }
      if (payloadTourId.trim().isNotEmpty && payloadTourId.trim() != expectedTourId.trim()) {
        return const QrConsumeResult(
          success: false,
          code: 'tour_mismatch_payload',
          message: 'QR farklı tura ait görünüyor.',
        );
      }

      await _firestore.collection('tickets').doc(ticketId).update({
        'isScanned': true,
        'status': 'checked_in',
        'scannedAt': FieldValue.serverTimestamp(),
        'qrToken': null,
      });

      return const QrConsumeResult(
        success: true,
        code: 'ok_no_read_fallback',
        message: 'QR doğrulandı (fallback).',
      );
    } on FirebaseException catch (e) {
      debugPrint('no-read fallback failed: ${e.code}');
      return QrConsumeResult(
        success: false,
        code: 'fallback_${e.code}',
        message: 'Fallback hatası: ${e.message ?? e.code}',
      );
    } catch (e) {
      return QrConsumeResult(
        success: false,
        code: 'fallback_unknown_error',
        message: 'Fallback beklenmeyen hata: $e',
      );
    }
  }

  // ==================== BİLET DURUM GÜNCELLEMESİ ====================

  /// Biletin durum alanını günceller (örn. 'cancelled', 'completed').
  ///
  /// Başarılıysa `true`, hata durumunda `false` döner.
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      final ticketRef = _firestore.collection('tickets').doc(ticketId);
      await _firestore.runTransaction((transaction) async {
        final ticketSnap = await transaction.get(ticketRef);
        if (!ticketSnap.exists) {
          throw Exception('Bilet bulunamadi');
        }

        final ticketData = ticketSnap.data();
        final previousStatus = ticketData?['status']?.toString() ?? '';
        final tourId = ticketData?['tourId']?.toString().trim() ?? '';

        if (newStatus == 'cancelled' && previousStatus != 'cancelled' && tourId.isNotEmpty) {
          final tourRef = _firestore.collection('tours').doc(tourId);
          final tourSnap = await transaction.get(tourRef);
          if (tourSnap.exists) {
            final currentCapacity = _readCapacity(tourSnap.data());
            transaction.update(tourRef, {
              'capacity': currentCapacity + 1,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        transaction.update(ticketRef, {
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      debugPrint('TicketService.updateTicketStatus Error: $e');
      return false;
    }
  }
}
