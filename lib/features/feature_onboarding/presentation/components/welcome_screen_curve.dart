import 'package:flutter/material.dart';
import 'package:ikuku/theme/colors.dart';

class WelcomeScreenCurve extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    paint.color = orangeShade;
    paint.style = PaintingStyle.fill;

    //  paint properties
    var path = Path();

    //  creating our curve
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    //  draw path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
