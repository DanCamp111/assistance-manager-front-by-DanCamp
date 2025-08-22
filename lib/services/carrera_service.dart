import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/carrera_dto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CarreraService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<List<CarreraDTO>> getCarreras() async {
    final response = await http.get(Uri.parse('$_baseUrl/carreras'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => CarreraDTO.fromJson(e)).toList();
    }
    throw Exception('Error al cargar carreras');
  }

  Future<void> crearCarrera(CarreraDTO carrera) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/carreras'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(carrera.toJson()),
    );
    if (response.statusCode != 201) throw Exception('Error al crear carrera');
  }

  Future<void> actualizarCarrera(CarreraDTO carrera) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/carreras/${carrera.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(carrera.toJson()),
    );
    if (response.statusCode != 200) throw Exception('Error al actualizar');
  }

  Future<void> eliminarCarrera(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/carreras/$id'));
    if (response.statusCode != 204) throw Exception('Error al eliminar');
  }
}
