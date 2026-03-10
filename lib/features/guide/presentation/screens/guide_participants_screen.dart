import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../controllers/guide_participants_controller.dart';
import '../widgets/participant_list_tile.dart';
import '../widgets/participants_filter_bar.dart';
import '../widgets/participants_summary_bar.dart';

class GuideParticipantsScreen extends StatefulWidget {
  const GuideParticipantsScreen({super.key});

  @override
  State<GuideParticipantsScreen> createState() => _GuideParticipantsScreenState();
}

class _GuideParticipantsScreenState extends State<GuideParticipantsScreen> {
  late final GuideParticipantsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? const {};
    _controller = Get.put(GuideParticipantsController.createDefault());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(
        initialTourId: args['tourId']?.toString() ?? '',
        initialTourTitle: args['tourTitle']?.toString() ?? '',
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Get.delete<GuideParticipantsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Katılımcı Listesi'),
              Text(
                _controller.tourTitle.value.isEmpty
                    ? 'Atanmış tur yok'
                    : _controller.tourTitle.value,
                style: const TextStyle(fontSize: 12, color: AppColors.slate400),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            final filtered = _controller.filteredParticipants;
            return Column(
              children: [
                ParticipantsSummaryBar(
                  total: _controller.participants.length,
                  arrived: _controller.arrivedCount,
                  pending: _controller.pendingCount,
                ),
                const SizedBox(height: 12),
                ParticipantsFilterBar(
                  searchController: _searchController,
                  selectedTab: _controller.selectedTab.value,
                  totalCount: _controller.participants.length,
                  arrivedCount: _controller.arrivedCount,
                  pendingCount: _controller.pendingCount,
                  onChanged: (value) => _controller.searchQuery.value = value,
                  onTabSelected: (index) => _controller.selectedTab.value = index,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Gösterilecek katılımcı yok.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _controller.loadParticipants,
                          child: ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return ParticipantListTile(participant: filtered[index]);
                            },
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
