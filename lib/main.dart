import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imdec_front/screens/asistencias/asistencia_form_screen.dart';
import 'package:imdec_front/screens/asistencias/historial_asistencia_screen.dart';
import 'package:imdec_front/screens/asistencias/monitoreo_asistencias_screen.dart';
import 'package:imdec_front/screens/incidencias/incidencia_form_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMDEC Asistencias',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/asistencias': (context) => const AsistenciaFormScreen(),
        '/asistencias/historial': (context) => const HistorialAsistenciaScreen(),
        '/asistencias/monitoreo': (context) => const MonitoreoAsistenciasScreen(),
        '/incidencias': (context) => const IncidenciaFormScreen(),
      },
    );
  }
}
