import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Auth ekranlarının ortak arka plan ve yerleşim şablonu.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.showBackButton = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  static const String backgroundImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAEguWPisfnT_X33mMr6kxaDGyh7ETatkfoerLRdOhHquvoz3v8SqwlcJLO_aQLBpcnlI12Z-aIGHXwtwNXtPsYUl37S2oS_UABCvjTvs2IcHMul2t0xMptYFhCCN2AnqsqviOFEqsanRRw5D-GD5VlV3yoGrT1D6Om4oxmPo59B7MQR6MOuuTeh5oPDhbLx87BxiLP9CDxd-D7J-0Lvyh90cCvis7IoTDz0rt0P_YoN0YNZ2j9hui_2pYSTwbWxEAMFTgh9iZbRTpt';

  final Widget child;
  final bool showBackButton;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(image: NetworkImage(backgroundImageUrl), fit: BoxFit.cover),
              ),
              child: Container(color: Colors.black.withOpacity(0.68)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: padding,
                child: Column(
                  children: [
                    if (showBackButton)
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: Get.back,
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        ),
                      ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
