import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Kullanıcı bulunamadı');
    }

    final isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
    final hasPasswordProvider = user.providerData.any((info) => info.providerId == 'password');
    if (isGoogleUser && !hasPasswordProvider) {
      throw Exception('Google ile giriş yaptığınız için şifre değiştiremezsiniz');
    }

    final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Future<UserModel?> getCurrentProfile() async {
    final userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return null;
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> updateProfile({required String fullName, required String email}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı bulunamadı');
    }
    if (email != user.email) {
      await user.verifyBeforeUpdateEmail(email);
    }
    await _firestore.collection('users').doc(user.uid).update({
      'fullName': fullName,
      'email': email,
    });
  }
}
