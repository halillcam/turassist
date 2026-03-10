class ChatSenderEntity {
  const ChatSenderEntity({required this.userId, required this.displayName, required this.role});

  final String userId;
  final String displayName;
  final String role;

  bool get isGuide => role.trim().toLowerCase() == 'guide';
}
