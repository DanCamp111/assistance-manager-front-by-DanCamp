import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import '../models/asistencia_dto.dart';
import 'package:flutter/foundation.dart';

class AsistenciaService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<String> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')?.trim();

      if (token == null || token.isEmpty) {
        throw Exception('No hay sesión activa. Por favor inicie sesión.');
      }

      return token;
    } catch (e) {
      throw Exception('Error al verificar la autenticación');
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<AsistenciaDTO>> getAsistencias({
    Map<String, String>? filters,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/asistencias',
      ).replace(queryParameters: filters);

      final response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AsistenciaDTO.fromJson(e)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al obtener asistencias');
      }
    } catch (e) {
      throw Exception('Error al cargar asistencias: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> createAsistencia(AsistenciaDTO dto) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias');
      final body = jsonEncode(dto.toJson());

      final response = await http.post(
        uri,
        headers: await _getAuthHeaders(),
        body: body,
      );

      if (response.statusCode == 201) {
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al crear asistencia');
      }
    } catch (e) {
      throw Exception('Error al registrar asistencia: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> updateAsistencia(int id, AsistenciaDTO dto) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');
      final body = jsonEncode(dto.toJson());

      final response = await http.put(
        uri,
        headers: await _getAuthHeaders(),
        body: body,
      );

      if (response.statusCode == 200) {
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al actualizar asistencia');
      }
    } catch (e) {
      throw Exception('Error al actualizar asistencia: ${e.toString()}');
    }
  }

  Future<void> deleteAsistencia(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');

      final response = await http.delete(uri, headers: await _getAuthHeaders());

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al eliminar asistencia');
      }
    } catch (e) {
      throw Exception('Error al eliminar asistencia: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> getAsistenciaById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');

      final response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Asistencia no encontrada');
      }
    } catch (e) {
      throw Exception('Error al obtener asistencia: ${e.toString()}');
    }
  }
}

extension AsistenciaFotoUpload on AsistenciaService {
  Future<String?> subirFoto(int asistenciaId, PlatformFile file) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$asistenciaId/foto');

      if (file.bytes == null) {
        throw Exception('El archivo no tiene datos');
      }

      final token = await _getToken();
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'foto',
            file.bytes!,
            filename: file.name,
            contentType: MediaType.parse(
              lookupMimeType(file.name) ?? 'image/jpeg',
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
        throw Exception(error['message'] ?? 'Error al subir foto');
      }
    } catch (e) {
      throw Exception('Error al subir foto: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getHistorialSemanal() async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/semanal');

      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al obtener historial');
      }
    } catch (e) {
      throw Exception('Error al cargar historial semanal: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getHistorialSemanalAdmin() async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/semanal-admin');
      debugPrint('📡 GET Historial Semanal Admin: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      debugPrint('🔄 Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint('✅ Historial admin obtenido: ${data}');
        return data.cast<Map<String, dynamic>>();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Error al obtener historial de administrador',
        );
      }
    } catch (e) {
      debugPrint('‼️ Excepción en getHistorialSemanalAdmin: $e');
      throw Exception('Error al cargar historial: ${e.toString()}');
    }
  }
}
