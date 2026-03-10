import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/models/ticket_model.dart';
import '../../../../core/models/tour_model.dart';
import '../../../../core/models/tour_program_model.dart';
import '../../data/repositories/tours_repository_impl.dart';
import '../../domain/usecases/cancel_ticket_use_case.dart';
import '../../domain/usecases/check_in_ticket_use_case.dart';
import '../../domain/usecases/get_my_tickets_use_case.dart';
import '../../domain/usecases/watch_my_tickets_use_case.dart';

class MyToursController extends GetxController {
  MyToursController({
    GetMyTicketsUseCase? getMyTicketsUseCase,
    WatchMyTicketsUseCase? watchMyTicketsUseCase,
    CancelTicketUseCase? cancelTicketUseCase,
    CheckInTicketUseCase? checkInTicketUseCase,
  }) : _repository = ToursRepositoryImpl(),
       _getMyTicketsUseCase = getMyTicketsUseCase ?? GetMyTicketsUseCase(ToursRepositoryImpl()),
       _watchMyTicketsUseCase =
           watchMyTicketsUseCase ?? WatchMyTicketsUseCase(ToursRepositoryImpl()),
       _cancelTicketUseCase = cancelTicketUseCase ?? CancelTicketUseCase(ToursRepositoryImpl()),
       _checkInTicketUseCase = checkInTicketUseCase ?? CheckInTicketUseCase(ToursRepositoryImpl());

  final ToursRepositoryImpl _repository;
  final GetMyTicketsUseCase _getMyTicketsUseCase;
  final WatchMyTicketsUseCase _watchMyTicketsUseCase;
  final CancelTicketUseCase _cancelTicketUseCase;
  final CheckInTicketUseCase _checkInTicketUseCase;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxMap<String, TourModel> ticketTours = <String, TourModel>{}.obs;
  final RxInt selectedTab = 0.obs;
  final Rxn<TicketModel> checkedInTicket = Rxn<TicketModel>();
  final Rxn<TourModel> activeTour = Rxn<TourModel>();
  final RxList<TourProgramDay> programDays = <TourProgramDay>[].obs;

  StreamSubscription<List<TicketModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _subscription = _watchMyTicketsUseCase.execute().listen((items) async {
      tickets.assignAll(items);
      await _refreshTicketTours(items);
      _evaluateCheckedInState();
      isLoading.value = false;
    });
    ever<List<TicketModel>>(tickets, (_) => _evaluateCheckedInState());
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  bool get hasCheckedIn => checkedInTicket.value != null;

  List<TicketModel> get upcomingTickets =>
      tickets.where((ticket) => ticket.status == 'active' && !_isPastTicket(ticket)).toList();
  List<TicketModel> get pastTickets => tickets.where(_isPastTicket).toList();

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loadedTickets = await _getMyTicketsUseCase.execute();
      tickets.assignAll(loadedTickets);
      await _refreshTicketTours(loadedTickets);
      _evaluateCheckedInState();
    } catch (_) {
      errorMessage.value = 'Veriler yüklenirken hata oluştu.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshTicketTours(List<TicketModel> sourceTickets) async {
    for (final ticket in sourceTickets) {
      final tour = await _repository.getTourById(ticket.tourId);
      if (tour == null) {
        ticketTours.remove(ticket.tourId);
      } else {
        ticketTours[ticket.tourId] = tour;
      }
    }
  }

  bool _isTicketCheckedIn(TicketModel ticket) {
    if (!ticket.isScanned) return false;
    final cachedTour = ticketTours[ticket.tourId];
    if (cachedTour?.isDeleted == true) return false;
    return true;
  }

  bool _isPastTicket(TicketModel ticket) {
    final status = ticket.status.toLowerCase();
    final cachedTour = ticketTours[ticket.tourId];
    if (status == 'completed' || status == 'cancelled') return true;
    if (status == 'checked_in' && !ticket.isScanned) return true;
    if (cachedTour?.isDeleted == true) return true;
    return false;
  }

  void _evaluateCheckedInState() {
    final checkedIn = tickets.where(_isTicketCheckedIn).toList();
    if (checkedIn.isEmpty) {
      checkedInTicket.value = null;
      activeTour.value = null;
      programDays.clear();
      return;
    }

    final incoming = checkedIn.first;
    checkedInTicket.value = incoming;
    _loadActiveTourDetail(incoming.tourId);
  }

  Future<void> _loadActiveTourDetail(String tourId) async {
    final tour = await _repository.getTourById(tourId);
    if (tour == null || tour.isDeleted) {
      checkedInTicket.value = null;
      activeTour.value = null;
      programDays.clear();
      return;
    }
    ticketTours[tourId] = tour;
    activeTour.value = tour;
    programDays.assignAll(await _repository.getTourProgram(tourId));
  }

  Future<bool> cancelUpcomingTicket(TicketModel ticket) async {
    final success = await _cancelTicketUseCase.execute(ticket.id);
    if (success) {
      await loadData();
    }
    return success;
  }

  Future<bool> checkInTicket(TicketModel ticket) async {
    final success = await _checkInTicketUseCase.execute(ticket.id);
    if (!success) {
      final fallback = await _repository.updateTicketStatus(ticket.id, 'checked_in');
      if (!fallback) {
        return false;
      }
    }
    await loadData();
    return true;
  }

  void backToTicketList() {
    checkedInTicket.value = null;
    activeTour.value = null;
    programDays.clear();
  }
}
