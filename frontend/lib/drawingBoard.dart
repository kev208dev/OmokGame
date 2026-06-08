import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final List<List<String?>>? stones;
  BoardPainter({this.stones});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    double gap = size.width / 8;

    for (int i = 0; i < 9; i++) {
      // 가로
      canvas.drawLine(
        Offset(0, gap * i),
        Offset(size.width, gap * i),
        paint,
      );

      // 세로
      canvas.drawLine(
        Offset(gap * i, 0),
        Offset(gap * i, size.height),
        paint,
      );
    }

    final s = stones;
    if (s != null) {
      final r = gap * 0.4;
      for (int y = 0; y < s.length; y++) {
        for (int x = 0; x < s[y].length; x++) {
          final c = s[y][x];
          if (c == null) continue;
          final center = Offset(gap * x, gap * y);
          canvas.drawCircle(
            center,
            r,
            Paint()..color = c == 'black' ? Colors.black : Colors.white,
          );
          if (c == 'white') {
            canvas.drawCircle(
              center,
              r,
              Paint()
                ..color = Colors.black
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
