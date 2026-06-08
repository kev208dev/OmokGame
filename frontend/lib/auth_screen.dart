import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final idCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  bool loading = false;

  Future<void> submit(bool isLogin) async {
    final id = idCtrl.text.trim();
    final pw = pwCtrl.text.trim();
    if (id.isEmpty || pw.isEmpty) {
      toast('아이디와 비밀번호를 입력하세요.');
      return;
    }
    setState(() => loading = true);
    final (ok, msg) = isLogin
        ? await ApiService.login(id, pw)
        : await ApiService.register(id, pw);
    if (!mounted) return;
    setState(() => loading = false);
    toast(msg);
    if (ok && isLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OmokGame()),
      );
    }
  }

  void toast(String m) =>
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
              controller: idCtrl,
              decoration: const InputDecoration(
                  labelText: '아이디', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            if (loading)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => submit(true),
                      child: const Text('로그인'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => submit(false),
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
    idCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }
}
