import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';
import 'dart:async'; // Importante: Esta librería es necesaria para la clase Timer.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = const Color(0xFFDD6DAD);
  final Color primaryDark = const Color(0xFFC7549B);
  final Color secondaryColor = const Color(0xFFE730AF);
  final Color backgroundLight = const Color(0xFFF9F4F9);
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.grey;
  final Color whiteColor = Colors.white;

  late DateTime _now;
  late Timer _timer;

  String? userRole; // 👈 Rol del usuario (Admin, Superadministrator, User)

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _now = DateTime.now());
    });

    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "USER"; // SUPERADMINISTRATOR, ADMIN, USER
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Fluttertoast.showToast(msg: "Sesión cerrada");
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final fecha = "${_now.day}/${_now.month}/${_now.year}";
    final hora =
        "${_now.hour}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Panel Principal"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerCard(fecha, hora),
              const SizedBox(height: 30),

              // 👇 Perfilado por rol
              if (userRole == "ADMIN" || userRole == "SUPERADMINISTRATOR") ...[
                _styledButton(context, "Registrar Asistencia", '/asistencias'),
                _styledButton(
                    context, "Ver Asistencias de la Semana", '/asistencias/historial'),
                _styledButton(
                    context, "Ver Monitoreo de Asistencias", '/asistencias/monitoreo'),
                _styledButton(context, "Registrar Incidencia", '/incidencias'),
                _styledButton(
                    context, "Revisión de Incidencias", '/incidencias/supervisor'),
                _styledButton(context, "Agregar Carrera", '/carreras'),
                _styledButton(context, "Agregar Usuarios", '/usuarios'),
              ] else if (userRole == "USER") ...[
                _styledButton(context, "Registrar Asistencia", '/asistencias'),
                _styledButton(
                    context, "Ver Asistencias de la Semana", '/asistencias/historial'),

                // 👇 Registrar Incidencia solo antes de las 12
                _styledButton(
                  context,
                  "Registrar Incidencia",
                  '/incidencias',
                  enabled: _now.hour < 12,
                ),
              ],

              const SizedBox(height: 30),
              _logoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard(String fecha, String hora) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "¡Bienvenido/a!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, color: textSecondary, size: 16),
              const SizedBox(width: 4),
              Text("Fecha: $fecha",
                  style: TextStyle(fontSize: 14, color: textPrimary)),
              const SizedBox(width: 12),
              Icon(Icons.access_time, color: textSecondary, size: 16),
              const SizedBox(width: 4),
              Text("Hora: $hora",
                  style: TextStyle(fontSize: 14, color: textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 22),
        label: const Text("Cerrar sesión"),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: whiteColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: () => _logout(context),
      ),
    );
  }

  // 🔹 Botón adaptable (con enabled)
  Widget _styledButton(
    BuildContext context,
    String label,
    String route, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? () => Navigator.pushNamed(context, route) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? whiteColor : Colors.grey.shade300,
            foregroundColor: enabled ? secondaryColor : Colors.grey,
            elevation: enabled ? 3 : 0,
            side: BorderSide(
              color: enabled ? secondaryColor : Colors.grey.shade400,
              width: 1.6,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
