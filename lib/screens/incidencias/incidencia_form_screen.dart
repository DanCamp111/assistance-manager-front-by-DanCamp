import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imdec_front/models/incidencia_dto.dart';
import 'package:imdec_front/screens/home/home_screen.dart';
import 'package:imdec_front/services/incidencia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidenciaFormScreen extends StatefulWidget {
  const IncidenciaFormScreen({super.key});

  @override
  State<IncidenciaFormScreen> createState() => _IncidenciaFormScreenState();
}

class _IncidenciaFormScreenState extends State<IncidenciaFormScreen> {
  final _motivoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaSalidaCtrl = TextEditingController();
  final _horaRegresoCtrl = TextEditingController();
  final _horaTransporteCtrl = TextEditingController();
  final _otroTipoCtrl = TextEditingController();

  String? _tipoSeleccionado;
  PlatformFile? _file;

  final List<String> _tipos = [
    'Falta Justificada',
    'Visita a Asesor Academico',
    'Permiso por Enfermedad',
    'Permiso Social',
    'Cita Universiad',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaCtrl.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickHora(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hora = picked.hour.toString().padLeft(2, '0');
      final minuto = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hora:$minuto:00';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        _file = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null) {
      Fluttertoast.showToast(msg: "Usuario no autenticado");
      return;
    }

    final tipoFinal = _tipoSeleccionado == 'Otro'
        ? _otroTipoCtrl.text.trim()
        : _tipoSeleccionado ?? '';

    if (tipoFinal.isEmpty || _motivoCtrl.text.isEmpty) {
      Fluttertoast.showToast(msg: "Completa todos los campos obligatorios");
      return;
    }

    final incidencia = IncidenciaDTO(
      usuarioId: usuarioId,
      tipoIncidencia: tipoFinal,
      motivo: _motivoCtrl.text,
      fechaAusencia: _fechaCtrl.text,
      horaSalida: _horaSalidaCtrl.text.isNotEmpty ? _horaSalidaCtrl.text : null,
      horaRegreso: _horaRegresoCtrl.text.isNotEmpty ? _horaRegresoCtrl.text : null,
      horaTransporte: _horaTransporteCtrl.text.isNotEmpty
          ? double.tryParse(_horaTransporteCtrl.text)
          : null,
      documentoJustificativo: null,
    );


    try {
      final creada = await IncidenciaService().createIncidencia(incidencia);

      if (_file != null) {
        final path = await IncidenciaService().subirDocumento(creada.id!, _file!);
        if (path != null) {
          creada.documentoJustificativo = path;
        }
      }

      _mostrarDialogoExito();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text("¡Registro exitoso!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Tu incidencia ha sido registrada correctamente.", textAlign: TextAlign.center),
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
      ),
    );
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _fechaCtrl.dispose();
    _horaSalidaCtrl.dispose();
    _horaRegresoCtrl.dispose();
    _horaTransporteCtrl.dispose();
    _otroTipoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Incidencia")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              items: _tipos.map((tipo) {
                return DropdownMenuItem(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (val) => setState(() => _tipoSeleccionado = val),
              decoration: const InputDecoration(labelText: "Tipo de Incidencia"),
            ),
            if (_tipoSeleccionado == 'Otro')
              TextField(
                controller: _otroTipoCtrl,
                decoration: const InputDecoration(labelText: "Especificar tipo"),
              ),
            TextField(
              controller: _motivoCtrl,
              decoration: const InputDecoration(labelText: "Motivo"),
              maxLines: 3,
            ),
            TextField(
              controller: _fechaCtrl,
              readOnly: true,
              decoration: const InputDecoration(labelText: "Fecha de Ausencia"),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _fechaCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _horaSalidaCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Hora de Salida"),
                    onTap: () => _pickHora(_horaSalidaCtrl),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _horaRegresoCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: "Hora de Regreso"),
                    onTap: () => _pickHora(_horaRegresoCtrl),
                  ),
                ),
              ],
            ),
            TextField(
              controller: _horaTransporteCtrl,
              decoration: const InputDecoration(labelText: "Hora de Transporte (opcional)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(_file != null ? "Documento seleccionado" : "Seleccionar Documento"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Guardar Incidencia"),
            ),
          ],
        ),
      ),
    );
  }
}
