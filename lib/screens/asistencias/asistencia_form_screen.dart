import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imdec_front/models/asistencia_dto.dart';
import 'package:imdec_front/screens/home/home_screen.dart';
import 'package:imdec_front/services/asistencia_service.dart';

class AsistenciaFormScreen extends StatefulWidget {
  const AsistenciaFormScreen({super.key});

  @override
  State<AsistenciaFormScreen> createState() => _AsistenciaFormScreenState();
}

class _AsistenciaFormScreenState extends State<AsistenciaFormScreen> {
  String _tipo = 'entrada';
  late TextEditingController _fechaCtrl;
  late TextEditingController _horaCtrl;
  PlatformFile? _file;
  String _nombreCompleto = '';
  String _carrera = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaCtrl = TextEditingController(
        text:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");
    _horaCtrl = TextEditingController(
        text:
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}");
    
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener datos del usuario desde la API
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/usuarios/$usuarioId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final usuarioData = jsonDecode(response.body);
        final carreraId = usuarioData['carrera_id'];
        
        String carreraNombre = 'No especificada';
        if (carreraId != null) {
          final carreraResponse = await http.get(
            Uri.parse('${dotenv.env['API_URL']}/carreras/$carreraId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          );

          if (carreraResponse.statusCode == 200) {
            final carreraData = jsonDecode(carreraResponse.body);
            carreraNombre = carreraData['nombre'];
          }
        }

        setState(() {
          _nombreCompleto = '${usuarioData['nombre']} ${usuarioData['apellido_paterno']} ${usuarioData['apellido_materno']}';
          _carrera = carreraNombre;
          _loading = false;
        });
      } else {
        throw Exception('Error al obtener datos del usuario');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al cargar datos: ${e.toString()}");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (token == null || usuarioId == null) {
      Fluttertoast.showToast(msg: "Usuario no autenticado");
      return;
    }

    if (_file == null) {
      Fluttertoast.showToast(msg: "Debes seleccionar una foto");
      return;
    }

    try {
      final asistencia = AsistenciaDTO(
        usuarioId: usuarioId,
        tipoRegistro: _tipo,
        fechaRegistro: _fechaCtrl.text,
        horaExacta: _horaCtrl.text,
        fotoRegistro: null,
      );

      final creada = await AsistenciaService().createAsistencia(asistencia);
      final fotoUrl = await AsistenciaService().subirFoto(creada.id!, _file!);

      if (fotoUrl != null) {
        _mostrarDialogoExito();
      } else {
        throw Exception('Error al subir la foto');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline, 
                  color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                "¡Registro exitoso!",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Tu asistencia ha sido registrada correctamente.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen()
                  ),
                  (route) => false,
                );
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Asistencia"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre completo
            const Text(
              "Nombre completo *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 16
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(_nombreCompleto),
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Carrera
            const Text(
              "Carrera *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 16
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(_carrera),
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo de registro
            const Text(
              "Tipo de registro *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<String>(
                  value: 'entrada',
                  groupValue: _tipo,
                  onChanged: (value) {
                    setState(() {
                      _tipo = value!;
                    });
                  },
                ),
                const Text("Entrada"),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'salida',
                  groupValue: _tipo,
                  onChanged: (value) {
                    setState(() {
                      _tipo = value!;
                    });
                  },
                ),
                const Text("Salida"),
              ],
            ),
            const SizedBox(height: 16),
            
            // Fecha
            const Text(
              "Fecha *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 16
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(_fechaCtrl.text),
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Hora
            const Text(
              "Hora *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 16
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(_horaCtrl.text),
                  const Spacer(),
                  const Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Subir foto
            const Text(
              "Sube tu foto (rostro, vestimenta, lugar y equipo) *",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _file != null ? _file!.name : "Examinar...",
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            if (_file == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Ningún archivo seleccionado.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            
            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 243, 33, 152),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "GUARDAR ASISTENCIA",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }
}