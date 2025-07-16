import 'package:flutter/material.dart';
import 'package:imdec_front/services/asistencia_service.dart';

class MonitoreoAsistenciasScreen extends StatefulWidget {
  const MonitoreoAsistenciasScreen({super.key});

  @override
  State<MonitoreoAsistenciasScreen> createState() => _MonitoreoAsistenciasScreenState();
}

class _MonitoreoAsistenciasScreenState extends State<MonitoreoAsistenciasScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  List<Map<String, dynamic>> get filteredAsistencias {
    return asistencias.where((asistencia) {
      final nombreMatch = asistencia['nombre'].toString().toLowerCase()
          .contains(searchQuery.toLowerCase());
      final incidenciaMatch = selectedIncidencia == null || 
          selectedIncidencia == 'Todas' ||
          asistencia['incidencia'] == selectedIncidencia;
      return nombreMatch && incidenciaMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoreo de Asistencias"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAsistencias,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre',
                      prefixIcon: Icon(Icons.search),
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
                    'Ninguna',
                    'Justificada',
                    'Injustificada',
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
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn(label: Text("Nombre")),
                        DataColumn(label: Text("Fecha")),
                        DataColumn(label: Text("Día")),
                        DataColumn(label: Text("Entrada")),
                        DataColumn(label: Text("Salida")),
                        DataColumn(label: Text("Retardo")),
                        DataColumn(label: Text("Incidencia")),
                        DataColumn(label: Text("Observaciones")),
                      ],
                      rows: filteredAsistencias.map((item) {
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
                            DataCell(Text(item['nombre'] ?? '-')),
                            DataCell(Text(item['fecha'] ?? '-')),
                            DataCell(Text(item['dia'] ?? '-')),
                            DataCell(
                              Text(item['hora_entrada'] ?? '-'),
                              onTap: tieneRetardo ? () {
                                _showDetalleRetardo(context, item);
                              } : null,
                            ),
                            DataCell(Text(item['hora_salida'] ?? '-')),
                            DataCell(
                              Text(item['retardo'] ?? '-'),
                              showEditIcon: tieneRetardo,
                            ),
                            DataCell(Text(item['incidencia'] ?? '-')),
                            DataCell(Text(item['observaciones'] ?? '-')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
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