import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/app_routes.dart';
import 'package:turassist/config/colors.dart';
import 'package:turassist/widgets/index.dart';

class MyQrScreen extends StatelessWidget {
  const MyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("QR'larım", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: const SafeArea(child: SizedBox.shrink()),
    );
  }
}
