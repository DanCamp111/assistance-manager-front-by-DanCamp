import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Fluttertoast.showToast(msg: "Sesión cerrada");
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fecha = "${now.day}/${now.month}/${now.year}";
    final hora = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("¡Bienvenido/a!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text("Fecha: $fecha"),
            Text("Hora: $hora"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/asistencias'),
              child: const Text("Registrar Asistencia"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/asistencias/historial'),
              child: const Text("Ver Asistencias de la Semana"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/incidencias'),
              child: const Text("Ver Incidencias"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/reportes'),
              child: const Text("Generar Reporte"),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _logout(context),
              child: const Text("Cerrar sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
