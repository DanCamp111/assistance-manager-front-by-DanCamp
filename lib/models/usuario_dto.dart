import 'carrera_dto.dart';
import 'rol_dto.dart';

class UsuarioDTO {
  final int? id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String? password;
  final int rolId;
  final int? carreraId;
  final String status;

  final RolDTO? rol;         // Objeto completo
  final CarreraDTO? carrera; // Objeto completo

  UsuarioDTO({
    this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    this.password,
    required this.rolId,
    this.carreraId,
    required this.status,
    this.rol,
    this.carrera,
  });

  factory UsuarioDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioDTO(
      id: json['id'],
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
      correo: json['correo'],
      password: json['password'],
      rolId: json['rol_id'],
      carreraId: json['carrera_id'],
      status: json['status'],
      rol: json['rol'] != null ? RolDTO.fromJson(json['rol']) : null,
      carrera: json['carrera'] != null ? CarreraDTO.fromJson(json['carrera']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'correo': correo,
      if (password != null) 'password': password,
      'rol_id': rolId,
      'carrera_id': carreraId,
      'status': status,
    };
  }

  String get nombreCompleto =>
      '$nombre $apellidoPaterno $apellidoMaterno';
}
