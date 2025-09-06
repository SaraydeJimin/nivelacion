import 'dart:convert';
import 'package:http/http.dart' as http;

class PacienteService {
  final String token;

  PacienteService({required this.token});

  /// Obtener fórmulas del paciente
  Future<List<Map<String, dynamic>>> fetchMisFormulas(int idPaciente) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/for/paciente/$idPaciente'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final formulas = data['response'] as List<dynamic>? ?? [];
        return formulas.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception('Error al cargar fórmulas: ${response.statusCode}');
    } catch (e) {
      print('fetchMisFormulas error: $e');
      return [];
    }
  }
}
