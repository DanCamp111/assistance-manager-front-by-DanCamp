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
        //debugPrint('❌ No hay token disponible en SharedPreferences');
        throw Exception('No hay sesión activa. Por favor inicie sesión.');
      }
      
      //debugPrint('🔑 Token obtenido: ${token.substring(0, 10)}...');
      return token;
    } catch (e) {
      //debugPrint('‼️ Error al obtener token: $e');
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

  Future<List<AsistenciaDTO>> getAsistencias({Map<String, String>? filters}) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias').replace(queryParameters: filters);
      // debugPrint('📡 GET Asistencias: $uri');
      // debugPrint('🔍 Filtros: ${filters ?? 'ninguno'}');

      final response = await http.get(
        uri,
        headers: await _getAuthHeaders(),
      );

      // debugPrint('🔄 Código de respuesta: ${response.statusCode}');
      // debugPrint('📄 Body de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        //debugPrint('✅ Asistencias obtenidas: ${data.length} registros');
        return data.map((e) => AsistenciaDTO.fromJson(e)).toList();
      } else {
        final error = jsonDecode(response.body);
        //debugPrint('❌ Error al obtener asistencias: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al obtener asistencias');
      }
    } catch (e) {
      //debugPrint('‼️ Excepción en getAsistencias: $e');
      throw Exception('Error al cargar asistencias: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> createAsistencia(AsistenciaDTO dto) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias');
      final body = jsonEncode(dto.toJson());
      
      // debugPrint('📡 POST Crear Asistencia: $uri');
      // debugPrint('📦 Body enviado: $body');

      final response = await http.post(
        uri,
        headers: await _getAuthHeaders(),
        body: body,
      );

      // debugPrint('🔄 Código de respuesta: ${response.statusCode}');
      // debugPrint('📄 Body de respuesta: ${response.body}');

      if (response.statusCode == 201) {
        //debugPrint('✅ Asistencia creada exitosamente');
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        //debugPrint('❌ Error al crear asistencia: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al crear asistencia');
      }
    } catch (e) {
      //debugPrint('‼️ Excepción en createAsistencia: $e');
      throw Exception('Error al registrar asistencia: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> updateAsistencia(int id, AsistenciaDTO dto) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');
      final body = jsonEncode(dto.toJson());
      
      // debugPrint('📡 PUT Actualizar Asistencia: $uri');
      // debugPrint('📦 Body enviado: $body');

      final response = await http.put(
        uri,
        headers: await _getAuthHeaders(),
        body: body,
      );

      // debugPrint('🔄 Código de respuesta: ${response.statusCode}');
      // debugPrint('📄 Body de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        //debugPrint('✅ Asistencia actualizada exitosamente');
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        //debugPrint('❌ Error al actualizar asistencia: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al actualizar asistencia');
      }
    } catch (e) {
      //debugPrint('‼️ Excepción en updateAsistencia: $e');
      throw Exception('Error al actualizar asistencia: ${e.toString()}');
    }
  }

  Future<void> deleteAsistencia(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');
      //debugPrint('📡 DELETE Eliminar Asistencia: $uri');

      final response = await http.delete(
        uri,
        headers: await _getAuthHeaders(),
      );

      //debugPrint('🔄 Código de respuesta: ${response.statusCode}');

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        //debugPrint('❌ Error al eliminar asistencia: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al eliminar asistencia');
      }
      
      //debugPrint('✅ Asistencia eliminada exitosamente');
    } catch (e) {
      //debugPrint('‼️ Excepción en deleteAsistencia: $e');
      throw Exception('Error al eliminar asistencia: ${e.toString()}');
    }
  }

  Future<AsistenciaDTO> getAsistenciaById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$id');
      //debugPrint('📡 GET Obtener Asistencia por ID: $uri');

      final response = await http.get(
        uri,
        headers: await _getAuthHeaders(),
      );

      // debugPrint('🔄 Código de respuesta: ${response.statusCode}');
      // debugPrint('📄 Body de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        //debugPrint('✅ Asistencia obtenida exitosamente');
        return AsistenciaDTO.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        //debugPrint('❌ Error al obtener asistencia: ${error['message']}');
        throw Exception(error['message'] ?? 'Asistencia no encontrada');
      }
    } catch (e) {
      //debugPrint('‼️ Excepción en getAsistenciaById: $e');
      throw Exception('Error al obtener asistencia: ${e.toString()}');
    }
  }
}

extension AsistenciaFotoUpload on AsistenciaService {
  Future<String?> subirFoto(int asistenciaId, PlatformFile file) async {
    try {
      final uri = Uri.parse('$_baseUrl/asistencias/$asistenciaId/foto');
      // debugPrint('📡 POST Subir Foto: $uri');
      // debugPrint('📸 Archivo: ${file.name}, Tamaño: ${file.size} bytes');

      if (file.bytes == null) {
        //debugPrint('❌ El archivo no tiene bytes cargados');
        throw Exception('El archivo no tiene datos');
      }

      final token = await _getToken();
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes(
          'foto',
          file.bytes!,
          filename: file.name,
          contentType: MediaType.parse(lookupMimeType(file.name) ?? 'image/jpeg'),
        ));

     // debugPrint('🔼 Iniciando upload...');
      final response = await request.send();
      final body = await response.stream.bytesToString();
      
      // debugPrint('🔄 Código de respuesta: ${response.statusCode}');
      // debugPrint('📄 Body de respuesta: $body');

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        //debugPrint('✅ Foto subida exitosamente. Path: ${json['path']}');
        return json['path'];
      } else {
        final error = jsonDecode(body);
        //debugPrint('❌ Error al subir foto: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al subir foto');
      }
    } catch (e) {
      //debugPrint('‼️ Excepción en subirFoto: $e');
      throw Exception('Error al subir foto: ${e.toString()}');
    }
  }

Future<List<Map<String, dynamic>>> getHistorialSemanal() async {
  try {
    final uri = Uri.parse('$_baseUrl/asistencias/semanal');
    debugPrint('📡 GET Historial Semanal: $uri');

    final headers = await _getAuthHeaders();
    debugPrint('🧾 Headers enviados: $headers');

    final response = await http.get(uri, headers: headers);

    debugPrint('🔄 Código de respuesta: ${response.statusCode}');
    debugPrint('📄 Body de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      debugPrint('✅ Historial obtenido: ${data.length} días');
      return data.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body);
      debugPrint('❌ Error en respuesta: ${error['message']}');
      throw Exception(error['message'] ?? 'Error al obtener historial');
    }
  } catch (e) {
    debugPrint('‼️ Excepción al cargar historial semanal: $e');
    throw Exception('Error al cargar historial semanal: ${e.toString()}');
  }
}

}
