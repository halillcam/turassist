import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/tour_model.dart';
import '../controllers/tour_detail_controller.dart';

class TourDetailBody extends StatelessWidget {
  const TourDetailBody({super.key, required this.controller, required this.tour});

  final TourDetailController controller;
  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroImage(tour: tour),
              _InfoCard(tour: tour, controller: controller),
              _AboutSection(tour: tour, controller: controller),
              _ProgramSection(controller: controller),
              if (tour.extraDetail.trim().isNotEmpty) _ExtrasSection(extraDetail: tour.extraDetail),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.tour});

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          tour.imageUrl.isNotEmpty
              ? Image.network(
                  tour.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.slate800,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.slate500,
                      size: 48,
                    ),
                  ),
                )
              : Container(
                  color: AppColors.slate800,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.slate500,
                    size: 48,
                  ),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.backgroundDark.withOpacity(0.82)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.tour, required this.controller});

  final TourModel tour;
  final TourDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate800),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                tour.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: AppColors.slate800),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoColumn(
                      icon: Icons.group,
                      label: 'KAPASİTE',
                      value: '${tour.capacity} Kişi',
                    ),
                  ),
                  Container(width: 1, height: 60, color: AppColors.slate800),
                  Expanded(
                    child: Obx(
                      () => _InfoColumn(
                        icon: Icons.business,
                        label: 'TUR FİRMASI',
                        value: controller.companyName.value.trim().isEmpty
                            ? 'Firma bilgisi yok'
                            : controller.companyName.value.trim(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate500,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.tour, required this.controller});

  final TourModel tour;
  final TourDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tur Hakkında',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Text(
                tour.description,
                style: const TextStyle(color: AppColors.slate400, fontSize: 14, height: 1.6),
                maxLines: controller.isDescriptionExpanded.value ? null : 5,
                overflow: controller.isDescriptionExpanded.value ? null : TextOverflow.ellipsis,
              ),
            ),
            if (tour.description.length > 150)
              Obx(
                () => GestureDetector(
                  onTap: controller.toggleDescription,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.isDescriptionExpanded.value
                              ? 'Daha az göster'
                              : 'Daha fazla oku',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          controller.isDescriptionExpanded.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgramSection extends StatelessWidget {
  const _ProgramSection({required this.controller});

  final TourDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.slate800),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.route_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tur Programı',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isProgramLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  );
                }
                if (controller.programDays.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.slate800.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Henüz program eklenmemiş.',
                      style: TextStyle(color: AppColors.slate500, fontSize: 14),
                    ),
                  );
                }
                return Column(
                  children: controller.programDays.map((day) {
                    final isLast = day == controller.programDays.last;
                    return _ProgramDayItem(
                      dayTitle: day.title,
                      activities: day.activities,
                      day: day.day,
                      isLast: isLast,
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramDayItem extends StatelessWidget {
  const _ProgramDayItem({
    required this.dayTitle,
    required this.activities,
    required this.day,
    required this.isLast,
  });

  final String dayTitle;
  final List<String> activities;
  final int day;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 126,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: AppColors.slate700,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.slate900.withOpacity(0.38),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      dayTitle,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...activities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.slate400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              activity,
                              style: const TextStyle(
                                color: AppColors.slate300,
                                fontSize: 13,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExtrasSection extends StatelessWidget {
  const _ExtrasSection({required this.extraDetail});

  final String extraDetail;

  @override
  Widget build(BuildContext context) {
    final extras = extraDetail
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tur Ekstraları',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate800),
              ),
              child: extras.length > 1
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: extras
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        color: AppColors.slate300,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Text(
                      extraDetail,
                      style: const TextStyle(color: AppColors.slate300, fontSize: 14, height: 1.6),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
