import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/tour_model.dart';
import '../controllers/my_tours_controller.dart';
import '../controllers/tour_detail_controller.dart';
import '../widgets/tour_detail_body.dart';
import '../widgets/tour_detail_bottom_bar.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.toursInSeries});

  final List<TourModel> toursInSeries;

  TourModel get displayTour => toursInSeries.first;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late final TourDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(TourDetailController(), tag: widget.displayTour.id);
    _controller.loadTourContext(widget.displayTour);
  }

  @override
  void dispose() {
    Get.delete<TourDetailController>(tag: widget.displayTour.id);
    super.dispose();
  }

  Future<void> _reserve() async {
    if (Get.isRegistered<MyToursController>()) {
      Get.delete<MyToursController>();
    }
    await _controller.reserve(widget.toursInSeries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          TourDetailBody(controller: _controller, tour: widget.displayTour),
          TourDetailBottomBar(
            tour: widget.displayTour,
            controller: _controller,
            onReserve: _reserve,
          ),
        ],
      ),
    );
  }
}
