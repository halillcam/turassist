import 'package:flutter/material.dart';

import 'tour_chat_screen.dart';

class CustomerChatScreen extends StatelessWidget {
  const CustomerChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TourChatScreen(emptyMessage: 'Tur grubuna ilk mesajı siz gönderin!');
  }
}
