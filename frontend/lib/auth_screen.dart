import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';

/// 로그인 / 회원가입 화면. 로그인 성공 시 OmokGame 으로 이동.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit(bool isLogin) async {
    final id = _idCtrl.text.trim();
    final pw = _pwCtrl.text.trim();
    if (id.isEmpty || pw.isEmpty) {
      _toast('아이디와 비밀번호를 입력하세요.');
      return;
    }
    setState(() => _loading = true);
    final (ok, msg) = isLogin
        ? await ApiService.login(id, pw)
        : await ApiService.register(id, pw);
    if (!mounted) return;
    setState(() => _loading = false);
    _toast(msg);
    if (ok && isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OmokGame()),
      );
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('오목',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                  labelText: '아이디', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submit(true),
                      child: const Text('로그인'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _submit(false),
                      child: const Text('회원가입'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }
}
