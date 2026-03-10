import 'package:get/get.dart';

import '../../data/repositories/guide_repository_impl.dart';
import '../../domain/entities/guide_participant_entity.dart';
import '../../domain/usecases/get_guide_dashboard_use_case.dart';
import '../../domain/usecases/get_guide_participants_use_case.dart';

class GuideParticipantsController extends GetxController {
  GuideParticipantsController({
    required GetGuideDashboardUseCase getGuideDashboardUseCase,
    required GetGuideParticipantsUseCase getGuideParticipantsUseCase,
  }) : _getGuideDashboardUseCase = getGuideDashboardUseCase,
       _getGuideParticipantsUseCase = getGuideParticipantsUseCase;

  factory GuideParticipantsController.createDefault() {
    final repository = GuideRepositoryImpl();
    return GuideParticipantsController(
      getGuideDashboardUseCase: GetGuideDashboardUseCase(repository),
      getGuideParticipantsUseCase: GetGuideParticipantsUseCase(repository),
    );
  }

  final GetGuideDashboardUseCase _getGuideDashboardUseCase;
  final GetGuideParticipantsUseCase _getGuideParticipantsUseCase;

  final RxBool isLoading = true.obs;
  final RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString tourId = ''.obs;
  final RxString tourTitle = ''.obs;
  final RxList<GuideParticipantEntity> participants = <GuideParticipantEntity>[].obs;

  Future<void> initialize({String initialTourId = '', String initialTourTitle = ''}) async {
    tourId.value = initialTourId.trim();
    tourTitle.value = initialTourTitle.trim();
    if (tourId.value.isEmpty || tourTitle.value.isEmpty) {
      final dashboard = await _getGuideDashboardUseCase.execute();
      if (tourId.value.isEmpty) {
        tourId.value = dashboard.tourId;
      }
      if (tourTitle.value.isEmpty) {
        tourTitle.value = dashboard.tourTitle;
      }
    }
    await loadParticipants();
  }

  Future<void> loadParticipants() async {
    isLoading.value = true;
    try {
      final items = await _getGuideParticipantsUseCase.execute(tourId: tourId.value);
      participants.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  List<GuideParticipantEntity> get filteredParticipants {
    var items = participants.toList();
    if (selectedTab.value == 1) {
      items = items.where((participant) => participant.arrived).toList();
    }
    if (selectedTab.value == 2) {
      items = items.where((participant) => !participant.arrived).toList();
    }
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }
    return items.where((participant) {
      return participant.name.toLowerCase().contains(query) ||
          participant.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  int get arrivedCount => participants.where((participant) => participant.arrived).length;

  int get pendingCount => participants.where((participant) => !participant.arrived).length;
}
