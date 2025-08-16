import 'package:flutter/material.dart';
import 'package:imdec_front/services/asistencia_service.dart';

class MonitoreoAsistenciasScreen extends StatefulWidget {
  const MonitoreoAsistenciasScreen({super.key});

  @override
  State<MonitoreoAsistenciasScreen> createState() =>
      _MonitoreoAsistenciasScreenState();
}

class _MonitoreoAsistenciasScreenState
    extends State<MonitoreoAsistenciasScreen> {
  List<Map<String, dynamic>> asistencias = [];
  bool loading = true;
  String searchQuery = '';
  String? selectedIncidencia;

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
  }

  Future<void> fetchAsistencias() async {
    try {
      final data = await AsistenciaService().getHistorialSemanalAdmin();
      setState(() {
        asistencias = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  List<Map<String, dynamic>> get filteredAsistencias {
    return asistencias.where((asistencia) {
      final nombreMatch = asistencia['nombre']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final incidenciaMatch =
          selectedIncidencia == null ||
          selectedIncidencia == 'Todas' ||
          asistencia['incidencia'] == selectedIncidencia;
      return nombreMatch && incidenciaMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 109, 173),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Registro de Asistencias",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: fetchAsistencias,
                    tooltip: "Recargar",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre',
                      filled: true,
                      fillColor: Colors.grey[100],
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedIncidencia,
                  hint: const Text('Filtrar por incidencia'),
                  items: [
                    'Todas',
                    'Falta Justificada',
                    'Visita a Asesor Academico',
                    'Permiso por Enfermedad',
                    'Permiso Social',
                    'Cita Universidad',
                    'Otro',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedIncidencia = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(children: _buildGroupedAsistencias()),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 223, 56, 181),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Volver"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedAsistencias() {
    final Map<String, List<Map<String, dynamic>>> asistenciasPorPersona = {};

    for (var asistencia in filteredAsistencias) {
      final nombre = asistencia['nombre'] ?? 'Sin nombre';
      if (!asistenciasPorPersona.containsKey(nombre)) {
        asistenciasPorPersona[nombre] = [];
      }
      asistenciasPorPersona[nombre]!.add(asistencia);
    }

    return asistenciasPorPersona.entries.map((entry) {
      final nombre = entry.key;
      final asistencias = entry.value;

      return ExpansionTile(
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color.fromARGB(255, 167, 44, 152)),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                dataRowHeight: 48,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text("Fecha")),
                  DataColumn(label: Text("Día")),
                  DataColumn(label: Text("Entrada")),
                  DataColumn(label: Text("Salida")),
                  DataColumn(label: Text("Retardo")),
                  DataColumn(label: Text("Incidencia")),
                  DataColumn(label: Text("Observaciones")),
                ],
                rows: asistencias.map((item) {
                  final tieneRetardo = item['retardo'] != 'No';
                  final tieneIncidencia = item['incidencia'] != 'Ninguna';

                  Color? rowColor;
                  if (tieneIncidencia) {
                    rowColor = Colors.orange[100];
                  } else if (tieneRetardo) {
                    rowColor = Colors.red[100];
                  }

                  return DataRow(
                    color: rowColor != null
                        ? MaterialStateProperty.all(rowColor)
                        : null,
                    cells: [
                      DataCell(Text(item['fecha'] ?? '-')),
                      DataCell(Text(item['dia'] ?? '-')),
                      DataCell(
                        Text(item['hora_entrada'] ?? '-'),
                        onTap: tieneRetardo
                            ? () => _showDetalleRetardo(context, item)
                            : null,
                      ),
                      DataCell(Text(item['hora_salida'] ?? '-')),
                      DataCell(Text(item['retardo'] ?? '-')),
                      DataCell(Text(item['incidencia'] ?? '-')),
                      DataCell(Text(item['observaciones'] ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  void _showDetalleRetardo(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalle de retardo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${item['nombre']}'),
            Text('Fecha: ${item['fecha']}'),
            Text('Hora de entrada: ${item['hora_entrada']}'),
            Text('Hora esperada: ${item['horario_entrada']}'),
            Text('Retardo: ${item['retardo']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

