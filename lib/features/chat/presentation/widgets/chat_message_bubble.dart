import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message, required this.currentUserId});

  final ChatMessageEntity message;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUserId;
    final bubbleColor = message.isGuideMessage
        ? AppColors.warning.withOpacity(0.28)
        : (isMe ? AppColors.primary : AppColors.slate800.withOpacity(0.8));

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isMe ? 0 : 12, right: isMe ? 12 : 0, bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMe ? 'Siz' : message.senderName,
                  style: TextStyle(
                    color: isMe ? AppColors.primary : AppColors.slate400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (message.isGuideMessage) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TUR SORUMLUSU',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 6),
                bottomRight: Radius.circular(isMe ? 6 : 18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
