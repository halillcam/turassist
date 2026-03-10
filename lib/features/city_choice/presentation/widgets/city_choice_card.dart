import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../domain/entities/city_choice_entity.dart';

class CityChoiceCard extends StatelessWidget {
  const CityChoiceCard({
    super.key,
    required this.city,
    required this.isSelected,
    required this.onTap,
  });

  final CityChoiceEntity city;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: city.isAvailable ? onTap : null,
      child: Opacity(
        opacity: city.isAvailable ? 1 : 0.45,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (city.networkImageUrl != null)
                  Image.network(
                    city.networkImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }
                      return _buildPlaceholder();
                    },
                  )
                else
                  _buildPlaceholder(),
                Container(color: Colors.black.withOpacity(0.28)),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        city.regionName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.cardDark,
      alignment: Alignment.center,
      child: const Icon(Icons.location_city, color: AppColors.slate400, size: 28),
    );
  }
}
