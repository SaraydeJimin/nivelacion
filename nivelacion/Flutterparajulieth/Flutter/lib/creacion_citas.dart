import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppointmentsPage extends StatefulWidget {
  final int idPaciente;
  final String token;
  const AppointmentsPage({super.key, required this.idPaciente, required this.token});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<Map<String, List<Map<String, dynamic>>>> _futureData;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    initNotifications();
    _futureData = fetchAllData();
  }

  // ==================== NOTIFICACIONES ====================
  Future<void> initNotifications() async {
    if (kIsWeb || ![TargetPlatform.android, TargetPlatform.iOS].contains(Theme.of(context).platform)) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleReminder(DateTime citaDate, String medico) async {
    if (kIsWeb || ![TargetPlatform.android, TargetPlatform.iOS].contains(Theme.of(context).platform)) {
      Future.delayed(citaDate.difference(DateTime.now()), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recordatorio: Cita con $medico a ${citaDate.hour.toString().padLeft(2,'0')}:${citaDate.minute.toString().padLeft(2,'0')}',
            ),
            backgroundColor: Colors.blue.shade700,
          ),
        );
      });
      return;
    }

    final reminderTime = citaDate.subtract(const Duration(minutes: 30));
    final tzScheduled = tz.TZDateTime.from(reminderTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Recordatorio de cita',
      'Tienes una cita con $medico a las ${citaDate.hour.toString().padLeft(2,'0')}:${citaDate.minute.toString().padLeft(2,'0')}',
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'Recordatorios',
          channelDescription: 'Recordatorios de citas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ==================== FETCH CITAS + MEDICOS ====================
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllData() async {
    final citasResponse = await http.get(
      Uri.parse('http://localhost:3000/appointment/paciente/${widget.idPaciente}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    final medicosResponse = await http.get(
      Uri.parse('http://localhost:3000/doctor/all'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (citasResponse.statusCode != 200) throw Exception('Error al obtener citas');
    if (medicosResponse.statusCode != 200) throw Exception('Error al obtener médicos');

    final citasDecodedRaw = jsonDecode(citasResponse.body);
    List<dynamic> listaCitas = citasDecodedRaw is Map && citasDecodedRaw.containsKey('response')
        ? citasDecodedRaw['response']
        : citasDecodedRaw is List
            ? citasDecodedRaw
            : [];
    final citas = listaCitas.map((e) => Map<String, dynamic>.from(e)).toList();

    final medicosDecodedRaw = jsonDecode(medicosResponse.body);
    List<dynamic> listaMedicos = medicosDecodedRaw is Map && medicosDecodedRaw.containsKey('response')
        ? medicosDecodedRaw['response']
        : medicosDecodedRaw is List
            ? medicosDecodedRaw
            : [];
    final medicos = listaMedicos.map((e) => Map<String, dynamic>.from(e)).toList();

    return {'citas': citas, 'medicos': medicos};
  }

  // ==================== CREATE ====================
  Future<void> createCita(int idMedico, DateTime fecha, TimeOfDay hora) async {
    final body = jsonEncode({
      'id_paciente': widget.idPaciente,
      'id_medico': idMedico,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
    });

    final response = await http.post(
      Uri.parse('http://localhost:3000/appointment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: const Text('Cita creada correctamente'),
            backgroundColor: Colors.blue.shade700,
          ));
      setState(() => _futureData = fetchAllData());

      scheduleReminder(
        DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute),
        'Dr. ${idMedico}',
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: Text('Error al crear cita: ${response.body}'),
            backgroundColor: Colors.red.shade700,
          ));
    }
  }

  // ==================== UPDATE ====================
  Future<void> updateCita(int idCita, DateTime fecha, TimeOfDay hora) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/appointment/$idCita'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'fecha': fecha.toIso8601String().split('T')[0],
        'hora': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: const Text('Cita actualizada correctamente'),
            backgroundColor: Colors.blue.shade700,
          ));
      setState(() => _futureData = fetchAllData());
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: const Text('Error al actualizar cita'),
            backgroundColor: Colors.red.shade700,
          ));
    }
  }

  // ==================== DELETE ====================
  Future<void> deleteCita(int idCita) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/appointment/$idCita'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: const Text('Cita eliminada correctamente'),
            backgroundColor: Colors.blue.shade700,
          ));
      setState(() => _futureData = fetchAllData());
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            content: const Text('Error al eliminar cita'),
            backgroundColor: Colors.red.shade700,
          ));
    }
  }

  // ==================== DIALOG ====================
  void showCitaDialog({
    Map<String, dynamic>? cita,
    required List<Map<String, dynamic>> medicos,
  }) async {
    final fechaController = TextEditingController(text: cita != null ? cita['fecha'] : '');
    final horaController = TextEditingController(text: cita != null ? cita['hora'] : '');
    int selectedMedicoId = cita != null ? cita['id_medico'] : medicos.first['id_medico'];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        title: Text(cita == null ? 'Crear Cita' : 'Editar Cita', style: const TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  selectableDayPredicate: (date) => date.weekday != DateTime.sunday,
                );
                if (pickedDate != null) {
                  fechaController.text = pickedDate.toIso8601String().split('T')[0];
                }
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: horaController,
              decoration: const InputDecoration(
                labelText: 'Hora',
                suffixIcon: Icon(Icons.access_time, color: Colors.blue),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  if (pickedTime.hour < 6 || pickedTime.hour > 18) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Solo se permiten citas de 6:00 a 18:00'),
                      backgroundColor: Colors.red.shade700,
                    ));
                    return;
                  }
                  horaController.text =
                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: selectedMedicoId,
              decoration: const InputDecoration(labelText: 'Médico'),
              items: medicos.map((m) {
                final nombre = m['nombre_usuario'] ?? 'Desconocido';
                final especialidad = m['especialidad'] ?? 'Sin especialidad';
                return DropdownMenuItem<int>(
                  value: m['id_medico'],
                  child: Text('$nombre - $especialidad'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) selectedMedicoId = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            onPressed: () {
              final fecha = DateTime.tryParse(fechaController.text);
              final horaSplit = horaController.text.split(':');
              final hora = TimeOfDay(
                hour: int.tryParse(horaSplit[0]) ?? 0,
                minute: int.tryParse(horaSplit[1]) ?? 0,
              );

              if (fecha == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Fecha inválida'),
                  backgroundColor: Colors.red.shade700,
                ));
                return;
              }

              if (cita == null) {
                createCita(selectedMedicoId, fecha, hora);
              } else {
                updateCita(cita['id_cita'], fecha, hora);
              }

              Navigator.pop(context);
            },
            child: Text(cita == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final citas = snapshot.data?['citas'] ?? [];
          final medicos = snapshot.data?['medicos'] ?? [];

          return Stack(
            children: [
              citas.isEmpty
                  ? Center(child: Text('No hay citas agendadas', style: TextStyle(color: Colors.blue.shade700)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: citas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = citas[i];
                        final medico = medicos.firstWhere(
                          (m) => m['id_medico'] == c['id_medico'],
                          orElse: () => {'nombre_usuario': 'Desconocido', 'especialidad': 'Sin especialidad'},
                        );
                        final medicoNombre = medico['nombre_usuario'];
                        final especialidad = medico['especialidad'];

                        return Card(
                          color: Colors.blue.shade50,
                          child: ListTile(
                            title: Text('Médico: $medicoNombre - $especialidad', style: TextStyle(color: Colors.blue.shade800)),
                            subtitle: Text('Fecha: ${c['fecha']} - Hora: ${c['hora']}', style: TextStyle(color: Colors.blue.shade700)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                                  onPressed: () => showCitaDialog(cita: c, medicos: medicos),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                                  onPressed: () => deleteCita(c['id_cita']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue.shade700,
                  child: const Icon(Icons.add),
                  onPressed: () => showCitaDialog(cita: null, medicos: medicos),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
