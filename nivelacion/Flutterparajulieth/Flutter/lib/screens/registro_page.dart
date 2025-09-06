import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../custom_alert.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({Key? key}) : super(key: key);

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final numDocumentoController = TextEditingController();
  final direccionController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmContrasenaController = TextEditingController();

  final List<Map<String, String>> tipoDocs = [
    {"tipo_documento": "CC", "nombre": "Cédula de ciudadanía"},
    {"tipo_documento": "TI", "nombre": "Tarjeta de identidad"},
    {"tipo_documento": "CE", "nombre": "Cédula de extranjería"},
    {"tipo_documento": "PAS", "nombre": "Pasaporte"},
  ];

  String? selectedTipoDoc;
  bool _mostrarContrasena = false;
  bool _mostrarConfirmContrasena = false;

  @override
  void initState() {
    super.initState();
    selectedTipoDoc = tipoDocs.first['tipo_documento'];
  }

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (contrasenaController.text != confirmContrasenaController.text) {
      CustomAlert.showError(context, 'Las contraseñas no coinciden');
      return;
    }

    Map<String, dynamic> formData = {
      "nombre": nombresController.text,
      "apellido": apellidosController.text,
      "telefono": telefonoController.text,
      "email": emailController.text,
      "tipo_documento": selectedTipoDoc,
      "documento": numDocumentoController.text,
      "direccion": direccionController.text,
      "password": contrasenaController.text,
      "id_rol": 1,
    };

    try {
      print("📤 Enviando datos al backend:");
      print(jsonEncode(formData));

      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/login/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(formData),
      );

      print("📥 Código de respuesta: ${response.statusCode}");
      print("📥 Body: ${response.body}");

      if (response.statusCode == 201) {
        CustomAlert.showSuccess(context, 'Registro exitoso');
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(response.body);
        CustomAlert.showError(
            context, errorData['mensaje'] ?? 'Error en el registro');
      }
    } catch (e, stacktrace) {
      print("❌ Error en handleSubmit: $e");
      print(stacktrace);
      CustomAlert.showError(context, 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB), // azul muy clarito de fondo
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Encabezado curvo azul
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF0D47A1), // azul fuerte
                ),
              ),

              // 🔙 Botón "Volver"
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.pop(context),
                  splashColor: Colors.blue.shade100,
                  highlightColor: Colors.blue.shade50,
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Color(0xFF1976D2)),
                      SizedBox(width: 5),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔽 Título y formulario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildInputField(
                              nombresController, 'Nombres', Icons.person),
                          buildInputField(apellidosController, 'Apellidos',
                              Icons.person_outline),
                          buildInputField(
                              telefonoController, 'Teléfono', Icons.phone),
                          buildInputField(
                              emailController, 'Email', Icons.email),

                          DropdownButtonFormField<String>(
                            value: selectedTipoDoc,
                            decoration: buildInputDecoration(
                                'Tipo de documento', Icons.assignment),
                            items: tipoDocs.map((tipo) {
                              return DropdownMenuItem<String>(
                                value: tipo['tipo_documento'],
                                child: Text(tipo['nombre']!),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => selectedTipoDoc = value),
                            validator: (value) =>
                                value == null ? 'Seleccione un tipo' : null,
                          ),

                          const SizedBox(height: 15),
                          buildInputField(numDocumentoController,
                              'Número de documento', Icons.credit_card),
                          buildInputField(
                              direccionController, 'Dirección', Icons.home),
                          buildPasswordField(contrasenaController, 'Contraseña',
                              _mostrarContrasena, () {
                            setState(
                                () => _mostrarContrasena = !_mostrarContrasena);
                          }),
                          buildPasswordField(
                              confirmContrasenaController,
                              'Confirmar contraseña',
                              _mostrarConfirmContrasena, () {
                            setState(() => _mostrarConfirmContrasena =
                                !_mostrarConfirmContrasena);
                          }),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1976D2), // azul botón
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Registrarse',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: buildInputDecoration(label, icon),
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF1976D2)),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label,
      bool mostrar, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: !mostrar,
        decoration: buildInputDecoration(label, Icons.lock).copyWith(
          suffixIcon: IconButton(
            icon: Icon(mostrar ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF1976D2)),
            onPressed: toggle,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }
}

// 🔷 Header clipper
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.5, size.height, size.width, size.height * 0.7);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}