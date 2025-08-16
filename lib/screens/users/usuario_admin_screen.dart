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
  bool _isLoading = true;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoPCtrl = TextEditingController();
  final TextEditingController _apellidoMCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  int? _rolId;
  int? _carreraId;
  String _status = 'activo';

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
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
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
    } finally {
      setState(() => _isLoading = false);
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: whiteColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
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
        child: Text(
          texto,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: primaryDark,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text("Administrar Usuarios"),
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
                  _tituloCampo("Nombre *"),
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
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Apellido Paterno *"),
                  TextFormField(
                    controller: _apellidoPCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Apellido Materno *"),
                  TextFormField(
                    controller: _apellidoMCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Requerido" : null,
                  ),
                  _tituloCampo("Correo *"),
                  TextFormField(
                    controller: _correoCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Requerido";
                      if (!v.contains("@")) return "Correo inválido";
                      return null;
                    },
                  ),
                  _tituloCampo(
                    "Contraseña ${_editando == null ? "*" : "(dejar vacío para no cambiar)"}",
                  ),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (v) => v == null ? "Requerido" : null,
                  ),
                  _tituloCampo("Carrera"),
                  DropdownButtonFormField<int>(
                    value: _carreraId,
                    items: _carreras
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _carreraId = v),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: borderGray),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  _tituloCampo("Estatus"),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: (v) => setState(() => _status = v!),
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
                      onPressed: _guardarUsuario,
                      icon: Icon(_editando == null ? Icons.add : Icons.save, size: 26),
                      label: Text(
                        _editando == null ? "Agregar Usuario" : "Actualizar Usuario",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        onPressed: _limpiarFormulario,
                        style: TextButton.styleFrom(foregroundColor: primaryDark),
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
              "Listado de Usuarios",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _usuarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final u = _usuarios[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      u.nombreCompleto,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Correo: ${u.correo}', style: TextStyle(color: textSecondary)),
                        Text('Rol: ${u.rol?.nombre ?? "N/A"}', style: TextStyle(color: textSecondary)),
                        Text('Carrera: ${u.carrera?.nombre ?? "N/A"}', style: TextStyle(color: textSecondary)),
                        Text('Estatus: ${u.status}', style: TextStyle(color: textSecondary)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Editar',
                          onPressed: () => _editarUsuario(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Eliminar',
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
