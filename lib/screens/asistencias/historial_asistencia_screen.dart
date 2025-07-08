import 'package:flutter/material.dart';
import 'package:imdec_front/services/asistencia_service.dart';


class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() => _HistorialAsistenciaScreenState();
}

class _HistorialAsistenciaScreenState extends State<HistorialAsistenciaScreen> {
  List<Map<String, dynamic>> historial = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistorial();
  }

  Future<void> fetchHistorial() async {
    try {
      final data = await AsistenciaService().getHistorialSemanal();
      setState(() {
        historial = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial Semanal")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn(label: Text("Día")),
                  DataColumn(label: Text("Entrada")),
                  DataColumn(label: Text("Salida")),
                  DataColumn(label: Text("Horas Comida")),
                  DataColumn(label: Text("Retardo")),
                  DataColumn(label: Text("Incidencias")),
                  DataColumn(label: Text("Observaciones")),
                ],
                rows: historial.map((item) {
                  final tieneRetardo = item['retardo'] != 'No' && item['retardo'] != '-';
                  final tieneIncidencia = item['incidencias'] != 'Ninguna';

                  Color? rowColor;
                  if (tieneIncidencia) {
                    rowColor = Colors.orange[100];
                  } else if (tieneRetardo) {
                    rowColor = Colors.red[100];
                  }

                  return DataRow(
                    color: rowColor != null ? MaterialStateProperty.all(rowColor) : null,
                    cells: [
                      DataCell(Text(item['dia'] ?? '-')),
                      DataCell(Text(item['entrada'] is String ? item['entrada'] : '-')),
                      DataCell(Text(item['salida'] is String ? item['salida'] : '-')),
                      DataCell(Text(item['horas_comida'] ?? '-')),
                      DataCell(Text(item['retardo'] ?? '-')),
                      DataCell(Text(item['incidencias'] ?? '-')),
                      DataCell(Text(item['observaciones'] ?? '-')),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
