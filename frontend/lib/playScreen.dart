import 'package:flutter/material.dart';
import 'drawingBoard.dart';
import 'socket_service.dart';

const int kBoardSize = 9; // 백엔드 BOARD_SIZE 와 동일
const double kBoardPx = 270; // 보드 픽셀 크기 (디자인 유지)

class PlayScreen extends StatefulWidget {
  /// match_complete payload: {roomid, player1id, player2id, player1name, player2name}
  final dynamic matchData;
  const PlayScreen({super.key, this.matchData});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _sock = SocketService.instance;

  // board[y][x] = "black" | "white" | null
  late List<List<String?>> _board;
  String _turn = 'black'; // 흑 선
  String? _myColor; // joined 이벤트로 결정
  bool _gameOver = false;

  String? get _roomId => widget.matchData?['roomid'] as String?;

  @override
  void initState() {
    super.initState();
    _board = List.generate(kBoardSize, (_) => List.filled(kBoardSize, null));
    _bindSocket();
  }

  void _bindSocket() {
    final room = _roomId;
    if (room == null) return;

    // 상대/내 착수 수신
    _sock.onChaksooed((data) {
      final x = data['x'] as int;
      final y = data['y'] as int;
      final color = data['color'] as String;
      if (!mounted) return;
      setState(() {
        _board[y][x] = color;
        _turn = color == 'black' ? 'white' : 'black';
      });
    });

    // 승패
    _sock.onGameOver((data) {
      final winner = data['winner'] as String;
      _finish(winner == _myColor ? '승리!' : '패배');
    });

    // 기권 결과
    _sock.onResigned((data) {
      final result = data['result'] as String;
      _finish(result == 'win' ? '승리! (상대 기권)' : '패배 (기권)');
    });

    // 방 입장 → 내 돌 색 수신
    _sock.join(room, (data) {
      if (!mounted) return;
      setState(() => _myColor = data['color'] as String);
    });
  }

  void _onTapBoard(Offset local) {
    if (_gameOver || _myColor == null) return;
    if (_turn != _myColor) {
      _snack('상대 차례입니다.');
      return;
    }
    final gap = kBoardPx / (kBoardSize - 1);
    final x = (local.dx / gap).round().clamp(0, kBoardSize - 1);
    final y = (local.dy / gap).round().clamp(0, kBoardSize - 1);
    if (_board[y][x] != null) return; // 이미 둔 자리

    // 서버가 검증/브로드캐스트 → chaksooed 로 보드 갱신
    _sock.chaksoo(_roomId!, x, y, _myColor!);
  }

  void _resign() {
    if (_gameOver || _myColor == null || _roomId == null) return;
    _sock.resign(_roomId!, _myColor!);
  }

  void _finish(String msg) {
    if (!mounted || _gameOver) return;
    setState(() => _gameOver = true);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _snack(String m) =>
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
            onTapDown: (d) => _onTapBoard(d.localPosition),
            child: CustomPaint(
              size: Size(kBoardPx, kBoardPx),
              painter: BoardPainter(stones: _board),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(child: Text('기권'), onPressed: _resign),
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
