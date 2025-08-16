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
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
    );
    _horaCtrl = TextEditingController(
      text:
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
    );

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
          _nombreCompleto =
              '${usuarioData['nombre']} ${usuarioData['apellido_paterno']} ${usuarioData['apellido_materno']}';
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
              Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                "¡Registro exitoso!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "Tu asistencia ha sido registrada correctamente.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Colores base IMDEC
    final Color primaryColor = const Color.fromARGB(255, 221, 109, 173); // Rosa/violeta IMDEC
    final Color primaryDark = const Color(0xFFC7549B);
    final Color backgroundLight = const Color(0xFFF9F4F9); // Muy claro
    final Color borderGray = Colors.grey.shade300;
    final Color textPrimary = Colors.black87;
    final Color textSecondary = Colors.grey.shade700;

    TextStyle labelStyle = TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: primaryDark,
      letterSpacing: 0.5,
    );

    BoxDecoration containerBox = BoxDecoration(
      border: Border.all(color: borderGray),
      borderRadius: BorderRadius.circular(12),
      color: backgroundLight,
      boxShadow: [
        BoxShadow(
          color: borderGray.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );

    EdgeInsets fieldPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 22,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registro de Asistencia",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildLabel("Nombre completo *", labelStyle),
            buildReadOnlyField(_nombreCompleto, containerBox, fieldPadding, textPrimary),

            buildLabel("Carrera *", labelStyle),
            buildReadOnlyField(_carrera, containerBox, fieldPadding, textPrimary),

            buildLabel("Tipo de registro *", labelStyle),
            Row(
              children: [
                Radio<String>(
                  value: 'entrada',
                  groupValue: _tipo,
                  activeColor: primaryColor,
                  onChanged: (value) => setState(() => _tipo = value!),
                ),
                Text(
                  "Entrada",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(width: 30),
                Radio<String>(
                  value: 'salida',
                  groupValue: _tipo,
                  activeColor: primaryColor,
                  onChanged: (value) => setState(() => _tipo = value!),
                ),
                Text(
                  "Salida",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),

            buildLabel("Fecha *", labelStyle),
            buildReadOnlyField(_fechaCtrl.text, containerBox, fieldPadding, textPrimary),

            buildLabel("Hora *", labelStyle),
            buildReadOnlyField(_horaCtrl.text, containerBox, fieldPadding, textPrimary),

            buildLabel(
              "Sube tu foto (rostro, vestimenta, lugar y equipo) *",
              labelStyle,
            ),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file_outlined, size: 26),
              label: Text(
                _file != null ? _file!.name : "Examinar...",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 58),
                backgroundColor: backgroundLight,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: primaryColor, width: 2),
                ),
                elevation: 0,
              ),
            ),
            if (_file == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Ningún archivo seleccionado.",
                  style: TextStyle(color: textSecondary, fontSize: 15),
                ),
              ),
            const SizedBox(height: 38),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: const Text("GUARDAR ASISTENCIA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text, TextStyle style) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Text(text, style: style),
      );

  Widget buildReadOnlyField(
    String value,
    BoxDecoration box,
    EdgeInsets padding,
    Color textColor,
  ) =>
      Container(
        padding: padding,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: box,
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
          ],
        ),
      );

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }
}
