import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_message_bubble.dart';

class TourChatScreen extends StatefulWidget {
  const TourChatScreen({super.key, required this.emptyMessage});

  final String emptyMessage;

  @override
  State<TourChatScreen> createState() => _TourChatScreenState();
}

class _TourChatScreenState extends State<TourChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _controllerTag;
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    final tourId = args['tourId']?.toString() ?? '';
    final tourTitle = args['tourTitle']?.toString() ?? 'Tur Sohbeti';
    _controllerTag = 'tour-chat-${DateTime.now().microsecondsSinceEpoch}';
    _controller = Get.put(ChatController.createDefault(), tag: _controllerTag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(chatTourId: tourId, chatTourTitle: tourTitle);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    Get.delete<ChatController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => ChatAppBar(
                title: _controller.tourTitle.value,
                messageCount: _controller.messages.length,
              ),
            ),
            Expanded(child: Obx(_buildBody)),
            Obx(
              () => ChatComposer(
                controller: _messageController,
                isSending: _controller.isSending.value,
                onSend: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_controller.errorMessage.value.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_controller.messages.isEmpty) {
      return ChatEmptyState(message: widget.emptyMessage);
    }

    final currentUserId = _controller.sender.value?.userId ?? '';
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _controller.messages.length,
      itemBuilder: (context, index) {
        final message = _controller.messages[_controller.messages.length - 1 - index];
        return ChatMessageBubble(message: message, currentUserId: currentUserId);
      },
    );
  }

  Future<void> _handleSend() async {
    final draft = _messageController.text;
    await _controller.sendMessage(draft);
    if (draft.trim().isEmpty) {
      return;
    }
    _messageController.clear();
  }
}
