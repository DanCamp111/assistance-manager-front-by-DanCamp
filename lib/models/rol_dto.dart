class RolDTO {
  final int id;
  final String nombre;

  RolDTO({
    required this.id,
    required this.nombre,
  });

  factory RolDTO.fromJson(Map<String, dynamic> json) {
    return RolDTO(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
