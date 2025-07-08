import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final authService = AuthService();

  void _login() async {
    final success = await authService.login(correoCtrl.text, passCtrl.text);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(msg: 'Correo o contraseña incorrectos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: correoCtrl, decoration: InputDecoration(labelText: 'Correo')),
            TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Contraseña')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}
