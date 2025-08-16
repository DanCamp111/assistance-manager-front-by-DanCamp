import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';
import 'dart:async'; // Importante: Esta librería es necesaria para la clase Timer.

// Convertimos HomeScreen a StatefulWidget para que su estado pueda cambiar
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🎨 Colores y estilos base IMDEC
  final Color primaryColor = const Color(0xFFDD6DAD); // Rosa IMDEC
  final Color primaryDark = const Color(0xFFC7549B);
  final Color secondaryColor = const Color(0xFFE730AF);
  final Color backgroundLight = const Color(0xFFF9F4F9);
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.grey;
  final Color whiteColor = Colors.white;

  // Variables de estado para la fecha y hora
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Inicializamos la hora actual y configuramos un temporizador
    _now = DateTime.now();
    // El temporizador se ejecutará cada 1 segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Usamos setState para notificar a Flutter que la hora ha cambiado
      // y que debe redibujar la parte del widget que muestra la hora.
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    // Es CRUCIAL cancelar el temporizador cuando el widget ya no es visible
    // para evitar fugas de memoria.
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
    // Las variables de fecha y hora ahora usan el estado _now
    final fecha = "${_now.day}/${_now.month}/${_now.year}";
    final hora = "${_now.hour}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";

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
      // Se envuelve el cuerpo en un SingleChildScrollView para evitar el desbordamiento
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Alineación de los elementos al centro horizontal
            children: [
              // Contenedor para la sección de bienvenida y fecha/hora
              Container(
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
                // Se utiliza un Row para colocar la bienvenida y la fecha/hora en la misma línea
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
                        Text(
                          "Fecha: $fecha",
                          style: TextStyle(fontSize: 14, color: textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, color: textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Hora: $hora",
                          style: TextStyle(fontSize: 14, color: textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _styledButton(context, "Registrar Asistencia", '/asistencias'),
              _styledButton(
                context,
                "Ver Asistencias de la Semana",
                '/asistencias/historial',
              ),
              _styledButton(
                context,
                "Ver Monitoreo de Asistencias",
                '/asistencias/monitoreo',
              ),
              _styledButton(context, "Registrar Incidencia", '/incidencias'),
              _styledButton(
                context,
                "Revisión de Incidencias",
                '/incidencias/supervisor',
              ),
              _styledButton(context, "Agregar Carrera", '/carreras'),
              _styledButton(context, "Agregar Usuarios", '/usuarios'),
              // En vez de Spacer, utilizamos un SizedBox para controlar el espacio
              const SizedBox(height: 30),
              SizedBox(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledButton(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, route),
          style: ElevatedButton.styleFrom(
            backgroundColor: whiteColor,
            foregroundColor: secondaryColor,
            elevation: 3,
            side: BorderSide(color: secondaryColor, width: 1.6),
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
