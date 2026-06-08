import 'package:flutter/material.dart';
import 'drawingBoard.dart';
import 'socket_service.dart';

const int kBoardSize = 9;
const double kBoardPx = 270;

class PlayScreen extends StatefulWidget {
  final dynamic matchData;
  const PlayScreen({super.key, this.matchData});

  @override
  State<PlayScreen> createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> {
  final sock = SocketService.instance;

  late List<List<String?>> board;
  String turn = 'black';
  String? myColor;
  bool gameOver = false;

  String? get roomId => widget.matchData?['roomid'] as String?;

  @override
  void initState() {
    super.initState();
    board = List.generate(kBoardSize, (_) => List.filled(kBoardSize, null));
    bindSocket();
  }

  void bindSocket() {
    final room = roomId;
    if (room == null) return;

    sock.onChaksooed((data) {
      final x = data['x'] as int;
      final y = data['y'] as int;
      final color = data['color'] as String;
      if (!mounted) return;
      setState(() {
        board[y][x] = color;
        turn = color == 'black' ? 'white' : 'black';
      });
    });

    sock.onGameOver((data) {
      final winner = data['winner'] as String;
      finish(winner == myColor ? '승리!' : '패배');
    });

    sock.onResigned((data) {
      final result = data['result'] as String;
      finish(result == 'win' ? '승리! (상대 기권)' : '패배 (기권)');
    });

    sock.join(room, (data) {
      if (!mounted) return;
      setState(() => myColor = data['color'] as String);
    });
  }

  void onTapBoard(Offset local) {
    if (gameOver || myColor == null) return;
    if (turn != myColor) {
      snack('상대 차례입니다.');
      return;
    }
    final gap = kBoardPx / (kBoardSize - 1);
    final x = (local.dx / gap).round().clamp(0, kBoardSize - 1);
    final y = (local.dy / gap).round().clamp(0, kBoardSize - 1);
    if (board[y][x] != null) return;

    sock.chaksoo(roomId!, x, y, myColor!);
  }

  void resign() {
    if (gameOver || myColor == null || roomId == null) return;
    sock.resign(roomId!, myColor!);
  }

  void finish(String msg) {
    if (!mounted || gameOver) return;
    setState(() => gameOver = true);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('온라인 대국'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, color: Colors.black, size: 30),
                  Text('흑', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(width: 10),
                  Text('YOU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                ],
              ),
              Text(
                '1:30',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 30,
                    shadows: [Shadow(color: Colors.black, blurRadius: 1)],
                  ),
                  Text('백', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  SizedBox(width: 10),
                  Text('오목의 신', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTapDown: (d) => onTapBoard(d.localPosition),
            child: CustomPaint(
              size: Size(kBoardPx, kBoardPx),
              painter: BoardPainter(stones: board),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(child: Text('기권'), onPressed: resign),
              ElevatedButton(child: Text('설정'), onPressed: () {}),
              ElevatedButton(child: Text('채팅'), onPressed: () {}),
              ElevatedButton(child: Text('기보'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
