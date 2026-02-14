import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../controllers/chat_controller.dart';

/// Müşteri tarafı tur sohbet ekranı.
///
/// QR tarandıktan sonra aktif tur detaylarından erişilir.
/// Tur katılımcıları ve rehber arasında grup sohbeti sağlar.
///
/// Gerekli arguments:
/// - `tourId`: Sohbetin bağlı olduğu tur ID'si
/// - `tourTitle`: AppBar'da gösterilecek tur başlığı
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ─── Controller & State ───
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatController _chatController;

  late final String _tourId;
  late final String _tourTitle;

  /// Giriş yapmış kullanıcının bilgileri (Firebase Auth).
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _currentUserName => FirebaseAuth.instance.currentUser?.displayName ?? 'Anonim';

  // ─── Lifecycle ───

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _tourId = args['tourId']?.toString() ?? '';
    _tourTitle = args['tourTitle']?.toString() ?? 'Tur Sohbeti';

    _chatController = Get.put(ChatController());

    // Stream dinlemeyi route geçişi tamamlandıktan sonra başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.startTourChat(_tourId);
    });
  }

  @override
  void dispose() {
    // Sadece subscription iptal — reactive state değiştirme!
    // stopListening() çağrılırsa messages.clear() Obx rebuild tetikler
    // ve dispose sırasında ANR'ye neden olur.
    _chatController.cancelSubscription();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildChatArea()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ───

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: Get.back,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Sohbet ikonu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),

          // Başlık ve alt bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tourTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final count = _chatController.messages.length;
                  return Text(
                    'GRUP SOHBETİ • $count MESAJ',
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sohbet Alanı ───

  Widget _buildChatArea() {
    return Obx(() {
      if (_chatController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      if (_chatController.messages.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _chatController.messages.length,
        itemBuilder: (context, index) {
          final msg = _chatController.messages[_chatController.messages.length - 1 - index];
          final isMe = msg.senderId == _currentUserId;

          return _buildMessageBubble(
            senderName: isMe ? 'Siz' : msg.senderName,
            text: msg.text,
            time: _formatTime(msg.timestamp),
            isMe: isMe,
          );
        },
      );
    });
  }

  /// Henüz mesaj yokken gösterilen boş durum.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.slate800.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_outlined, color: AppColors.slate500, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Henüz mesaj yok',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tur grubuna ilk mesajı siz gönderin!',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Mesaj Baloncuğu ───

  Widget _buildMessageBubble({
    required String senderName,
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Gönderen adı
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 12, right: isMe ? 12 : 0, bottom: 4),
            child: Text(
              senderName,
              style: TextStyle(
                color: isMe ? AppColors.primary : AppColors.slate400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Mesaj kutusu
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.slate800.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 18),
              ),
              boxShadow: isMe
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mesaj metni
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.slate300,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Saat
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isMe ? Colors.white.withOpacity(0.5) : AppColors.slate500,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all, size: 12, color: Colors.white.withOpacity(0.6)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mesaj Giriş Alanı ───

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.slate900.withOpacity(0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.slate800),
        ),
        child: Row(
          children: [
            // Metin alanı
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Mesaj yazın...',
                  hintStyle: TextStyle(color: AppColors.slate600, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            const SizedBox(width: 8),

            // Gönder butonu
            GestureDetector(
              onTap: _handleSendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── İş Mantığı ───

  /// Mesaj gönderir. Gönderen bilgileri Firebase Auth'dan alınır.
  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_tourId.isEmpty) {
      debugPrint('Chat: tourId boş — mesaj gönderilemedi');
      return;
    }
    if (_currentUserId.isEmpty) {
      debugPrint('Chat: Kullanıcı giriş yapmamış (currentUser null)');
      return;
    }

    debugPrint(
      'Chat: Mesaj gönderiliyor → tourId=$_tourId, uid=$_currentUserId, name=$_currentUserName',
    );

    _messageController.clear();

    try {
      await _chatController.sendMessage(
        tourId: _tourId,
        text: text,
        senderName: _currentUserName,
        senderId: _currentUserId,
      );
    } catch (e) {
      debugPrint('Chat: Mesaj gönderme hatası (UI) → $e');
      Get.snackbar(
        'Hata',
        'Mesaj gönderilemedi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  /// Timestamp'i "HH:mm" formatına çevirir.
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
