import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imdec_front/models/carrera_dto.dart';
import 'package:imdec_front/models/rol_dto.dart';
import 'package:imdec_front/models/usuario_dto.dart';
import 'package:imdec_front/services/rol_service.dart';
import '../../services/usuario_service.dart';
import '../../services/carrera_service.dart';

class UsuarioAdminScreen extends StatefulWidget {
  const UsuarioAdminScreen({super.key});

  @override
  State<UsuarioAdminScreen> createState() => _UsuarioAdminScreenState();
}

class _UsuarioAdminScreenState extends State<UsuarioAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UsuarioService();

  List<UsuarioDTO> _usuarios = [];
  List<RolDTO> _roles = [];
  List<CarreraDTO> _carreras = [];

  UsuarioDTO? _editando;
  bool _obscurePassword = true;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoPCtrl = TextEditingController();
  final TextEditingController _apellidoMCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  int? _rolId;
  int? _carreraId;
  String _status = 'activo';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final usuarios = await _service.getUsuarios();
      final roles = await RolService().getRoles();
      final carreras = await CarreraService().getCarreras();

      setState(() {
        _usuarios = usuarios;
        _roles = roles;
        _carreras = carreras;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al cargar datos: $e");
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _nombreCtrl.clear();
    _apellidoPCtrl.clear();
    _apellidoMCtrl.clear();
    _correoCtrl.clear();
    _passwordCtrl.clear();
    _rolId = null;
    _carreraId = null;
    _status = 'activo';
    _editando = null;
    _obscurePassword = true;
    setState(() {});
  }

  Future<void> _guardarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = UsuarioDTO(
      id: _editando?.id,
      nombre: _nombreCtrl.text.trim(),
      apellidoPaterno: _apellidoPCtrl.text.trim(),
      apellidoMaterno: _apellidoMCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      rolId: _rolId ?? 0,
      carreraId: _carreraId,
      status: _status,
    );

    try {
      if (_editando != null) {
        await _service.actualizarUsuario(usuario);
        Fluttertoast.showToast(msg: "Usuario actualizado");
      } else {
        await _service.crearUsuario(usuario);
        Fluttertoast.showToast(msg: "Usuario creado");
      }
      _limpiarFormulario();
      await _cargarDatos();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al guardar usuario: $e");
    }
  }

  void _editarUsuario(UsuarioDTO usuario) {
    _editando = usuario;
    _nombreCtrl.text = usuario.nombre;
    _apellidoPCtrl.text = usuario.apellidoPaterno;
    _apellidoMCtrl.text = usuario.apellidoMaterno;
    _correoCtrl.text = usuario.correo;
    _passwordCtrl.clear();
    _rolId = usuario.rolId;
    _carreraId = usuario.carreraId;
    _status = usuario.status;
    _obscurePassword = true;
    setState(() {});
  }

  Future<void> _eliminarUsuario(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: const Text("¿Seguro que quieres eliminar este usuario?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _service.eliminarUsuario(id);
        Fluttertoast.showToast(msg: "Usuario eliminado");
        await _cargarDatos();
      } catch (e) {
        Fluttertoast.showToast(msg: "Error al eliminar usuario: $e");
      }
    }
  }

  Widget _tituloCampo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 8),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrar Usuarios"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tituloCampo("Nombre *"),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Apellido Paterno *"),
                  TextFormField(
                    controller: _apellidoPCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Apellido Materno *"),
                  TextFormField(
                    controller: _apellidoMCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Correo *"),
                  TextFormField(
                    controller: _correoCtrl,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Requerido";
                      if (!v.contains("@")) return "Correo inválido";
                      return null;
                    },
                  ),
                  _tituloCampo("Contraseña ${_editando == null ? "*" : "(dejar vacío para no cambiar)"}"),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) {
                      if (_editando == null && (v == null || v.isEmpty)) return "Requerido";
                      if (v != null && v.isNotEmpty && v.length < 8) return "Mínimo 8 caracteres";
                      return null;
                    },
                  ),
                  _tituloCampo("Rol *"),
                  DropdownButtonFormField<int>(
                    value: _rolId,
                    items: _roles
                        .map((r) => DropdownMenuItem(value: r.id, child: Text(r.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _rolId = v),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    validator: (v) => v == null ? "Requerido" : null,
                  ),
                  _tituloCampo("Carrera"),
                  DropdownButtonFormField<int>(
                    value: _carreraId,
                    items: _carreras
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _carreraId = v),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  _tituloCampo("Estatus"),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: (v) => setState(() => _status = v!),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardarUsuario,
                      icon: Icon(_editando == null ? Icons.add : Icons.save),
                      label: Text(_editando == null ? "Agregar Usuario" : "Actualizar Usuario"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color.fromARGB(255, 243, 33, 152),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_editando != null)
                    TextButton(
                      onPressed: _limpiarFormulario,
                      child: const Text("Cancelar edición"),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const Text(
              "Listado de Usuarios",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Lista tipo tarjetas pero con filas que muestren columnas (como tabla)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _usuarios.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final u = _usuarios[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(u.nombreCompleto),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Correo: ${u.correo}'),
                        Text('Rol: ${u.rol?.nombre ?? "N/A"}'),
                        Text('Carrera: ${u.carrera?.nombre ?? "N/A"}'),
                        Text('Estatus: ${u.status}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarUsuario(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarUsuario(u.id!),
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
    _apellidoPCtrl.dispose();
    _apellidoMCtrl.dispose();
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
