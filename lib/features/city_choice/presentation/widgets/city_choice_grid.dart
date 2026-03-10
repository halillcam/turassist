import 'package:flutter/material.dart';

import '../../domain/entities/city_choice_entity.dart';
import 'city_choice_card.dart';

class CityChoiceGrid extends StatelessWidget {
  const CityChoiceGrid({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onSelect,
  });

  final List<CityChoiceEntity> cities;
  final String selectedCity;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 4,
      ),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return CityChoiceCard(
          city: city,
          isSelected: selectedCity == city.name,
          onTap: () => onSelect(city.name),
        );
      },
    );
  }
}
