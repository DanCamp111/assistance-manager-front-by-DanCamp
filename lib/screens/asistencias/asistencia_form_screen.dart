import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/asistencia_dto.dart';
import '../../services/asistencia_service.dart';

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaCtrl = TextEditingController(text: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");
    _horaCtrl = TextEditingController(text: "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}");
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
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
    Fluttertoast.showToast(msg: "Selecciona una foto");
    return;
  }

  final asistencia = AsistenciaDTO(
    usuarioId: usuarioId,
    tipoRegistro: _tipo,
    fechaRegistro: _fechaCtrl.text,
    horaExacta: _horaCtrl.text,
    fotoRegistro: null,
  );

  try {
    final creada = await AsistenciaService().createAsistencia(asistencia);

    // Ahora subimos la imagen
    final fotoUrl = await AsistenciaService().subirFoto(creada.id!, _file!);

    // Si quieres actualizar la asistencia con la foto (opcional):
    if (fotoUrl != null) {
      creada.fotoRegistro = fotoUrl;
    }

    Fluttertoast.showToast(msg: "Asistencia registrada correctamente");
    Navigator.pop(context);
  } catch (e) {
    Fluttertoast.showToast(msg: "Error: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Asistencia")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              onChanged: (val) => setState(() => _tipo = val!),
              items: const [
                DropdownMenuItem(value: 'entrada', child: Text("Entrada")),
                DropdownMenuItem(value: 'salida', child: Text("Salida")),
              ],
              decoration: const InputDecoration(labelText: "Tipo de Registro"),
            ),
            TextField(controller: _fechaCtrl, decoration: const InputDecoration(labelText: "Fecha (YYYY-MM-DD)")),
            TextField(controller: _horaCtrl, decoration: const InputDecoration(labelText: "Hora (HH:MM:SS)")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(_file != null ? "Foto seleccionada" : "Seleccionar Foto"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Guardar Asistencia"),
            )
          ],
        ),
      ),
    );
  }
}