import 'package:flutter/material.dart';
import 'playScreen.dart';
import 'auth_screen.dart';
import 'socket_service.dart';
import 'api_service.dart';

void main() {
  runApp(const MaterialApp(home: AuthScreen()));
}

class OmokGame extends StatelessWidget {
  const OmokGame({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 60), // 상단 여백
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_circle, size: 30),
                    Text(
                      ApiService.username ?? 'Player1',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.settings, size: 32),
              ],
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 소켓 연결 후 매칭 요청. 매칭되면 대국 화면으로 이동.
                  final sock = SocketService.instance;
                  sock.connect(
                    onConnect: () {
                      sock.requestMatch((data) {
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayScreen(matchData: data),
                          ),
                        );
                      });
                    },
                    onError: (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('연결 실패: $e')),
                      );
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('상대 찾는 중...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              
                child: Text('온라인 대국하기',
                    style: TextStyle(fontSize: 20, ),
              ),
            ),
        ),],
        ),
      ),
    );
  }
}
