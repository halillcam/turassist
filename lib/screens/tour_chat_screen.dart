import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/controllers/profile_controller.dart';

class TourChatScreen extends StatefulWidget {
  const TourChatScreen({super.key});

  @override
  _TourChatScreenState createState() => _TourChatScreenState();
}

class _TourChatScreenState extends State<TourChatScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        title: const Text(
          'Tur Sohbeti',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Announcements Section
          Obx(
            () => controller.announcements.isNotEmpty
                ? Container(
                    color: AppColors.darkCard,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📢 Duyurular',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.announcements.length,
                            itemBuilder: (context, index) {
                              final announcement = controller.announcements[index];
                              return Container(
                                width: 250,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: announcement.isUrgent
                                      ? AppColors.error.withOpacity(0.2)
                                      : AppColors.darkBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: announcement.isUrgent
                                        ? AppColors.error
                                        : AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      announcement.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      announcement.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Chat Messages
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(15),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = controller.chatMessages[index];
                  final isCurrentUser = message.senderId == 'current_user_id';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? AppColors.primary : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.senderName,
                              style: TextStyle(
                                color: isCurrentUser ? AppColors.textPrimary : AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isCurrentUser
                                    ? AppColors.textPrimary.withOpacity(0.7)
                                    : AppColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Message Input
          Container(
            color: AppColors.darkCard,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Mesaj yazın...',
                      hintStyle: TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.darkBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (messageController.text.isNotEmpty &&
                        controller.selectedTicket.value != null) {
                      controller.sendMessage(
                        tourId: controller.selectedTicket.value!.tourId,
                        userId: 'current_user_id',
                        userName: 'Current User',
                        message: messageController.text,
                      );
                      messageController.clear();
                      _scrollToBottom();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: AppColors.textPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
