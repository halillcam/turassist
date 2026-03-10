import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  Future<UserModel?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (error) {
      debugPrint('AuthService.getUserProfile Error: $error');
      return null;
    }
  }

  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;

      final newUser = UserModel(
        uid: userId,
        fullName: '$name $surname',
        email: email,
        phone: '',
        role: 'customer',
        companyId: '',
        registeredCompanies: const [],
        tcNo: '',
        selectedCity: '',
        profileImage: null,
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toJson());
      return newUser;
    } catch (error) {
      debugPrint('AuthService.registerUser Error: $error');
      throw Exception('Kayıt başarısız: ${error.toString()}');
    }
  }

  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('Kullanıcı profili bulunamadı. Lütfen tekrar kayıt olun.');
      }

      final user = UserModel.fromFirestore(doc);
      if (user.role == 'admin' || user.role == 'super_admin') {
        await _auth.signOut();
        throw Exception(
          'Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.',
        );
      }
      return user;
    } on FirebaseException {
      rethrow;
    } catch (error) {
      debugPrint('AuthService.loginAndCheckAuth Error: $error');
      rethrow;
    }
  }

  Future<UserModel?> guideLogin(String guideId, String password) async {
    final syntheticEmail = '${guideId.trim()}@guide.turassist';
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: syntheticEmail,
        password: password,
      );
      final userId = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('guide-profile-not-found');
      }

      final user = UserModel.fromFirestore(doc);
      if (user.role != 'guide') {
        await _auth.signOut();
        throw Exception('not-a-guide');
      }

      return user;
    } on FirebaseException {
      rethrow;
    } catch (error) {
      debugPrint('AuthService.guideLogin Error: $error');
      rethrow;
    }
  }

  Future<UserModel?> customerLogin(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return UserModel(
        uid: userId,
        fullName: cred.user!.displayName ?? 'Müşteri',
        email: email,
        phone: '',
        role: 'customer',
        companyId: '',
        registeredCompanies: const [],
        tcNo: '',
        selectedCity: '',
        profileImage: null,
        isDeleted: false,
        createdAt: DateTime.now(),
      );
    } on FirebaseException {
      rethrow;
    } catch (error) {
      debugPrint('AuthService.customerLogin Error: $error');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (error) {
      debugPrint('AuthService.logout Error: $error');
      throw Exception('Çıkış başarısız');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      debugPrint('AuthService.resetPassword Error: $error');
      throw Exception('Şifre sıfırlama hatası');
    }
  }

  Future<bool> isAuthorizedForCompany(String userId, String companyId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final user = UserModel.fromFirestore(userDoc);
    if (user.role == 'super_admin') return true;
    return user.registeredCompanies.contains(companyId);
  }

  Future<String> getGuideFullName(String uid, {String defaultName = 'Tur Sorumlusu'}) async {
    if (uid.isEmpty) return defaultName;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final name = userDoc.data()?['fullName']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }

    final guideDoc = await _firestore.collection('guides').doc(uid).get();
    if (guideDoc.exists) {
      final name = guideDoc.data()?['fullName']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }

    return defaultName;
  }
}
