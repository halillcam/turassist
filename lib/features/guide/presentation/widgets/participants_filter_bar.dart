import 'package:flutter/material.dart';

import '../../../../config/app_strings.dart';
import '../../../../config/colors.dart';

class ParticipantsFilterBar extends StatelessWidget {
  const ParticipantsFilterBar({
    super.key,
    required this.searchController,
    required this.selectedTab,
    required this.totalCount,
    required this.arrivedCount,
    required this.pendingCount,
    required this.onChanged,
    required this.onTabSelected,
  });

  final TextEditingController searchController;
  final int selectedTab;
  final int totalCount;
  final int arrivedCount;
  final int pendingCount;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.slate400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onChanged,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchParticipant,
                    hintStyle: TextStyle(color: AppColors.slate400, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _FilterTab(
              label: '${AppStrings.tabAll} ($totalCount)',
              isActive: selectedTab == 0,
              onTap: () => onTabSelected(0),
            ),
            const SizedBox(width: 12),
            _FilterTab(
              label: '${AppStrings.tabArrived} ($arrivedCount)',
              isActive: selectedTab == 1,
              onTap: () => onTabSelected(1),
            ),
            const SizedBox(width: 12),
            _FilterTab(
              label: '${AppStrings.tabNotArrived} ($pendingCount)',
              isActive: selectedTab == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.isActive, required this.onTap});

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.cardDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.primary : AppColors.slate700),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.slate400,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
