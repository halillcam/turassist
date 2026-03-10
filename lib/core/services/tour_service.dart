import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/tour_model.dart';
import '../models/tour_program_model.dart';
import '../models/user_model.dart';

class TourService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TourModel>> getActiveTours() async {
    try {
      final snapshot = await _firestore.collection('tours').get();
      return snapshot.docs.map(TourModel.fromFirestore).where((tour) => !tour.isDeleted).toList();
    } catch (error) {
      debugPrint('TourService.getActiveTours Error: $error');
      return [];
    }
  }

  Future<List<TourModel>> getToursByCity(String city) async {
    try {
      final snapshot = await _firestore.collection('tours').where('city', isEqualTo: city).get();
      return snapshot.docs.map(TourModel.fromFirestore).where((tour) => !tour.isDeleted).toList();
    } catch (error) {
      debugPrint('TourService.getToursByCity Error: $error');
      return [];
    }
  }

  Future<List<String>> getAllCities() async {
    try {
      final snapshot = await _firestore.collection('cities').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (error) {
      debugPrint('TourService.getAllCities Error: $error');
      return [];
    }
  }

  Future<TourModel?> getTourById(String tourId) async {
    try {
      final doc = await _firestore.collection('tours').doc(tourId).get();
      if (doc.exists) return TourModel.fromFirestore(doc);
      return null;
    } catch (error) {
      debugPrint('TourService.getTourById Error: $error');
      return null;
    }
  }

  Future<TourModel?> getAssignedTourForGuide(String guideId) async {
    try {
      if (guideId.trim().isEmpty) return null;
      final snapshot = await _firestore
          .collection('tours')
          .where('guideId', isEqualTo: guideId)
          .get();
      if (snapshot.docs.isEmpty) return null;

      final tours = snapshot.docs
          .map(TourModel.fromFirestore)
          .where((tour) => !tour.isDeleted)
          .toList();
      if (tours.isEmpty) return null;
      tours.sort((left, right) => right.createdAt.compareTo(left.createdAt));
      return tours.first;
    } catch (error) {
      debugPrint('TourService.getAssignedTourForGuide Error: $error');
      return null;
    }
  }

  Future<List<TourProgramDay>> getTourProgram(String tourId) async {
    try {
      final tourDoc = await _firestore.collection('tours').doc(tourId).get();
      final data = tourDoc.data();
      if (data != null) {
        final embeddedProgram = data['program'] ?? data['tourProgram'] ?? data['programDays'];
        final parsedEmbedded = _parseEmbeddedProgram(embeddedProgram);
        if (parsedEmbedded.isNotEmpty) {
          return parsedEmbedded;
        }
      }

      final snapshot = await _firestore
          .collection('tours')
          .doc(tourId)
          .collection('program')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map(TourProgramDay.fromFirestore).toList();
    } catch (error) {
      debugPrint('TourService.getTourProgram Error: $error');
      return [];
    }
  }

  List<TourProgramDay> _parseEmbeddedProgram(dynamic rawProgram) {
    if (rawProgram is! List || rawProgram.isEmpty) return [];

    final programDays = <TourProgramDay>[];
    for (var index = 0; index < rawProgram.length; index++) {
      final item = rawProgram[index];
      if (item is Map<String, dynamic>) {
        programDays.add(TourProgramDay.fromMap(item, id: 'embedded_$index'));
        continue;
      }
      if (item is Map) {
        programDays.add(
          TourProgramDay.fromMap(Map<String, dynamic>.from(item), id: 'embedded_$index'),
        );
        continue;
      }
      if (item is String && item.trim().isNotEmpty) {
        programDays.add(
          TourProgramDay(
            id: 'embedded_$index',
            title: 'Gün ${index + 1}',
            day: index + 1,
            order: index,
            activities: [item.trim()],
          ),
        );
      }
    }

    programDays.sort((left, right) {
      final orderCompare = left.order.compareTo(right.order);
      if (orderCompare != 0) return orderCompare;
      return left.day.compareTo(right.day);
    });
    return programDays;
  }

  Future<void> updateTour(String tourId, TourModel tour) async {
    try {
      await _firestore.collection('tours').doc(tourId).update(tour.toJson());
    } catch (error) {
      debugPrint('TourService.updateTour Error: $error');
    }
  }

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
          var resolvedName = ticketName;

          if (resolvedName.isEmpty && userId.isNotEmpty) {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            final userData = userDoc.data();
            final profileName = userData?['fullName']?.toString().trim() ?? '';
            final email = userData?['email']?.toString().trim() ?? '';
            final emailName = email.contains('@') ? email.split('@').first.trim() : '';

            resolvedName = profileName.isNotEmpty
                ? profileName
                : (emailName.isNotEmpty ? emailName : resolvedName);

            if (resolvedName.isNotEmpty) {
              await doc.reference.update({'passengerName': resolvedName});
            }
          }

          return {'id': doc.id, ...data, 'passengerName': resolvedName, 'tcNo': tcNo};
        }),
      );

      return participants.whereType<Map<String, dynamic>>().toList();
    } catch (error) {
      debugPrint('TourService.getTourParticipants Error: $error');
      return [];
    }
  }

  Future<bool> hasPendingTourCompletionRequest({
    required String tourId,
    required String guideId,
  }) async {
    try {
      if (tourId.trim().isEmpty || guideId.trim().isEmpty) return false;

      final snapshot = await _firestore
          .collection('tourCompletionRequests')
          .where('tourId', isEqualTo: tourId)
          .where('guideId', isEqualTo: guideId)
          .where('isApproved', isEqualTo: false)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException {
      rethrow;
    } catch (error) {
      debugPrint('TourService.hasPendingTourCompletionRequest Error: $error');
      rethrow;
    }
  }

  Future<void> requestTourCompletion({required String tourId, required String guideId}) async {
    try {
      final normalizedTourId = tourId.trim();
      final normalizedGuideId = guideId.trim();
      if (normalizedTourId.isEmpty || normalizedGuideId.isEmpty) {
        throw Exception('invalid-tour-completion-request');
      }

      final guideDoc = await _firestore.collection('users').doc(normalizedGuideId).get();
      if (!guideDoc.exists) {
        throw Exception('guide-profile-not-found');
      }

      final guide = UserModel.fromFirestore(guideDoc);
      if (guide.role.trim().toLowerCase() != 'guide') {
        throw Exception('only-guide-can-request-tour-completion');
      }

      final tourDoc = await _firestore.collection('tours').doc(normalizedTourId).get();
      if (!tourDoc.exists) {
        throw Exception('tour-not-found');
      }

      final tour = TourModel.fromFirestore(tourDoc);
      if (tour.isDeleted) {
        throw Exception('tour-already-inactive');
      }
      if (tour.guideId.trim() != normalizedGuideId) {
        throw Exception('guide-not-assigned-to-this-tour');
      }

      final hasPending = await hasPendingTourCompletionRequest(
        tourId: normalizedTourId,
        guideId: normalizedGuideId,
      );
      if (hasPending) {
        throw Exception('tour-completion-request-already-exists');
      }

      await _firestore.collection('tourCompletionRequests').add({
        'tourId': tour.id,
        'tourTitle': tour.title,
        'guideId': normalizedGuideId,
        'companyId': tour.companyId,
        'isApproved': false,
        'requestedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      rethrow;
    } catch (error) {
      debugPrint('TourService.requestTourCompletion Error: $error');
      rethrow;
    }
  }

  Future<void> finishTour(String tourId, String guideId) {
    return requestTourCompletion(tourId: tourId, guideId: guideId);
  }
}
