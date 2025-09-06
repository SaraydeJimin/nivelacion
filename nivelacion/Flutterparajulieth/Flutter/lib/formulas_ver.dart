import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormulaService {
  final String token;

  FormulaService({required this.token});

  Future<List<Map<String, dynamic>>> fetchFormulasByPaciente(int idPaciente) async {
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
      print('fetchFormulasByPaciente error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchDetallesByPaciente(int idPaciente) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/formDetail/all'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detalles = data['response'] as List<dynamic>? ?? [];
        return detalles.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      throw Exception('Error al cargar detalles: ${response.statusCode}');
    } catch (e) {
      print('fetchDetallesByPaciente error: $e');
      return [];
    }
  }
}

class PrescriptionsPage extends StatefulWidget {
  final String token;
  final int idPaciente;

  const PrescriptionsPage({super.key, required this.token, required this.idPaciente});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  late Future<List<Map<String, dynamic>>> _futureFormulas;
  late Future<List<Map<String, dynamic>>> _futureDetalles;
  late FormulaService _service;

  @override
  void initState() {
    super.initState();
    _service = FormulaService(token: widget.token);
    _futureFormulas = _service.fetchFormulasByPaciente(widget.idPaciente);
    _futureDetalles = _service.fetchDetallesByPaciente(widget.idPaciente);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF1E88E5); // Azul EPS

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fórmulas y Medicamentos'),
        backgroundColor: primaryBlue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.wait([_futureFormulas, _futureDetalles]).then((values) {
          final formulas = values[0];
          final detalles = values[1];

          for (var formula in formulas) {
            formula['medicamentos'] = detalles
                .where((d) => d['id_formula'] == formula['id_formula'])
                .toList();
          }

          return formulas;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text('No fue posible cargar tus fórmulas'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureFormulas = _service.fetchFormulasByPaciente(widget.idPaciente);
                        _futureDetalles = _service.fetchDetallesByPaciente(widget.idPaciente);
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final formulas = snapshot.data ?? [];
          if (formulas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Sin fórmulas activas'),
                  SizedBox(height: 8),
                  Text('Cuando un profesional te prescriba, aparecerá aquí.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: formulas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final formula = formulas[i];
              final medicamentos = formula['medicamentos'] as List<dynamic>? ?? [];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services_outlined, color: primaryBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formula['observaciones'] ?? 'Fórmula médica',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${formula['fecha'] ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Profesional: ${formula['nombre_medico'] ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 20, thickness: 1.2),
                      Text('Medicamentos:', style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                      const SizedBox(height: 6),
                      if (medicamentos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'No hay medicamentos asociados a esta fórmula.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ...medicamentos.map((m) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${m['nombre_medicamento']} | Cantidad: ${m['cantidad']} | Dosis: ${m['dosis']} | Duración: ${m['duracion']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}