import 'package:imdec_front/models/usuario_dto.dart';

class IncidenciaDTO {
  final int? id;
  final int usuarioId;
  final String tipoIncidencia;
  final String motivo;
  final String fechaAusencia; // formato YYYY-MM-DD
  final String? horaSalida; // formato HH:mm:ss
  final String? horaRegreso; // formato HH:mm:ss
  final double? horaTransporte; // decimal en formato 4,2 (ej. 1.25 = 1h 15min)
  String? documentoJustificativo;
  final String estatus;
  final int? supervisorId;
  final String? observaciones;
  final String? fechaSolicitud; // formato timestamp
  final String? nombreCompleto;
  UsuarioDTO? usuario;

  IncidenciaDTO({
    this.id,
    required this.usuarioId,
    required this.tipoIncidencia,
    required this.motivo,
    required this.fechaAusencia,
    this.horaSalida,
    this.horaRegreso,
    this.horaTransporte,
    this.documentoJustificativo,
    this.estatus = 'pendiente',
    this.supervisorId,
    this.observaciones,
    this.fechaSolicitud,
    this.nombreCompleto, // <-- en constructor
    this.usuario
  });

factory IncidenciaDTO.fromJson(Map<String, dynamic> json) {
  final usuarioJson = json['usuario'];
  final nombre = usuarioJson?['nombre'] ?? '';
  final apellidoPaterno = usuarioJson?['apellido_paterno'] ?? '';
  final apellidoMaterno = usuarioJson?['apellido_materno'] ?? '';

  return IncidenciaDTO(
    id: json['id'],
    usuarioId: json['usuario_id'],
    tipoIncidencia: json['tipo_incidencia'],
    motivo: json['motivo'],
    fechaAusencia: json['fecha_ausencia'],
    horaSalida: json['hora_salida'],
    horaRegreso: json['hora_regreso'],
    horaTransporte: json['hora_transporte'] != null
        ? double.tryParse(json['hora_transporte'].toString())
        : null,
    documentoJustificativo: json['documento_justificativo'],
    estatus: json['estatus'] ?? 'pendiente',
    supervisorId: json['supervisor_id'],
    observaciones: json['observaciones'],
    fechaSolicitud: json['fecha_solicitud'],
    nombreCompleto: "$nombre $apellidoPaterno $apellidoMaterno".trim(),
    usuario: usuarioJson != null ? UsuarioDTO.fromJson(usuarioJson) : null,
  );
}

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'usuario_id': usuarioId,
      'tipo_incidencia': tipoIncidencia,
      'motivo': motivo,
      'fecha_ausencia': fechaAusencia,
      'estatus': estatus,
    };

    if (id != null) data['id'] = id;
    if (horaSalida != null && horaSalida!.isNotEmpty)
      data['hora_salida'] = horaSalida;
    if (horaRegreso != null && horaRegreso!.isNotEmpty)
      data['hora_regreso'] = horaRegreso;
    if (horaTransporte != null) data['hora_transporte'] = horaTransporte;
    if (documentoJustificativo != null)
      data['documento_justificativo'] = documentoJustificativo;
    if (supervisorId != null) data['supervisor_id'] = supervisorId;
    if (observaciones != null) data['observaciones'] = observaciones;
    if (fechaSolicitud != null) data['fecha_solicitud'] = fechaSolicitud;

    return data;
  }
}
