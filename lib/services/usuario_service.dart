import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:imdec_front/models/usuario_dto.dart';

class UsuarioService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<List<UsuarioDTO>> getUsuarios() async {
    print('GET $_baseUrl/usuarios');
    final response = await http.get(Uri.parse('$_baseUrl/usuarios'));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => UsuarioDTO.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

  Future<UsuarioDTO> crearUsuario(UsuarioDTO usuario) async {
    final body = jsonEncode(usuario.toJson());
    print('POST $_baseUrl/usuarios');
    print('Request Body: $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      return UsuarioDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear usuario: ${response.body}');
    }
  }

  Future<UsuarioDTO> actualizarUsuario(UsuarioDTO usuario) async {
    final body = jsonEncode(usuario.toJson());
    print('PUT $_baseUrl/usuarios/${usuario.id}');
    print('Request Body: $body');

    final response = await http.put(
      Uri.parse('$_baseUrl/usuarios/${usuario.id}'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return UsuarioDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar usuario: ${response.body}');
    }
  }

  Future<void> eliminarUsuario(int id) async {
    print('DELETE $_baseUrl/usuarios/$id');

    final response = await http.delete(Uri.parse('$_baseUrl/usuarios/$id'));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar usuario: ${response.body}');
    }
  }
}