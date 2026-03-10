import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/ticket_model.dart';

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

class TicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _readCapacity(Map<String, dynamic>? data) {
    final raw = data?['capacity'];
    if (raw is num) return raw.toInt();

    final parsedTopLevel = int.tryParse(raw?.toString() ?? '');
    if (parsedTopLevel != null) return parsedTopLevel;

    final busInfo = data?['busInfo'];
    if (busInfo is Map<String, dynamic>) {
      final nested = busInfo['capacity'];
      if (nested is num) return nested.toInt();
      return int.tryParse(nested?.toString() ?? '') ?? 0;
    }
    if (busInfo is Map) {
      final nested = busInfo['capacity'];
      if (nested is num) return nested.toInt();
      return int.tryParse(nested?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _normalizeQrToken(String token) {
    return token.trim().replaceAll('\n', '').replaceAll('\r', '');
  }

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

  bool _isDateSlotId(String slotId) {
    if (slotId.length != 10) return false;
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(slotId);
  }

  Future<int> getSlotTicketCount(String tourId, String slotId) async {
    try {
      final snap = await _firestore
          .collection('tickets')
          .where('tourId', isEqualTo: tourId)
          .where('slotId', isEqualTo: slotId)
          .where('status', whereIn: ['active', 'checked_in'])
          .get();
      return snap.docs.length;
    } catch (error) {
      debugPrint('TicketService.getSlotTicketCount HATA: $error');
      return 0;
    }
  }

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
      } catch (error) {
        debugPrint('TicketService.getSlotTicketCounts HATA (chunk $i): $error');
      }
    }
    return result;
  }

  Future<({String ticketId, String qrToken})> createTicket(TicketModel ticket) async {
    try {
      debugPrint('TicketService.createTicket: userId=${ticket.userId}, tourId=${ticket.tourId}');
      final docRef = _firestore.collection('tickets').doc();
      final tourRef = _firestore.collection('tours').doc(ticket.tourId);
      final userRef = _firestore.collection('users').doc(ticket.userId);
      final qrToken = await generateQRToken(
        ticketId: docRef.id,
        tourId: ticket.tourId,
        userId: ticket.userId,
      );

      final tourSnap = await tourRef.get();
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

      await docRef.set(payload);

      final currentBusInfo = Map<String, dynamic>.from(tourData?['busInfo'] ?? const {});
      currentBusInfo['capacity'] = currentCapacity - 1;

      try {
        await tourRef.update({
          'capacity': currentCapacity - 1,
          'busInfo': currentBusInfo,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (error) {
        debugPrint('TicketService.createTicket capacity update error: $error');
      }

      try {
        await tourRef.update({
          'registeredUserIds': FieldValue.arrayUnion([ticket.userId]),
        });
      } catch (error) {
        debugPrint('TicketService.createTicket registeredUserIds update error: $error');
      }
      try {
        await userRef.set({
          'purchasedTourIds': FieldValue.arrayUnion([ticket.tourId]),
        }, SetOptions(merge: true));
      } catch (error) {
        debugPrint('TicketService.createTicket purchasedTourIds update error: $error');
      }

      return (ticketId: docRef.id, qrToken: qrToken);
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        throw Exception('ticket-create-permission-denied');
      }
      rethrow;
    } catch (error) {
      debugPrint('TicketService.createTicket: HATA → $error');
      throw Exception('Bilet oluşturma başarısız: $error');
    }
  }

  Future<List<TicketModel>> getUserTickets() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('Kullanıcı giriş yapmamış');
      final snapshot = await _firestore
          .collection('tickets')
          .where('userId', isEqualTo: userId)
          .get();
      final tickets = snapshot.docs.map(TicketModel.fromFirestore).toList();
      tickets.sort((left, right) => right.purchaseDate.compareTo(left.purchaseDate));
      return tickets;
    } catch (error) {
      debugPrint('TicketService.getUserTickets: HATA → $error');
      return [];
    }
  }

  Stream<List<TicketModel>> getUserTicketsStream() {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return const Stream.empty();

    return _firestore.collection('tickets').where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final tickets = snapshot.docs.map(TicketModel.fromFirestore).toList();
      tickets.sort((left, right) => right.purchaseDate.compareTo(left.purchaseDate));
      return tickets;
    });
  }

  Future<String> generateQRToken({
    required String ticketId,
    required String tourId,
    required String userId,
  }) async {
    final nowPart = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final ticketPart = ticketId.hashCode.abs().toRadixString(36);
    final userPart = userId.hashCode.abs().toRadixString(36);
    final tourPart = tourId.hashCode.abs().toRadixString(36);
    final randomPart = Random().nextInt(1 << 30).toRadixString(36);
    return 'tk_${ticketId}_$nowPart$randomPart$ticketPart$userPart$tourPart';
  }

  Future<void> updateTicketQRToken(String ticketId, String qrToken) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'qrToken': qrToken});
    } catch (error) {
      debugPrint('TicketService.updateTicketQRToken Error: $error');
      throw Exception('QR token kaydedilemedi: $error');
    }
  }

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
    } catch (error) {
      debugPrint('TicketService.updateTicketQRStatus Error: $error');
      return false;
    }
  }

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

  Future<QrConsumeResult> consumeTicketByQrTokenDetailed({
    required String qrToken,
    required String expectedTourId,
    String? expectedDate,
  }) async {
    final normalizedToken = _normalizeQrToken(qrToken);
    final payloadTicketId = _extractTicketIdFromToken(qrToken);

    try {
      if (normalizedToken.isEmpty || expectedTourId.trim().isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'invalid_input',
          message: 'QR verisi veya tur bilgisi boş.',
        );
      }

      if (payloadTicketId.isNotEmpty) {
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
            final passengerName = data['passengerName']?.toString() ?? '';
            final slotId = data['slotId']?.toString() ?? '';

            if (tourId.trim() != expectedTourId.trim()) return null;
            if (normalizedInDb != normalizedToken) return null;
            if (alreadyScanned || status == 'cancelled' || status == 'completed') return null;

            if (expectedDate != null && _isDateSlotId(slotId) && slotId != expectedDate) {
              return '__DATE_MISMATCH__$slotId';
            }

            tx.update(directRef, {
              'isScanned': true,
              'status': 'checked_in',
              'scannedAt': FieldValue.serverTimestamp(),
              'qrToken': null,
            });
            return passengerName;
          });

          if (txPassengerName != null) {
            if (txPassengerName.startsWith('__DATE_MISMATCH__')) {
              return QrConsumeResult(
                success: false,
                code: 'date_mismatch',
                message: 'QR farklı tarihli bir tura ait.',
              );
            }
            return QrConsumeResult(
              success: true,
              code: 'ok',
              message: 'QR başarıyla okundu.',
              passengerName: txPassengerName,
            );
          }
        } catch (_) {}
      }

      final query = await _firestore
          .collection('tickets')
          .where('qrToken', isEqualTo: normalizedToken)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return const QrConsumeResult(
          success: false,
          code: 'not_found',
          message: 'QR bulunamadı veya geçersiz.',
        );
      }

      final doc = query.docs.first;
      final data = doc.data();
      final status = data['status']?.toString().toLowerCase() ?? '';
      final slotId = data['slotId']?.toString() ?? '';

      if (data['tourId']?.toString().trim() != expectedTourId.trim()) {
        return const QrConsumeResult(
          success: false,
          code: 'tour_mismatch',
          message: 'QR bu tura ait değil.',
        );
      }
      if (data['isScanned'] == true || status == 'cancelled' || status == 'completed') {
        return const QrConsumeResult(
          success: false,
          code: 'already_used',
          message: 'QR daha önce kullanılmış veya artık geçersiz.',
        );
      }
      if (expectedDate != null && _isDateSlotId(slotId) && slotId != expectedDate) {
        return const QrConsumeResult(
          success: false,
          code: 'date_mismatch',
          message: 'QR farklı tarihli bir tura ait.',
        );
      }

      await doc.reference.update({
        'isScanned': true,
        'status': 'checked_in',
        'scannedAt': FieldValue.serverTimestamp(),
        'qrToken': null,
      });
      return QrConsumeResult(
        success: true,
        code: 'ok',
        message: 'QR başarıyla okundu.',
        passengerName: data['passengerName']?.toString() ?? '',
      );
    } catch (error) {
      debugPrint('TicketService.consumeTicketByQrTokenDetailed Error: $error');
      return const QrConsumeResult(success: false, code: 'error', message: 'QR doğrulanamadı.');
    }
  }

  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'status': newStatus});
      return true;
    } catch (error) {
      debugPrint('TicketService.updateTicketStatus Error: $error');
      return false;
    }
  }
}
