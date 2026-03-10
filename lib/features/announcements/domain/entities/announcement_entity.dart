/// Tur duyurusu domain varlığı.
class AnnouncementEntity {
  const AnnouncementEntity({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.scope,
    required this.senderRole,
    required this.senderName,
  });

  final String id;
  final String message;
  final DateTime createdAt;
  final String scope;
  final String senderRole;
  final String senderName;
}
