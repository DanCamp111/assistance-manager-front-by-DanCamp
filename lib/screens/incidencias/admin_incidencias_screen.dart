import 'package:flutter/material.dart';
import 'package:imdec_front/models/incidencia_dto.dart';
import 'package:imdec_front/services/incidencia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AdminIncidenciasScreen extends StatefulWidget {
  const AdminIncidenciasScreen({super.key});

  @override
  State<AdminIncidenciasScreen> createState() => _AdminIncidenciasScreenState();
}

class _AdminIncidenciasScreenState extends State<AdminIncidenciasScreen> {
  final IncidenciaService _service = IncidenciaService();
  late Future<List<IncidenciaDTO>> _incidenciasFuture;

  @override
  void initState() {
    super.initState();
    _incidenciasFuture = _service.getIncidencias();
  }

  Future<void> _cambiarEstatus({
    required int id,
    required String nuevoEstatus,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final supervisorId = prefs.getInt('usuario_id');

      if (supervisorId == null) {
        throw Exception("No se encontró el ID del usuario en sesión");
      }

      await _service.cambiarEstatus(
        estatus: nuevoEstatus,
        id: id,
        supervisorId: supervisorId,
        observaciones: nuevoEstatus == 'rechazado' ? 'Motivo de rechazo' : null,
      );

      setState(() {
        _incidenciasFuture = _service.getIncidencias();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  String _formatearFecha(String fechaIso) {
    try {
      final DateTime fecha = DateTime.parse(fechaIso);
      return DateFormat('dd/MM/yyyy').format(fecha);
    } catch (_) {
      return fechaIso;
    }
  }

  String _formatearHora(String hora) {
    try {
      final DateTime horaFormateada = DateFormat("HH:mm:ss").parse(hora);
      return DateFormat("hh:mm a").format(horaFormateada);
    } catch (_) {
      return hora;
    }
  }

  DataRow _buildRow(IncidenciaDTO incidencia) {
    return DataRow(
      cells: [
        DataCell(Text(incidencia.nombreCompleto ?? '')),
        DataCell(Text(_formatearFecha(incidencia.fechaAusencia))),
        DataCell(Text(incidencia.motivo)),
        DataCell(
          incidencia.documentoJustificativo != null
              ? InkWell(
                  onTap: () {
                    final url = incidencia.documentoJustificativo!;
                    // Aquí podrías usar url_launcher si lo deseas
                  },
                  child: const Text(
                    'Ver PDF',
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 33, 173),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : const Text("No disponible"),
        ),
        DataCell(Text(_formatearHora(incidencia.horaSalida ?? ''))),
        DataCell(Text(_formatearHora(incidencia.horaRegreso ?? ''))),
        DataCell(Text('${incidencia.horaTransporte ?? 0} hrs')),
        DataCell(
          Row(
            children: [
              Icon(
                incidencia.estatus == 'aprobado'
                    ? Icons.check_circle
                    : incidencia.estatus == 'rechazado'
                    ? Icons.cancel
                    : Icons.hourglass_bottom,
                color: incidencia.estatus == 'aprobado'
                    ? Colors.green
                    : incidencia.estatus == 'rechazado'
                    ? Colors.red
                    : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                incidencia.estatus[0].toUpperCase() +
                    incidencia.estatus.substring(1),
                style: TextStyle(
                  color: incidencia.estatus == 'aprobado'
                      ? Colors.green
                      : incidencia.estatus == 'rechazado'
                      ? Colors.red
                      : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        DataCell(
          incidencia.estatus == 'pendiente'
              ? Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Aprobar',
                      onPressed: () => _cambiarEstatus(
                        id: incidencia.id!,
                        nuevoEstatus: 'aprobado',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Rechazar',
                      onPressed: () => _mostrarDialogoRechazo(incidencia.id!),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listado de Incidencias')),
      body: FutureBuilder<List<IncidenciaDTO>>(
        future: _incidenciasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final incidencias = snapshot.data ?? [];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Fecha')),
                DataColumn(label: Text('Motivo')),
                DataColumn(label: Text('Justificación')),
                DataColumn(label: Text('Hora Salida')),
                DataColumn(label: Text('Hora Regreso')),
                DataColumn(label: Text('Tiempo Transporte')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: incidencias.map(_buildRow).toList(),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoRechazo(int incidenciaId) {
    final TextEditingController observacionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivo de Rechazo'),
        content: TextField(
          controller: observacionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escribe la razón del rechazo...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final observacion = observacionController.text.trim();
              if (observacion.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("La observación es obligatoria."),
                  ),
                );
                return;
              }

              Navigator.of(context).pop(); // Cierra el diálogo

              final prefs = await SharedPreferences.getInstance();
              final supervisorId = prefs.getInt('usuario_id');

              if (supervisorId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "No se encontró el ID del usuario en sesión.",
                    ),
                  ),
                );
                return;
              }

              await _service.cambiarEstatus(
                estatus: 'rechazado',
                id: incidenciaId,
                supervisorId: supervisorId,
                observaciones: observacion,
              );

              setState(() {
                _incidenciasFuture = _service.getIncidencias();
              });
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}
