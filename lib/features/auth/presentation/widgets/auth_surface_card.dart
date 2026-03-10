import 'dart:ui';

import 'package:flutter/material.dart';

/// Auth formlarının paylaştığı cam efektli yüzey.
class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
