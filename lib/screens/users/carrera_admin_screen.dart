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
      } else {
        await _service.crearCarrera(carrera);
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
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Eliminar'), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmado ?? false) {
      await _service.eliminarCarrera(id);
      await _cargarCarreras();
    }
  }

  Widget _campoTitulo(String texto) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 8),
    child: Text(
      texto,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _contenedorDato(String valor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(4),
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
      appBar: AppBar(title: const Text("Administrar Carreras"), centerTitle: true),
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
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  _campoTitulo("Código"),
                  TextFormField(
                    controller: _codigoCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  _campoTitulo("Descripción"),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: Icon(_editando != null ? Icons.save : Icons.add),
                      label: Text(_editando != null ? 'ACTUALIZAR CARRERA' : 'AGREGAR CARRERA'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color.fromARGB(255, 243, 33, 152),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_editando != null)
                    TextButton(
                      onPressed: _limpiar,
                      child: const Text("Cancelar edición"),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const Text(
              "Listado de Carreras",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _carreras.length,
              itemBuilder: (context, index) {
                final c = _carreras[index];
                return Card(
                  child: ListTile(
                    title: Text(c.nombre),
                    subtitle: Text(c.descripcion ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editar(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
