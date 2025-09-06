import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LaboratoriosPage extends StatefulWidget {
  final String token;
  final int userId;

  const LaboratoriosPage({super.key, required this.token, required this.userId});

  @override
  State<LaboratoriosPage> createState() => _LaboratoriosPageState();
}

class _LaboratoriosPageState extends State<LaboratoriosPage> {
  late Future<List<Map<String, dynamic>>> _futureLaboratorios;

  @override
  void initState() {
    super.initState();
    _futureLaboratorios = fetchLaboratorios(widget.userId);
  }

  Future<List<Map<String, dynamic>>> fetchLaboratorios(int idPaciente) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/laboratory/paciente/$idPaciente'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final labs = data['response'] as List<dynamic>? ?? [];
        print('Laboratorios recibidos para el paciente $idPaciente: $labs');
        return labs.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception('Error al cargar laboratorios: ${response.statusCode}');
    } catch (e) {
      print('fetchLaboratorios error: $e');
      return [];
    }
  }

  void _crearLaboratorio() async {
    DateTime? fechaSeleccionada;
    String tipoPrueba = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.blue.shade50,
          title: const Text('Crear laboratorio', style: TextStyle(color: Colors.blueAccent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Tipo de examen',
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade700),
                    ),
                  ),
                  onChanged: (v) => tipoPrueba = v,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar fecha'),
                  onPressed: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      selectableDayPredicate: (date) =>
                          date.weekday != DateTime.saturday &&
                          date.weekday != DateTime.sunday,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Colors.blue.shade700,
                              onPrimary: Colors.white,
                              onSurface: Colors.blue.shade900,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (fecha != null) {
                      setState(() {
                        fechaSeleccionada = fecha;
                      });
                    }
                  },
                ),
                if (fechaSeleccionada != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Fecha seleccionada: ${fechaSeleccionada!.toIso8601String().substring(0, 10)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
              onPressed: () async {
                if (tipoPrueba.isEmpty || fechaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debes seleccionar tipo de examen y fecha')),
                  );
                  return;
                }

                final response = await http.post(
                  Uri.parse('http://localhost:3000/laboratory/'),
                  headers: {
                    'Authorization': 'Bearer ${widget.token}',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'id_paciente': widget.userId,
                    'tipo_prueba': tipoPrueba,
                    'fecha': fechaSeleccionada!.toIso8601String(),
                  }),
                );

                print('Respuesta creación laboratorio: ${response.body}');
                Navigator.pop(context);

                setState(() {
                  _futureLaboratorios = fetchLaboratorios(widget.userId);
                });
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _reprogramarLaboratorio(int idLaboratorio, DateTime fechaActual) async {
    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: fechaActual.isBefore(DateTime.now()) ? DateTime.now() : fechaActual,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (date) =>
          date.weekday != DateTime.saturday && date.weekday != DateTime.sunday,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.blue.shade900,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
            ),
          ),
          child: child!,
        );
      },
    );

    if (nuevaFecha != null) {
      final response = await http.put(
        Uri.parse('http://localhost:3000/laboratory/$idLaboratorio'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fecha': nuevaFecha.toIso8601String()}),
      );

      print('Respuesta reprogramación: ${response.body}');
      setState(() {
        _futureLaboratorios = fetchLaboratorios(widget.userId);
      });
    }
  }

  void _eliminarLaboratorio(int idLaboratorio) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/laboratory/$idLaboratorio'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    print('Respuesta eliminación: ${response.body}');
    setState(() {
      _futureLaboratorios = fetchLaboratorios(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Laboratorios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _crearLaboratorio,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureLaboratorios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar laboratorios'),
            );
          }

          final labs = snapshot.data ?? [];
          if (labs.isEmpty) {
            return const Center(child: Text('No hay laboratorios registrados.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: labs.length,
            itemBuilder: (_, i) {
              final lab = labs[i];
              print('Laboratorio #${lab['id_laboratorio']}: $lab');

              return Card(
                color: Colors.white,
                shadowColor: Colors.blue.shade200,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    lab['tipo_prueba'],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  subtitle: Text(
                    'Fecha: ${lab['fecha']?.substring(0, 10) ?? ''}\nResultados: ${lab['resultados'] ?? 'No disponible'}',
                    style: const TextStyle(color: Colors.blueGrey),
                  ),
                  leading: const Icon(Icons.biotech_outlined, color: Colors.blueAccent),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_calendar, color: Colors.blueAccent),
                        onPressed: () => _reprogramarLaboratorio(
                            lab['id_laboratorio'],
                            DateTime.parse(lab['fecha'])),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () =>
                            _eliminarLaboratorio(lab['id_laboratorio']),
                      ),
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