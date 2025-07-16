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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
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
            Text(
              "¡Registro exitoso!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Tu incidencia ha sido registrada correctamente.",
              textAlign: TextAlign.center,
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
      appBar: AppBar(
        title: const Text("Registro de Incidencias"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de incidencia
            const Text(
              "Tipo de Incidencia *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _tipoSeleccionado,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("Seleccione un tipo"),
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _tipoSeleccionado = val),
              ),
            ),
            const SizedBox(height: 16),

            // Campo para especificar tipo si es "Otro"
            if (_tipoSeleccionado == 'Otro')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Especificar tipo *",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otroTipoCtrl,
                    decoration: const InputDecoration(
                      hintText: "Ingrese el tipo de incidencia",
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Motivo
            const Text(
              "Motivo *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _motivoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Describa el motivo de la incidencia",
              ),
            ),
            const SizedBox(height: 16),

            // Fecha
            const Text(
              "Fecha de Ausencia *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(_fechaCtrl.text),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaCtrl.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Horas (Salida y Regreso)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hora de Salida",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(_horaSalidaCtrl.text.isEmpty ? "--:--:--" : _horaSalidaCtrl.text),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () => _pickHora(_horaSalidaCtrl),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hora de Regreso",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(_horaRegresoCtrl.text.isEmpty ? "--:--:--" : _horaRegresoCtrl.text),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () => _pickHora(_horaRegresoCtrl),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hora de transporte
            const Text(
              "Hora de Transporte (opcional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _horaTransporteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Ingrese el tiempo de transporte en horas",
              ),
            ),
            const SizedBox(height: 16),

            // Documento justificativo
            const Text(
              "Documento Justificativo *",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: Text(_file != null ? _file!.name : "Seleccionar documento"),
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
                  "Ningún archivo seleccionado",
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
                  backgroundColor: const Color.fromARGB(255, 243, 33, 166),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "GUARDAR INCIDENCIA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}