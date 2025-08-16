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

  // Colores base
  final Color primaryColor = const Color.fromARGB(255, 221, 109, 173);
  final Color primaryDark = const Color(0xFFC7549B);
  final Color backgroundLight = const Color(0xFFF9F4F9);
  final Color borderGray = Colors.grey.shade300;
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.grey.shade700;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fechaCtrl.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
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

    // Aquí iría tu lógica para enviar los datos al servidor
    // Ejemplo genérico:
    final incidencia = {
      'usuarioId': usuarioId,
      'tipoIncidencia': tipoFinal,
      'motivo': _motivoCtrl.text,
      'fechaAusencia': _fechaCtrl.text,
      'horaSalida': _horaSalidaCtrl.text.isNotEmpty
          ? _horaSalidaCtrl.text
          : null,
      'horaRegreso': _horaRegresoCtrl.text.isNotEmpty
          ? _horaRegresoCtrl.text
          : null,
      'horaTransporte': _horaTransporteCtrl.text.isNotEmpty
          ? double.tryParse(_horaTransporteCtrl.text)
          : null,
      'documentoJustificativo': null,
    };

    try {
      // Simulación de envío exitoso
      await Future.delayed(const Duration(seconds: 1));
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
          children: [
            Icon(Icons.check_circle_outline, color: primaryColor, size: 60),
            const SizedBox(height: 16),
            Text(
              "¡Registro exitoso!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Tu incidencia ha sido registrada correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Cerrar dialogo y regresar a home
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
        title: const Text(
          "Registro de Incidencias",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.white,
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
            _buildLabel("Tipo de Incidencia *"),
            const SizedBox(height: 8),
            _buildDropdown(),
            const SizedBox(height: 16),

            if (_tipoSeleccionado == 'Otro') ...[
              _buildLabel("Especificar tipo *"),
              const SizedBox(height: 8),
              _buildTextField(_otroTipoCtrl, "Ingrese el tipo de incidencia"),
              const SizedBox(height: 16),
            ],

            _buildLabel("Motivo *"),
            const SizedBox(height: 8),
            _buildTextField(
              _motivoCtrl,
              "Describa el motivo de la incidencia",
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildLabel("Fecha de Ausencia *"),
            const SizedBox(height: 8),
            _buildDateField(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Hora de Salida"),
                      const SizedBox(height: 8),
                      _buildTimeField(_horaSalidaCtrl),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Hora de Regreso"),
                      const SizedBox(height: 8),
                      _buildTimeField(_horaRegresoCtrl),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel("Hora de Transporte (opcional)"),
            const SizedBox(height: 8),
            _buildTextField(
              _horaTransporteCtrl,
              "Ingrese el tiempo de transporte en horas",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildLabel("Documento Justificativo *"),
            const SizedBox(height: 8),
            _buildFilePicker(),
            if (_file == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Ningún archivo seleccionado",
                  style: TextStyle(color: textSecondary, fontSize: 15),
                ),
              ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                child: const Text("GUARDAR INCIDENCIA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: primaryDark,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border.all(color: borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _tipoSeleccionado,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: backgroundLight,
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        borderRadius: BorderRadius.circular(12),
        hint: Text(
          "Seleccione un tipo",
          style: TextStyle(color: textSecondary),
        ),
        items: _tipos.map((tipo) {
          return DropdownMenuItem(value: tipo, child: Text(tipo));
        }).toList(),
        onChanged: (val) => setState(() => _tipoSeleccionado = val),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: textSecondary),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundLight,
        border: Border.all(color: borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _fechaCtrl.text,
              style: TextStyle(
                fontSize: 16,
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: primaryColor),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
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
    );
  }

  Widget _buildTimeField(TextEditingController controller) {
    return InkWell(
      onTap: () => _pickHora(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundLight,
          border: Border.all(color: borderGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? "--:--:--" : controller.text,
                style: TextStyle(
                  fontSize: 16,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.access_time, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return ElevatedButton.icon(
      onPressed: _pickFile,
      icon: const Icon(Icons.upload_file, size: 24),
      label: Text(
        _file != null ? _file!.name : "Seleccionar documento",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        backgroundColor: backgroundLight,
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primaryColor, width: 2),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    );
  }
}
