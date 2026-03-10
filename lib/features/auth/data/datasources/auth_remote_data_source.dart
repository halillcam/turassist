import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_session_entity.dart';
import '../models/auth_user_model.dart';

/// FirebaseAuth + Firestore + Google Sign-In erişimini tek noktada toplar.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<AuthSessionEntity?> loginWithEmail({
    required String email,
    required String password,
    required String companyId,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = await _readUserModelOrThrow(credential.user?.uid ?? '');
      if (userModel.isDeleted) {
        await _firebaseAuth.signOut();
        throw Exception('Bu hesap silinmiştir.');
      }
      if (userModel.role == 'admin' || userModel.role == 'super_admin') {
        await _firebaseAuth.signOut();
        throw Exception(
          'Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.',
        );
      }

      final currentEmail = credential.user?.email ?? userModel.email;
      final isSyntheticEmail =
          currentEmail.endsWith('@guide.turassist') || currentEmail.endsWith('@customer.turassist');

      return AuthSessionEntity(
        user: userModel.toEntity(),
        requiresEmailVerification: !isSyntheticEmail && !(credential.user?.emailVerified ?? false),
        isSyntheticEmail: isSyntheticEmail,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('AuthRemoteDataSource.loginWithEmail error: $error');
      rethrow;
    }
  }

  Future<AuthSessionEntity?> loginWithGuideId({
    required String guideId,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: '${guideId.trim()}@guide.turassist',
        password: password,
      );
      final userModel = await _readUserModelOrThrow(
        credential.user?.uid ?? '',
        missingError: 'guide-profile-not-found',
      );

      if (userModel.role != 'guide') {
        await _firebaseAuth.signOut();
        throw Exception('not-a-guide');
      }

      return AuthSessionEntity(
        user: userModel.toEntity(),
        requiresEmailVerification: false,
        isSyntheticEmail: true,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('AuthRemoteDataSource.loginWithGuideId error: $error');
      rethrow;
    }
  }

  Future<AuthSessionEntity?> loginWithSyntheticCustomer({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final document = await _firestore.collection('users').doc(credential.user?.uid).get();
      final userModel = document.exists
          ? AuthUserModel.fromFirestore(document)
          : AuthUserModel(
              uid: credential.user?.uid ?? '',
              fullName: credential.user?.displayName ?? 'Müşteri',
              email: email,
              phone: credential.user?.phoneNumber ?? '',
              role: 'customer',
              companyId: '',
              registeredCompanies: const [],
              tcNo: '',
              selectedCity: '',
              profileImage: credential.user?.photoURL,
              isDeleted: false,
              createdAt: DateTime.now(),
            );

      return AuthSessionEntity(
        user: userModel.toEntity(),
        requiresEmailVerification: false,
        isSyntheticEmail: true,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('AuthRemoteDataSource.loginWithSyntheticCustomer error: $error');
      rethrow;
    }
  }

  Future<AuthSessionEntity?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final authentication = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: authentication.idToken);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase girişi başarısız oldu.');
      }

      final document = await _firestore.collection('users').doc(firebaseUser.uid).get();
      final userModel = document.exists
          ? AuthUserModel.fromFirestore(document)
          : await _createGoogleCustomer(firebaseUser);

      if (userModel.role == 'admin' || userModel.role == 'super_admin') {
        await signOut();
        throw Exception(
          'Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.',
        );
      }
      if (userModel.isDeleted) {
        await signOut();
        throw Exception('Bu hesap silinmiştir.');
      }

      return AuthSessionEntity(
        user: userModel.toEntity(),
        requiresEmailVerification: false,
        isSyntheticEmail: false,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      debugPrint('AuthRemoteDataSource.signInWithGoogle error: $error');
      throw Exception(_mapGoogleError(error.code));
    } on FirebaseAuthException catch (error) {
      debugPrint('AuthRemoteDataSource.signInWithGoogle auth error: ${error.code}');
      throw Exception(_mapFirebaseError(error.code));
    } catch (error) {
      debugPrint('AuthRemoteDataSource.signInWithGoogle generic error: $error');
      rethrow;
    }
  }

  Future<AuthUserModel?> registerCustomer({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = credential.user?.uid ?? '';
      final newUser = AuthUserModel(
        uid: userId,
        fullName: fullName,
        email: email,
        phone: '',
        role: 'customer',
        companyId: '',
        registeredCompanies: const [],
        tcNo: '',
        selectedCity: '',
        profileImage: credential.user?.photoURL,
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toJson());
      await credential.user?.sendEmailVerification();
      return newUser;
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      debugPrint('AuthRemoteDataSource.registerCustomer error: $error');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await _firebaseAuth.signOut();
    } catch (error) {
      debugPrint('AuthRemoteDataSource.signOut error: $error');
      rethrow;
    }
  }

  Future<AuthUserModel> _createGoogleCustomer(User firebaseUser) async {
    final newUser = AuthUserModel(
      uid: firebaseUser.uid,
      fullName: firebaseUser.displayName ?? 'İsimsiz Kullanıcı',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      role: 'customer',
      companyId: '',
      registeredCompanies: const [],
      tcNo: '',
      selectedCity: '',
      profileImage: firebaseUser.photoURL,
      isDeleted: false,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());
    return newUser;
  }

  Future<AuthUserModel> _readUserModelOrThrow(
    String userId, {
    String missingError = 'Kullanıcı profili bulunamadı. Lütfen tekrar kayıt olun.',
  }) async {
    final document = await _firestore.collection('users').doc(userId).get();
    if (!document.exists) {
      await _firebaseAuth.signOut();
      throw Exception(missingError);
    }
    return AuthUserModel.fromFirestore(document);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi başka bir giriş yöntemiyle kayıtlı. Lütfen o yöntemle giriş yapın.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgisi. Lütfen tekrar deneyin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'operation-not-allowed':
        return 'Google ile giriş şu an devre dışı.';
      case 'network-request-failed':
        return 'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  String _mapGoogleError(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.interrupted:
        return 'Giriş işlemi kesintiye uğradı. Lütfen tekrar deneyin.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google giriş arayüzü kullanılamıyor.';
      default:
        return 'Google ile giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
