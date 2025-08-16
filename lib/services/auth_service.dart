import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';



class AuthService {
  final String _baseUrl = dotenv.env['API_URL']!;
Future<bool> login(String correo, String password) async {
  final url = Uri.parse('$_baseUrl/login');
  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'correo': correo, 'password': password},
    );
    /*debugPrint("📡 Login request → ${response.request?.url}");
    debugPrint("📡 StatusCode → ${response.statusCode}");
    debugPrint("📡 Body crudo → ${response.body}");*/

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //debugPrint("✅ JSON decodificado → $data");
      if (data['token'] == null ||
          data['usuario'] == null ||
          data['usuario']['id'] == null) {
        //debugPrint("❌ Estructura inesperada en respuesta: $data");
        throw Exception(
          'La respuesta del servidor no tiene el formato esperado',
        );
      }

      final token = data['token'] as String;
      final usuario = data['usuario'] as Map<String, dynamic>;
      final usuarioId = usuario['id'] as int;
      final rolId = usuario['rol_id'] as int;
      // 👇 Mapeo de roles
      String rolName;
      switch (rolId) {
        case 1:
          rolName = "SUPERADMINISTRATOR";
          break;
        case 2:
          rolName = "ADMIN";
          break;
        case 3:
          rolName = "USER";
          break;
        default:
          rolName = "DESCONOCIDO";
      }

      /*debugPrint("🔑 Token → ${token.substring(0, 15)}...");
      debugPrint("👤 Usuario ID → $usuarioId");
      debugPrint("🛡️ Rol ID → $rolId ($rolName)");
      debugPrint("📋 Usuario completo → $usuario");*/

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('usuario_id', usuarioId);
      await prefs.setInt('rol_id', rolId);
      await prefs.setString('role', rolName);

     /* debugPrint(
        "💾 Guardado en SharedPreferences → token, usuario_id, rol_id, role",
      );*/

      return true;
    } else {
      final errorData = json.decode(response.body);
      final errorMsg = errorData['message'] ?? 'Error de autenticación';
      //debugPrint("❌ Error en login: $errorMsg");
      throw Exception(errorMsg);
    }
  } catch (e) {
    debugPrint("‼️ Error en login: $e");
    throw Exception('Error al conectar con el servidor: ${e.toString()}');
  }
}

  Future<void> logout() async {
    //debugPrint('🔐 Intentando logout'); 
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        //debugPrint('⚠️ No hay token almacenado para logout');
        return;
      }
     // debugPrint('🔑 Token usado para logout: ${token.substring(0, 10)}...');
      final url = Uri.parse('$_baseUrl/logout');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      //debugPrint('🔄 Respuesta del logout: ${response.statusCode}');
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('usuario_id');
        //debugPrint('✅ Logout exitoso');
      } else {
        final error = json.decode(response.body);
        //debugPrint('❌ Error en logout: ${error['message']}');
        throw Exception(error['message'] ?? 'Error al cerrar sesión');
      }
    } catch (e) {
      //debugPrint('‼️ Error en logout: $e');
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLogged = token != null && token.isNotEmpty;
      //debugPrint('🔍 Verificando sesión: ${isLogged ? 'ACTIVA' : 'INACTIVA'}');
      // if (isLogged) {
      //   debugPrint('🔑 Token encontrado: ${token!.substring(0, 10)}...');
      // }
      return isLogged;
    } catch (e) {
      //debugPrint('‼️ Error al verificar sesión: $e');
      return false;
    }
  }

  Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token')?.trim();
      // //debugPrint('🔍 Obteniendo token actual');
      // if (token != null) {
      //   //debugPrint('🔑 Token actual: ${token.substring(0, 10)}...');
      // } else {
      //   //debugPrint('⚠️ No hay token almacenado');
      // }
      return token;
    } catch (e) {
      //debugPrint('‼️ Error al obtener token: $e');
      return null;
    }
  }

  Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('usuario_id');      
      // debugPrint('🔍 Obteniendo ID de usuario actual');
      // if (userId != null) {
      //   debugPrint('👤 ID de usuario: $userId');
      // } else {
      //   debugPrint('⚠️ No hay ID de usuario almacenado');
      // }
      return userId;
    } catch (e) {
      //debugPrint('‼️ Error al obtener ID de usuario: $e');
      return null;
    }
  }
}