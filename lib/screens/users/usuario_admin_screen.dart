import 'package:flutter/material.dart';
import 'package:imdec_front/models/carrera_dto.dart';
import 'package:imdec_front/models/rol_dto.dart';
import 'package:imdec_front/models/usuario_dto.dart';
import 'package:imdec_front/services/rol_service.dart';
import '../../services/usuario_service.dart';
import '../../services/carrera_service.dart';

class UsuarioAdminScreen extends StatefulWidget {
  @override
  _UsuarioAdminScreenState createState() => _UsuarioAdminScreenState();
}

class _UsuarioAdminScreenState extends State<UsuarioAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UsuarioService();

  List<UsuarioDTO> _usuarios = [];
  List<RolDTO> _roles = [];
  List<CarreraDTO> _carreras = [];

  UsuarioDTO? _editingUsuario;
  bool _obscurePassword = true;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPController = TextEditingController();
  final TextEditingController _apellidoMController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int? _rolId;
  int? _carreraId;
  String _status = 'activo';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nombreController.clear();
    _apellidoPController.clear();
    _apellidoMController.clear();
    _correoController.clear();
    _passwordController.clear();
    _rolId = null;
    _carreraId = null;
    _status = 'activo';
    _editingUsuario = null;
    _obscurePassword = true;
    setState(() {});
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final usuario = UsuarioDTO(
        id: _editingUsuario?.id, // Usamos ?. para manejar null
        nombre: _nombreController.text,
        apellidoPaterno: _apellidoPController.text,
        apellidoMaterno: _apellidoMController.text,
        correo: _correoController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        rolId: _rolId ?? 0, // Valor por defecto o manejo de error
        carreraId: _carreraId,
        status: _status,
      );

      if (_editingUsuario == null) {
        await _service.crearUsuario(usuario);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario creado exitosamente')),
        );
      } else {
        await _service.actualizarUsuario(usuario);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
      }

      _resetForm();
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _editUsuario(UsuarioDTO usuario) {
    setState(() {
      _editingUsuario = usuario;
      _nombreController.text = usuario.nombre;
      _apellidoPController.text = usuario.apellidoPaterno;
      _apellidoMController.text = usuario.apellidoMaterno;
      _correoController.text = usuario.correo;
      _passwordController.clear();
      _rolId = usuario.rolId;
      _carreraId = usuario.carreraId;
      _status = usuario.status;
      _obscurePassword = true;
    });
  }

  Future<void> _deleteUsuario(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.eliminarUsuario(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario eliminado exitosamente')),
        );
        await _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar usuario: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administrar Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _apellidoPController,
                    decoration: InputDecoration(labelText: 'Apellido Paterno'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _apellidoMController,
                    decoration: InputDecoration(labelText: 'Apellido Materno'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      if (!value.contains('@')) {
                        return 'Ingrese un correo válido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (_editingUsuario == null && (value == null || value.isEmpty)) {
                        return 'La contraseña es requerida';
                      }
                      if (value != null && value.isNotEmpty && value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<int>(
                    value: _rolId,
                    decoration: InputDecoration(labelText: 'Rol'),
                    items: _roles.map((rol) {
                      return DropdownMenuItem<int>(
                        value: rol.id,
                        child: Text(rol.nombre),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _rolId = value),
                    validator: (value) => value == null ? 'Campo requerido' : null,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<int>(
                    value: _carreraId,
                    decoration: InputDecoration(labelText: 'Carrera'),
                    items: _carreras.map((carrera) {
                      return DropdownMenuItem<int>(
                        value: carrera.id,
                        child: Text(carrera.nombre),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _carreraId = value),
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(labelText: 'Estatus'),
                    items: ['activo', 'inactivo']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(_editingUsuario == null ? 'Agregar' : 'Actualizar'),
                ),
                if (_editingUsuario != null)
                  TextButton(
                    onPressed: _resetForm,
                    child: Text('Cancelar'),
                  )
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nombre')),
                  DataColumn(label: Text('Correo')),
                  DataColumn(label: Text('Rol')),
                  DataColumn(label: Text('Carrera')),
                  DataColumn(label: Text('Estatus')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: _usuarios.map((usuario) {
                  return DataRow(cells: [
                    DataCell(Text(usuario.nombreCompleto)),
                    DataCell(Text(usuario.correo)),
                    DataCell(Text(usuario.rol?.nombre ?? '')),
                    DataCell(Text(usuario.carrera?.nombre ?? '')),
                    DataCell(Text(usuario.status)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editUsuario(usuario),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUsuario(usuario.id!),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}