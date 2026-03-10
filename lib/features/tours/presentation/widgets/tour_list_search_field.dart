import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class TourListSearchField extends StatelessWidget {
  const TourListSearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate800,
        border: Border.all(color: AppColors.slate700),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.white),
        decoration: const InputDecoration(
          hintText: 'Tur veya aktivite ara...',
          hintStyle: TextStyle(color: AppColors.slate400),
          prefixIcon: Icon(Icons.search, color: AppColors.slate400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    );
  }
}
