import 'package:flutter/material.dart';
import 'package:imdec_front/models/incidencia_dto.dart';
import 'package:imdec_front/services/incidencia_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminIncidenciasScreen extends StatefulWidget {
  const AdminIncidenciasScreen({super.key});

  @override
  State<AdminIncidenciasScreen> createState() => _AdminIncidenciasScreenState();
}

class _AdminIncidenciasScreenState extends State<AdminIncidenciasScreen> {
  final IncidenciaService _service = IncidenciaService();
  late Future<List<IncidenciaDTO>> _incidenciasFuture;

  // 🎨 Colores y estilos base IMDEC
  final Color primaryColor = const Color.fromARGB(255, 221, 109, 173);
  final Color primaryDark = const Color(0xFFC7549B);
  final Color greyLight = Colors.grey.shade100; // más claro
  final Color greyMedium = Colors.grey.shade600;
  final Color greyDark = Colors.grey.shade800;
  final Color whiteColor = Colors.white;
  final Color blackColor = Colors.black87;

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
        DataCell(
          Text(
            incidencia.nombreCompleto ?? '',
            style: TextStyle(color: blackColor),
          ),
        ),
        DataCell(
          Text(
            _formatearFecha(incidencia.fechaAusencia),
            style: TextStyle(color: greyDark),
          ),
        ),
        DataCell(Text(incidencia.motivo, style: TextStyle(color: greyDark))),
        DataCell(
          incidencia.documentoJustificativo != null
              ? InkWell(
                  onTap: () async {
                    final apiUrl = dotenv.env['API_URL']!;
                    final baseUrl = apiUrl.replaceAll('/api', '');
                    final rutaRelativa = incidencia.documentoJustificativo!;
                    final urlCompleta = baseUrl + rutaRelativa;

                    final uri = Uri.parse(urlCompleta);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el PDF'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Ver PDF',
                    style: TextStyle(
                      color: primaryDark,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text("No disponible", style: TextStyle(color: greyMedium)),
        ),
        DataCell(
          Text(
            _formatearHora(incidencia.horaSalida ?? ''),
            style: TextStyle(color: greyDark),
          ),
        ),
        DataCell(
          Text(
            _formatearHora(incidencia.horaRegreso ?? ''),
            style: TextStyle(color: greyDark),
          ),
        ),
        DataCell(
          Text(
            '${incidencia.horaTransporte ?? 0} hrs',
            style: TextStyle(color: greyDark),
          ),
        ),
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
                    : greyMedium,
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
                      : greyDark,
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
      backgroundColor: greyLight,
      appBar: AppBar(
        title: const Text('Listado de Incidencias'),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 2,
      ),
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
            child: Padding(
              // 👉 Ajustes de padding para subirlo y moverlo a la derecha
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Transform.scale(
                scale: 1.02,
                alignment: Alignment
                    .topLeft, // 👉 Alineación para anclarlo a la esquina superior izquierda
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: greyMedium),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
                    color: whiteColor,
                  ),
                  child: DataTable(
                    headingRowHeight: 50,
                    dataRowHeight: 48,
                    headingRowColor: MaterialStateProperty.all(
                      primaryColor.withOpacity(0.15),
                    ),
                    dividerThickness: 1.5,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Nombre',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Fecha',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Motivo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Justificación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Hora Salida',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Hora Regreso',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tiempo Transporte',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Estado',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Acciones',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: blackColor,
                          ),
                        ),
                      ),
                    ],
                    rows: incidencias.map(_buildRow).toList(),
                  ),
                ),
              ),
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
          decoration: InputDecoration(
            hintText: 'Escribe la razón del rechazo...',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: greyMedium),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
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

              Navigator.of(context).pop();

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
