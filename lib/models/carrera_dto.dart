class CarreraDTO {
  int? id;
  String nombre;
  String? codigo;
  String? descripcion;

  CarreraDTO({
    this.id,
    required this.nombre,
    this.codigo,
    this.descripcion,
  });

  factory CarreraDTO.fromJson(Map<String, dynamic> json) => CarreraDTO(
        id: json['id'],
        nombre: json['nombre'],
        codigo: json['codigo'],
        descripcion: json['descripcion'],
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'codigo': codigo,
        'descripcion': descripcion,
      };
}
