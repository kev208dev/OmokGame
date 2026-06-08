import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final List<List<String?>>? stones;
  final int boardSize;
  BoardPainter({this.stones, this.boardSize = 19});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.8;

    final gap = size.width / (boardSize - 1);

    for (int i = 0; i < boardSize; i++) {
      canvas.drawLine(Offset(0, gap * i), Offset(size.width, gap * i), paint);
      canvas.drawLine(Offset(gap * i, 0), Offset(gap * i, size.height), paint);
    }

    final s = stones;
    if (s != null) {
      final r = gap * 0.42;
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
          canvas.drawCircle(
            center,
            r,
            Paint()
              ..color = Colors.black
              ..style = PaintingStyle.stroke
              ..strokeWidth = c == 'white' ? 1.2 : 0,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
