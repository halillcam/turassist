class ChatMessageEntity {
  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  bool get isGuideMessage => senderRole.trim().toLowerCase() == 'guide';
}
