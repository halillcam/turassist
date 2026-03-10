import 'auth_entity.dart';

/// Auth sonrası yönlendirme kararını taşıyan domain sonucu.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.user,
    required this.requiresEmailVerification,
    required this.isSyntheticEmail,
  });

  final AuthEntity user;
  final bool requiresEmailVerification;
  final bool isSyntheticEmail;

  bool get isSyntheticCustomer => user.email.toLowerCase().endsWith('@customer.turassist');
}
