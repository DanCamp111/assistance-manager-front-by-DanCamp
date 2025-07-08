class AsistenciaDTO {
  final int? id;
  final int usuarioId;
  final String tipoRegistro; // entrada | salida
  final String fechaRegistro; // formato 'YYYY-MM-DD'
  final String horaExacta;    // formato 'HH:mm:ss'
  String? fotoRegistro;

  AsistenciaDTO({
    this.id,
    required this.usuarioId,
    required this.tipoRegistro,
    required this.fechaRegistro,
    required this.horaExacta,
    this.fotoRegistro,
  });

  factory AsistenciaDTO.fromJson(Map<String, dynamic> json) {
    return AsistenciaDTO(
      id: json['id'],
      usuarioId: json['usuario_id'],
      tipoRegistro: json['tipo_registro'],
      fechaRegistro: json['fecha_registro'], // ya viene como string tipo '2025-07-04'
      horaExacta: json['hora_exacta'],       // formato 'HH:mm:ss'
      fotoRegistro: json['foto_registro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_id': usuarioId,
      'tipo_registro': tipoRegistro,
      'fecha_registro': fechaRegistro,
      'hora_exacta': horaExacta,
      'foto_registro': fotoRegistro,
    };
  }
}

