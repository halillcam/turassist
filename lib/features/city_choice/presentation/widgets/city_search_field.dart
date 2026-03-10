import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class CitySearchField extends StatelessWidget {
  const CitySearchField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white),
        decoration: const InputDecoration(
          hintText: 'Şehir ara...',
          hintStyle: TextStyle(color: AppColors.slate400),
          prefixIcon: Icon(Icons.search, color: AppColors.slate400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
