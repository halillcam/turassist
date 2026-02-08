import 'package:flutter/material.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/models/tour_model.dart';

class TourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback? onTap;

  const TourCard({Key? key, required this.tour, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.slate800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate700.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tour image
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: tour.imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(tour.imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: tour.imageUrl.isEmpty
                    ? Container(
                        color: AppColors.slate700,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.slate500,
                            size: 32,
                          ),
                        ),
                      )
                    : null,
              ),
              // Tour info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        tour.title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        '₺${tour.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        tour.description,
                        style: const TextStyle(color: AppColors.slate400, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Capacity
                      Row(
                        children: [
                          const Icon(Icons.group, color: AppColors.slate400, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Maks ${tour.capacity} Kişi',
                              style: const TextStyle(
                                color: AppColors.slate400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
