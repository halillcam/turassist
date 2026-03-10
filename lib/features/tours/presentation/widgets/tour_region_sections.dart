import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/tour_model.dart';
import '../../../../widgets/tour_card.dart';

class TourRegionSections extends StatelessWidget {
  const TourRegionSections({super.key, required this.groupedTours, required this.onTourTap});

  final Map<String, List<TourModel>> groupedTours;
  final ValueChanged<TourModel> onTourTap;

  @override
  Widget build(BuildContext context) {
    if (groupedTours.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'Bu şehirde henüz tur bulunmuyor',
            style: TextStyle(color: AppColors.slate400),
          ),
        ),
      );
    }

    final regions = groupedTours.keys.toList();
    return SliverList.builder(
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final tours = groupedTours[region] ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '$region Turları',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 290,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tours.length,
                itemBuilder: (context, cardIndex) {
                  final tour = tours[cardIndex];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TourCard(tour: tour, onTap: () => onTourTap(tour)),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
