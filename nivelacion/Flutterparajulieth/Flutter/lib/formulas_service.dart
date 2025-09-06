import 'dart:convert';
import 'package:http/http.dart' as http;

class FormulaService {
  final String token;
  final int idMedico;

  FormulaService({
    required this.token,
    required this.idMedico,
  });

  /// Obtener citas del médico
  Future<List<Map<String, dynamic>>> fetchCitas() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/appointment/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['response']);
        final responseList = data['response'] as List<dynamic>? ?? [];

        // Filtrar citas con id_paciente válido
        final citasValidas = responseList
            .where((e) =>
                e['id_paciente'] != null &&
                (e['id_paciente'] is int) &&
                e['id_paciente'] > 0)
            .toList();

        return citasValidas.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception('Error al cargar citas: ${response.statusCode}');
    } catch (e) {
      print('fetchCitas error: $e');
      return [];
    }
  }

  /// Obtener lista de medicamentos disponibles
  Future<List<Map<String, dynamic>>> fetchMedicamentos() async {
  try {
    print("🔹 fetchMedicamentos: iniciando petición"); // <-- Debug
    final response = await http.get(
      Uri.parse('http://localhost:3000/medicine/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print("🔹 fetchMedicamentos: status code = ${response.statusCode}"); // <-- Debug

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("🔹 fetchMedicamentos: data recibida -> ${data['response']}"); // <-- Debug
      final meds = data['response'] as List<dynamic>? ?? [];
      return meds.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    throw Exception('Error al cargar medicamentos: ${response.statusCode}');
  } catch (e) {
    print('fetchMedicamentos error: $e');
    return [];
  }
}

  /// Crear fórmula con detalles
  Future<bool> crearFormula({
  required int idCita,
  required int idPaciente,
  required String observaciones,
  required List<Map<String, dynamic>> detalles,
  required int idMedico, // <- ahora se pasa desde la pantalla
}) async {
  try {
    final bodyFormula = json.encode({
      "id_cita": idCita,
      "id_medico": idMedico,
      "id_paciente": idPaciente,
      "fecha": DateTime.now().toIso8601String(),
      "observaciones": observaciones,
    });

    final responseFormula = await http.post(
      Uri.parse('http://localhost:3000/for/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: bodyFormula,
    );

    if (responseFormula.statusCode != 201) {
      final formulaData = json.decode(responseFormula.body);
      print('Error creando fórmula: ${formulaData['error'] ?? responseFormula.body}');
      return false;
    }

    final formulaData = json.decode(responseFormula.body)['response'];
    final idFormula = formulaData['id_formula'];

    for (var det in detalles) {
      final bodyDetalle = json.encode({
        "id_formula": idFormula,
        "id_medicamento": det['id_medicamento'],
        "cantidad": det['cantidad'],
        "dosis": det['dosis'],
        "duracion": det['duracion'],
      });

      final respDetalle = await http.post(
        Uri.parse('http://localhost:3000/formDetail/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: bodyDetalle,
      );

      if (respDetalle.statusCode != 201) {
        print('Error creando detalle: ${respDetalle.body}');
        return false;
      }
    }

    return true;
  } catch (e) {
    print('crearFormula error: $e');
    return false;
  }
}

  /// Validar detalle de medicamento
  bool validarDetalle(Map<String, dynamic> detalle) {
    return detalle.containsKey('id_medicamento') &&
        detalle.containsKey('cantidad') &&
        detalle['cantidad'].toString().isNotEmpty;
  }

  /// Sumar todas las cantidades de medicamentos
  int totalMedicamentos(List<Map<String, dynamic>> detalles) {
    int total = 0;
    for (var det in detalles) {
      final cantidad = int.tryParse(det['cantidad'].toString()) ?? 0;
      total += cantidad;
    }
    return total;
  }
}
