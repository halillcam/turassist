import 'package:flutter/material.dart';

class GoogleIconWidget extends StatelessWidget {
  final double size;

  const GoogleIconWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: GoogleIconPainter()),
    );
  }
}

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()..color = Color(0xFF4285F4);

    // Basit Google logo temsili - mavi daire
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paintBlue);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
