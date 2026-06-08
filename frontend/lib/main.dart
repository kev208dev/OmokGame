import 'package:flutter/material.dart';
import 'playScreen.dart';
import 'auth_screen.dart';
import 'socket_service.dart';
import 'api_service.dart';

void main() {
  runApp(const MaterialApp(home: AuthScreen()));
}

class OmokGame extends StatefulWidget {
  const OmokGame({super.key});
  @override
  State<OmokGame> createState() => _OmokGameState();
}

class _OmokGameState extends State<OmokGame> {
  int wins = 0;
  int losses = 0;
  bool matching = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (profile != null && mounted) {
      setState(() {
        wins = (profile['wins'] as num?)?.toInt() ?? 0;
        losses = (profile['losses'] as num?)?.toInt() ?? 0;
      });
    }
  }

  void _startMatch() {
    if (matching) return;
    setState(() => matching = true);
    final sock = SocketService.instance;
    sock.connect(
      onConnect: () {
        sock.requestMatch((data) {
          if (!mounted) return;
          setState(() => matching = false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayScreen(matchData: data)),
          ).then((_) => _loadProfile());
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => matching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('연결 실패: $e')),
        );
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('상대 찾는 중...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 30),
                    const SizedBox(width: 6),
                    Text(
                      ApiService.username ?? 'Player',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Icon(Icons.settings, size: 32),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$wins승 $losses패',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: matching ? null : _startMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  matching ? '상대 찾는 중...' : '온라인 대국하기',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
