import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../sesion.dart';
import '../constans.dart';
import '../ui/onboarding_screen.dart';
import '../principal.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String nombres = "";
  String apellidos = "";
  String email = "";
  String telefono = "";

  int _currentImageIndex = 0;
  late Timer _timer;

  final List<String> _imagenes = [
    "assets/imagen/perro_perfil.png",
    "assets/imagen/gato_perfil.png",
  ];

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _contrasenaController;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();

    _nombresController = TextEditingController();
    _apellidosController = TextEditingController();
    _emailController = TextEditingController();
    _telefonoController = TextEditingController();
    _contrasenaController = TextEditingController();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _imagenes.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> obtenerDatosUsuario() async {
    await Sesion.cargarSesion();

    if (Sesion.userId == null || Sesion.token == null) {
      print("No hay sesión activa");
      return;
    }

    final url = Uri.parse(
        'http://localhost:3000/login/${Sesion.userId}');
        print("📡 URL solicitada: $url");
    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer ${Sesion.token}",
        "Cache-Control": "no-cache",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Tu backend devuelve { "user": { ... } }
      final usuario = data;

      setState(() {
        nombres = usuario["nombres"] ?? "";
        apellidos = usuario["apellidos"] ?? "";
        email = usuario["email"] ?? "";
        telefono = usuario["telefono"] ?? "";

        _nombresController.text = nombres;
        _apellidosController.text = apellidos;
        _emailController.text = email;
        _telefonoController.text = telefono;
      });
    } else {
      print("Error al obtener datos del usuario: ${response.statusCode}");
    }
  }

  void cerrarSesion() async {
    await Sesion.cerrar();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  void _mostrarEditarPerfilModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Editar perfil',
            style: TextStyle(color: Constants.naranjaOscuro),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _inputField(_nombresController, 'Nombres'),
                  _inputField(_apellidosController, 'Apellidos'),
                  _inputField(_emailController, 'Correo',
                      inputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su correo';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      }),
                  _inputField(_telefonoController, 'Teléfono',
                      inputType: TextInputType.phone),
                  _inputField(_contrasenaController, 'Contraseña',
                      isPassword: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Constants.naranjaClaro,
              ),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.naranjaOscuro,
              ),
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _actualizarPerfil();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _inputField(TextEditingController controller, String label,
      {bool isPassword = false,
      TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Constants.naranjaClaro.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
                color: Constants.naranjamasOscuro, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:
                const BorderSide(color: Constants.naranjaOscuro, width: 1.8),
          ),
        ),
      ),
    );
  }

  Future<void> _actualizarPerfil() async {
    final url = Uri.parse(
        'http://localhost:3000/login/${Sesion.userId}');
    final body = {
      "nombres": _nombresController.text.trim(),
      "apellidos": _apellidosController.text.trim(),
      "email": _emailController.text.trim(),
      "telefono": _telefonoController.text.trim(),
    };

    if (_contrasenaController.text.trim().isNotEmpty) {
      body["password"] = _contrasenaController.text.trim();
    }

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer ${Sesion.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        nombres = body["nombres"]!;
        apellidos = body["apellidos"]!;
        email = body["email"]!;
        telefono = body["telefono"]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al actualizar perfil: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Constants.naranjaOscuro),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const EpsHomeShell()),
                    );
                  },
                ),
                const Text(
                  "Volver",
                  style: TextStyle(
                    color: Constants.naranjaOscuro,
                    fontSize: 16,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.account_circle,
                    color: Constants.naranjaClaro, size: 30),
                SizedBox(width: 8),
                Text(
                  'Perfil',
                  style: TextStyle(
                    color: Constants.naranjaClaro,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Image.asset(
                            _imagenes[_currentImageIndex],
                            key: ValueKey<String>(_imagenes[_currentImageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    infoRow("Nombres:", nombres),
                    infoRow("Apellidos:", apellidos),
                    infoRow("Correo:", email),
                    infoRow("Teléfono:", telefono),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.naranjaOscuro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      onPressed: _mostrarEditarPerfilModal,
                      child: const Text(
                        "Editar perfil",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constants.naranjaOscuro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      onPressed: cerrarSesion,
                      child: const Text(
                        "Cerrar sesión",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.naranjaOscuro,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
