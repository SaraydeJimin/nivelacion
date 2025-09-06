import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../admin_panel.dart';
import '../principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isHovering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔹 Función para iniciar sesión
  Future<void> login() async {
    final String documento = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (documento.isEmpty || password.isEmpty) {
      _showToast("Por favor complete todos los campos", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/login/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"documento": documento, "password": password}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];
        final Map<String, dynamic> user = data['user'];
        final int userId = user['id_usuario'];
        final int role = user['id_rol'];
        final int? idMedico = user['id_medico'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setInt("userId", userId);
        await prefs.setInt("rol", role);
        if (idMedico != null) await prefs.setInt("idMedico", idMedico);
        await prefs.setBool("isLogged", true);

        print('TOKEN: $token');
  print('USER ID: $userId');
  print('ROLE: $role');
  print('ID MEDICO: $idMedico');

        _showToast("Inicio de sesión exitoso");
        _redirectBasedOnRole(role, token, idMedico);
      } else {
        _showToast("Documento o password incorrectos", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast("Error de conexión: ${e.toString()}", isError: true);
    }
  }

  // 🔹 Redirige según el rol
  void _redirectBasedOnRole(int role, String token, int? idMedico) {
    if (role == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MedicoPanel(
            token: token,
            idMedico: idMedico ?? 0,
          ),
        ),
      );
    } else if (role == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EpsHomeShell()),
      );
    }
  }

  // 🔹 Función de toast
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB), // azul clarito de fondo
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF0D47A1), // azul oscuro header
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  onTapDown: (_) => setState(() => _isHovering = true),
                  onTapUp: (_) => setState(() => _isHovering = false),
                  onTapCancel: () => setState(() => _isHovering = false),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: _isHovering
                            ? const Color(0xFF0D47A1)
                            : const Color(0xFF1976D2),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: _isHovering
                              ? const Color(0xFF0D47A1)
                              : const Color(0xFF1976D2),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Inicio de sesión",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Documento",
                        prefixIcon:
                            const Icon(Icons.badge, color: Color(0xFF1976D2)), // 👈 cambiado
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF1976D2)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon:
                            const Icon(Icons.lock, color: Color(0xFF1976D2)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xFF1976D2)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1976D2), // azul botón
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                "Iniciar Sesión",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Clip para el header
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.85);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.85,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}