import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/login_screen.dart';

class AuthService {
  // Obtener datos del usuario logueado
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getInt('id_Usuario');
    final nombres = prefs.getString('nombres');
    final apellidos = prefs.getString('apellidos');
    final telefono = prefs.getString('telefono');
    final correo = prefs.getString('correo');

    if (idUsuario != null && nombres != null && apellidos != null && telefono != null && correo != null) {
      return {
        'id_Usuario': idUsuario,
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
        'correo': correo,
      };
    }
    return null;
  }

  // Guardar datos después de login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_Usuario', userData['id_Usuario']);
    await prefs.setString('nombres', userData['nombres']);
    await prefs.setString('apellidos', userData['apellidos']);
    await prefs.setString('telefono', userData['telefono']);
    await prefs.setString('correo', userData['correo']);
  }

  // Obtener el token JWT almacenado
  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      return token;
    } else {
      throw Exception('Token no encontrado');
    }
  }

  // Cerrar sesión y eliminar datos
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina todos los datos almacenados

    // Redirige a la página de login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
