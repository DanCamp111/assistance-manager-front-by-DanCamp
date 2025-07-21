import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imdec_front/models/rol_dto.dart';


class RolService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<List<RolDTO>> getRoles() async {
    final response = await http.get(Uri.parse('$_baseUrl/roles'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => RolDTO.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar roles');
    }
  }

  Future<RolDTO> crearRol(RolDTO rol) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/roles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(rol.toJson()),
    );

    if (response.statusCode == 201) {
      return RolDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear rol');
    }
  }

  Future<RolDTO> actualizarRol(RolDTO rol) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/roles/${rol.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(rol.toJson()),
    );

    if (response.statusCode == 200) {
      return RolDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar rol');
    }
  }

  Future<void> eliminarRol(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/roles/$id'));

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar rol');
    }
  }
}
