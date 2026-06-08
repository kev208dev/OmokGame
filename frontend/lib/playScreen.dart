import 'package:flutter/material.dart';
import 'drawingBoard.dart';
import 'socket_service.dart';
import 'api_service.dart';

const int kBoardSize = 19;

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

  String get opponentName {
    final me = ApiService.username ?? '';
    final p1 = widget.matchData?['player1name'] as String? ?? '';
    final p2 = widget.matchData?['player2name'] as String? ?? '';
    if (p1 == me) return p2.isEmpty ? '상대' : p2;
    return p1.isEmpty ? '상대' : p1;
  }

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

  void onTapBoard(Offset local, double boardPx) {
    if (gameOver || myColor == null) return;
    if (turn != myColor) {
      snack('상대 차례입니다.');
      return;
    }
    final gap = boardPx / (kBoardSize - 1);
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

  Widget playerChip(String color) {
    final isMe = myColor == color;
    final name = isMe ? (ApiService.username ?? '나') : opponentName;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          color: color == 'black' ? Colors.black : Colors.white,
          size: 26,
          shadows: color == 'white'
              ? [const Shadow(color: Colors.black54, blurRadius: 2)]
              : null,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            if (isMe)
              const Text('나', style: TextStyle(fontSize: 11, color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('온라인 대국'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                playerChip('black'),
                const Text('VS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                playerChip('white'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boardPx = constraints.maxWidth;
                return GestureDetector(
                  onTapDown: (d) => onTapBoard(d.localPosition, boardPx),
                  child: CustomPaint(
                    size: Size(boardPx, boardPx),
                    painter: BoardPainter(stones: board, boardSize: kBoardSize),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: resign, child: const Text('기권')),
              ElevatedButton(onPressed: () {}, child: const Text('설정')),
            ],
          ),
        ],
      ),
    );
  }
}
