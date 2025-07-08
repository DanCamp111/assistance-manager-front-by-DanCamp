class UsuarioDTO {
  final int id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final int rolId;
  final int? carreraId;
  final String status;

  UsuarioDTO({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.rolId,
    this.carreraId,
    required this.status,
  });

  factory UsuarioDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioDTO(
      id: json['id'],
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
      correo: json['correo'],
      rolId: json['rol_id'],
      carreraId: json['carrera_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'correo': correo,
      'rol_id': rolId,
      'carrera_id': carreraId,
      'status': status,
    };
  }

  String get nombreCompleto =>
      '$nombre $apellidoPaterno $apellidoMaterno';
}
