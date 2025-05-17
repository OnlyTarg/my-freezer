import 'package:flutter/material.dart';
import 'dart:math' as math;

class SnowflakePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final Offset? tapPosition;

  SnowflakePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.tapPosition,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SnowflakeTransition(
      animation: animation,
      tapPosition: tapPosition,
      child: child,
    );
  }
}

class _SnowflakeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset? tapPosition;

  const _SnowflakeTransition({
    required this.animation,
    required this.child,
    this.tapPosition,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final startPosition =
        tapPosition ?? Offset(screenSize.width / 2, screenSize.height / 2);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Сніжинка, що розкривається
            Positioned(
              left: startPosition.dx - (100 * animation.value),
              top: startPosition.dy - (100 * animation.value),
              child: Transform.scale(
                scale: animation.value * 2,
                child: Opacity(
                  opacity: 1 - animation.value,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: SnowflakePainter(
                      color: Colors.blue[100]!.withOpacity(0.8),
                      rotation: animation.value * math.pi * 4,
                      strokeWidth: 3.0,
                    ),
                  ),
                ),
              ),
            ),
            // Нова сторінка, що з'являється
            Opacity(
              opacity: animation.value,
              child: child,
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class SnowflakePainter extends CustomPainter {
  final Color color;
  final double rotation;
  final double strokeWidth;

  SnowflakePainter({
    required this.color,
    required this.rotation,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Малюємо основні гілки сніжинки
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + rotation;
      final endPoint = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      // Основна гілка
      canvas.drawLine(center, endPoint, paint);

      // Бічні гілки
      final sideAngle1 = angle + math.pi / 6;
      final sideAngle2 = angle - math.pi / 6;
      final sideLength = radius * 0.4;

      final sidePoint1 = Offset(
        center.dx + math.cos(sideAngle1) * sideLength,
        center.dy + math.sin(sideAngle1) * sideLength,
      );
      final sidePoint2 = Offset(
        center.dx + math.cos(sideAngle2) * sideLength,
        center.dy + math.sin(sideAngle2) * sideLength,
      );

      canvas.drawLine(center, sidePoint1, paint);
      canvas.drawLine(center, sidePoint2, paint);

      // Додаткові деталі на кінцях гілок
      final detailLength = radius * 0.2;
      final detailPoint1 = Offset(
        endPoint.dx + math.cos(sideAngle1) * detailLength,
        endPoint.dy + math.sin(sideAngle1) * detailLength,
      );
      final detailPoint2 = Offset(
        endPoint.dx + math.cos(sideAngle2) * detailLength,
        endPoint.dy + math.sin(sideAngle2) * detailLength,
      );

      canvas.drawLine(endPoint, detailPoint1, paint);
      canvas.drawLine(endPoint, detailPoint2, paint);
    }

    // Малюємо центр сніжинки
    canvas.drawCircle(center, 6, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(SnowflakePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.rotation != rotation ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
