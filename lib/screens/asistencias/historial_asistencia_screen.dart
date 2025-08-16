import 'package:flutter/material.dart';
import 'package:imdec_front/services/asistencia_service.dart';


class HistorialAsistenciaScreen extends StatefulWidget {
  const HistorialAsistenciaScreen({super.key});

  @override
  State<HistorialAsistenciaScreen> createState() =>
      _HistorialAsistenciaScreenState();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFDD6DAD); // Rosa IMDEC
    final Color primaryDark = const Color(0xFFC7549B);
    final Color headingBgStart = const Color(0xFFF3E6F3);
    final Color headingBgEnd = const Color(0xFFEAD3EA);
    final Color borderColor = Colors.grey.shade300;
    final Color rowHighlightIncidencia = Colors.orange.shade100;
    final Color rowHighlightRetardo = Colors.red.shade100;
    final Color textPrimary = Colors.black87;

    TextStyle headerTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: primaryDark,
      letterSpacing: 0.6,
    );

    TextStyle cellTextStyle = TextStyle(
      fontSize: 14,
      color: textPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historial Semanal",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 16), // menos espacio arriba
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Transform.scale(
                    scale: 1.2, // tabla 20% más grande
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(209, 255, 251, 251),
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: DataTable(
                        headingRowHeight: 44,
                        dataRowHeight: 40,
                        headingRowColor:
                            MaterialStateProperty.all(Colors.transparent),
                        dividerThickness: 1.5,
                        columns: [
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text("Día", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text("Entrada", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text("Salida", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child:
                                  Text("Horas Comida", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text("Retardo", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text("Incidencias", style: headerTextStyle),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [headingBgStart, headingBgEnd],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child:
                                  Text("Observaciones", style: headerTextStyle),
                            ),
                          ),
                        ],
                        rows: historial.map((item) {
                          final tieneRetardo =
                              item['retardo'] != 'No' && item['retardo'] != '-';
                          final tieneIncidencia = item['incidencias'] != 'Ninguna';

                          Color? rowColor;
                          if (tieneIncidencia) {
                            rowColor = rowHighlightIncidencia;
                          } else if (tieneRetardo) {
                            rowColor = rowHighlightRetardo;
                          }

                          return DataRow(
                            color: rowColor != null
                                ? MaterialStateProperty.all(rowColor)
                                : null,
                            cells: [
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(item['dia'] ?? '-', style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                      item['entrada'] is String
                                          ? item['entrada']
                                          : '-',
                                      style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                      item['salida'] is String ? item['salida'] : '-',
                                      style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(item['horas_comida'] ?? '-', style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(item['retardo'] ?? '-', style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(item['incidencias'] ?? '-', style: cellTextStyle),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(item['observaciones'] ?? '-', style: cellTextStyle),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}


