import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

import '../models/incidencia_dto.dart';

class IncidenciaService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa. Por favor inicie sesión.');
    }
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<IncidenciaDTO>> getIncidencias({
    Map<String, String>? filters,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/incidencias',
    ).replace(queryParameters: filters);
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> items = data is List ? data : data['data'];
      return items.map((e) => IncidenciaDTO.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al obtener incidencias');
    }
  }

  Future<IncidenciaDTO> getIncidenciaById(int id) async {
    final uri = Uri.parse('$_baseUrl/incidencias/$id');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return IncidenciaDTO.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Incidencia no encontrada');
    }
  }

  Future<IncidenciaDTO> createIncidencia(IncidenciaDTO dto) async {
    final uri = Uri.parse('$_baseUrl/incidencias');
    final body = jsonEncode(dto.toJson());

    final response = await http.post(
      uri,
      headers: await _getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 201) {
      return IncidenciaDTO.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al crear incidencia');
    }
  }

  Future<IncidenciaDTO> updateIncidencia(int id, IncidenciaDTO dto) async {
    final uri = Uri.parse('$_baseUrl/incidencias/$id');
    final body = jsonEncode(dto.toJson());

    final response = await http.put(
      uri,
      headers: await _getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      return IncidenciaDTO.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al actualizar incidencia');
    }
  }

  Future<void> deleteIncidencia(int id) async {
    final uri = Uri.parse('$_baseUrl/incidencias/$id');
    final response = await http.delete(uri, headers: await _getAuthHeaders());

    if (response.statusCode != 204) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al eliminar incidencia');
    }
  }

  Future<IncidenciaDTO> cambiarEstatus({
    required int id,
    required String estatus,
    required int supervisorId,
    String? observaciones,
  }) async {
    final uri = Uri.parse('$_baseUrl/incidencias/$id/estatus');

    final body = {
      'estatus': estatus,
      'observaciones': observaciones,
      'supervisor_id': supervisorId,
    };

    final headers = await _getAuthHeaders();

    print('🔁 Cambiando estatus de incidencia');
    print('🔗 URL: $uri');
    print('📤 Headers: $headers');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('📥 Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Estatus cambiado correctamente');
      return IncidenciaDTO.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      print('❌ Error al cambiar estatus: ${error['message']}');
      throw Exception(error['message'] ?? 'Error al cambiar estatus');
    }
  }

  Future<List<IncidenciaDTO>> listarTodas() async {
    final uri = Uri.parse('$_baseUrl/incidencias');
    final headers = await _getAuthHeaders();
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => IncidenciaDTO.fromJson(e)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al cargar incidencias');
    }
  }

  Future<String?> subirDocumento(int incidenciaId, PlatformFile file) async {
    try {
      final uri = Uri.parse('$_baseUrl/incidencias/$incidenciaId/documento');

      if (file.bytes == null) {
        throw Exception('El archivo no tiene datos');
      }

      final token = await _getToken();
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'documento',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(
              lookupMimeType(file.name) ?? 'application/octet-stream',
            ),
          ),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        return json['path'];
      } else {
        final error = jsonDecode(body);
        throw Exception(error['message'] ?? 'Error al subir documento');
      }
    } catch (e) {
      throw Exception('Error al subir documento: ${e.toString()}');
    }
  }
}
