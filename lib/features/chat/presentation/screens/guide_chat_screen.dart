import 'package:flutter/material.dart';

import 'tour_chat_screen.dart';

class GuideChatScreen extends StatelessWidget {
  const GuideChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TourChatScreen(emptyMessage: 'Katılımcılarla sohbete başlayın!');
  }
}
