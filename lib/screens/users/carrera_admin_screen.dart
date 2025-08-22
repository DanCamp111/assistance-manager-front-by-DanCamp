import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imdec_front/models/carrera_dto.dart';
import 'package:imdec_front/services/carrera_service.dart';

class CarreraAdminScreen extends StatefulWidget {
  const CarreraAdminScreen({super.key});

  @override
  State<CarreraAdminScreen> createState() => _CarreraAdminScreenState();
}

class _CarreraAdminScreenState extends State<CarreraAdminScreen> {
  final CarreraService _service = CarreraService();
  final _formKey = GlobalKey<FormState>();

  List<CarreraDTO> _carreras = [];
  CarreraDTO? _editando;
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  bool _loading = true;

  // 🎨 Colores y estilos base IMDEC
  final Color primaryColor = const Color.fromARGB(255, 221, 109, 173);
  final Color primaryDark = const Color(0xFFC7549B);
  final Color backgroundLight = const Color(0xFFF9F4F9);
  final Color borderGray = Colors.grey.shade300;
  final Color textPrimary = Colors.black87;
  final Color textSecondary = Colors.grey.shade700;
  final Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _cargarCarreras();
  }

  Future<void> _cargarCarreras() async {
    try {
      _carreras = await _service.getCarreras();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al cargar carreras: $e");
    }
    setState(() => _loading = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final carrera = CarreraDTO(
      id: _editando?.id,
      nombre: _nombreCtrl.text,
      codigo: _codigoCtrl.text,
      descripcion: _descripcionCtrl.text,
    );

    try {
      if (_editando != null) {
        await _service.actualizarCarrera(carrera);
        Fluttertoast.showToast(msg: "Carrera actualizada con éxito");
      } else {
        await _service.crearCarrera(carrera);
        Fluttertoast.showToast(msg: "Carrera creada con éxito");
      }
      _limpiar();
      await _cargarCarreras();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al guardar: $e");
    }
  }

  void _limpiar() {
    _formKey.currentState?.reset();
    _editando = null;
    _nombreCtrl.clear();
    _codigoCtrl.clear();
    _descripcionCtrl.clear();
    setState(() {});
  }

  void _editar(CarreraDTO carrera) {
    _editando = carrera;
    _nombreCtrl.text = carrera.nombre;
    _codigoCtrl.text = carrera.codigo ?? '';
    _descripcionCtrl.text = carrera.descripcion ?? '';
    setState(() {});
  }

  Future<void> _eliminar(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta carrera?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: whiteColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado ?? false) {
      try {
        await _service.eliminarCarrera(id);
        await _cargarCarreras();
        Fluttertoast.showToast(msg: "Carrera eliminada con éxito");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error al eliminar: $e");
      }
    }
  }

  Widget _campoTitulo(String texto) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 8),
    child: Text(
      texto,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryDark,
      ),
    ),
  );

  Widget _contenedorDato(String valor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      border: Border.all(color: borderGray),
      borderRadius: BorderRadius.circular(4),
      color: backgroundLight,
    ),
    child: Row(
      children: [
        Expanded(child: Text(valor)),
        const Icon(Icons.check, color: Colors.green),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Administrar Carreras"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _campoTitulo("Nombre *"),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  _campoTitulo("Código"),
                  TextFormField(
                    controller: _codigoCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  _campoTitulo("Descripción"),
                  TextFormField(
                    controller: _descripcionCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: Icon(
                        _editando != null ? Icons.save : Icons.add,
                        size: 26,
                      ),
                      label: Text(
                        _editando != null
                            ? 'ACTUALIZAR CARRERA'
                            : 'AGREGAR CARRERA',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  if (_editando != null)
                    Center(
                      child: TextButton(
                        onPressed: _limpiar,
                        style: TextButton.styleFrom(
                          foregroundColor: primaryDark,
                        ),
                        child: const Text(
                          "Cancelar edición",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            Text(
              "Listado de Carreras",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _carreras.length,
              itemBuilder: (context, index) {
                final c = _carreras[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    title: Text(
                      c.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      c.descripcion ?? 'Sin descripción',
                      style: TextStyle(color: textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar',
                          onPressed: () => _editar(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminar(c.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }
}
