class GuideDashboardEntity {
  const GuideDashboardEntity({
    required this.guideId,
    required this.guideName,
    required this.isGuideUser,
    this.tourId = '',
    this.tourTitle = '',
    this.companyId = '',
    this.totalParticipants = 0,
    this.checkedInParticipants = 0,
    this.assignedSlotId,
    this.hasPendingCompletionRequest = false,
  });

  final String guideId;
  final String guideName;
  final bool isGuideUser;
  final String tourId;
  final String tourTitle;
  final String companyId;
  final int totalParticipants;
  final int checkedInParticipants;
  final String? assignedSlotId;
  final bool hasPendingCompletionRequest;

  int get pendingParticipants {
    final pending = totalParticipants - checkedInParticipants;
    return pending < 0 ? 0 : pending;
  }

  double get progress {
    if (totalParticipants <= 0) {
      return 0;
    }
    final value = checkedInParticipants / totalParticipants;
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  bool get hasAssignedTour => tourId.trim().isNotEmpty;
}
