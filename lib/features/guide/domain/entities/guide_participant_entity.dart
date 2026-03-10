class GuideParticipantEntity {
  const GuideParticipantEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.arrived,
  });

  final String id;
  final String name;
  final String subtitle;
  final bool arrived;
}
