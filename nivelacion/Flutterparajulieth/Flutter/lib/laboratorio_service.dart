import 'dart:convert';
import 'package:http/http.dart' as http;

class LaboratorioService {
  final String token;

  LaboratorioService({required this.token});

  // Obtener todos los laboratorios
  Future<List<Map<String, dynamic>>> getAllLaboratorios() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/laboratory/all'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final labs = data['response'] as List<dynamic>? ?? [];
      return labs.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Error al cargar laboratorios');
    }
  }

  // Actualizar resultados (médico) -> solo resultados
  Future<bool> updateResultados(int idLaboratorio, String tipoPrueba,int idCita, int idPaciente, int idMedico, String fecha, String resultados) async {
  final response = await http.put(
    Uri.parse('http://localhost:3000/laboratory/$idLaboratorio'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'id_cita': idCita,
      'id_paciente': idPaciente,
      'id_medico': idMedico,
      'tipo_prueba': tipoPrueba,
      'fecha': fecha,
      'resultados': resultados,
    }),
  );

  print('STATUS PUT: ${response.statusCode}');
  print('BODY PUT: ${response.body}');

  return response.statusCode == 200;
}
}