import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class CityChoiceHeader extends StatelessWidget {
  const CityChoiceHeader({super.key, required this.searchField});

  final Widget searchField;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.backgroundDark.withOpacity(0.72),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Şehir Seçin',
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              searchField,
            ],
          ),
        ),
      ),
    );
  }
}
