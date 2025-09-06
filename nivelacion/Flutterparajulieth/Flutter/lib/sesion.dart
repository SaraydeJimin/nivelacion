import 'package:shared_preferences/shared_preferences.dart';

class Sesion {
  static String? token;
  static String? userId;

 static Future<void> cargarSesion() async {
  final prefs = await SharedPreferences.getInstance();
  token = prefs.getString("token");

  // Recuperar como int y convertir a String
  final int? id = prefs.getInt("userId");
  userId = id?.toString();
}

  static Future<void> cerrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("userId");
    await prefs.remove("isLogged");
    await prefs.remove("rol");
  }
}
