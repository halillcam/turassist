import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';

class TourManagerChatScreen extends StatefulWidget {
  const TourManagerChatScreen({super.key});

  @override
  State<TourManagerChatScreen> createState() => _TourManagerChatScreenState();
}

class _TourManagerChatScreenState extends State<TourManagerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Şablon mesajlar
  final List<_ChatMessage> _messages = [
    _ChatMessage(sender: 'Ahmet Yılmaz', text: '', time: '14:22', isMe: false),
    _ChatMessage(sender: 'Siz (Mert Demir)', text: '', time: '14:25', isMe: true),
    _ChatMessage(sender: 'Canan Özkan', text: '', time: '14:30', isMe: false, badge: 'REHBER'),
    _ChatMessage(sender: 'Zeynep Kaya', text: '', time: '14:32', isMe: false),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  // ── App Bar ──
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          // Geri butonu
          GestureDetector(
            onTap: () => Get.back(),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kapadokya Turu',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'GRUP SOHBETİ • 12 KATILIMCI',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Area ──
  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length + 1, // +1 for date header
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateHeader();
        }
        final msg = _messages[index - 1];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildDateHeader() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.slate800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'BUGÜN',
          style: TextStyle(
            color: AppColors.slate400,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 12, right: isMe ? 12 : 0, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.sender,
                  style: TextStyle(
                    color: isMe ? AppColors.primary : AppColors.slate400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (msg.badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      msg.badge!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Message bubble
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Placeholder content area
                Container(
                  height: 14,
                  width: 180,
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withOpacity(0.15)
                        : AppColors.slate700.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.slate700.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.time,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ──
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
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
            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Mesaj yazın...',
                  hintStyle: TextStyle(color: AppColors.slate600, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: () {
                // TODO: Send message
              },
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
                child: const Icon(Icons.send, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;
  final String? badge;

  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    this.badge,
  });
}
