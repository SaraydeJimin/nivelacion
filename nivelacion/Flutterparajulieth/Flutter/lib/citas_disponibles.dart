import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Para formatear la fecha

class CitasDisponiblesScreen extends StatefulWidget {
  final String token;
  final int idMedico;

  const CitasDisponiblesScreen({
    super.key,
    required this.token,
    required this.idMedico,
  });

  @override
  State<CitasDisponiblesScreen> createState() => _CitasDisponiblesScreenState();
}

class _CitasDisponiblesScreenState extends State<CitasDisponiblesScreen> {
  List<Map<String, dynamic>> citas = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCitas();
  }

  Future<void> fetchCitas() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final url = Uri.parse("http://localhost:3000/appointment/all");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> lista = data["response"] ?? [];

        if (!mounted) return;
        setState(() {
          citas = lista.map((c) => Map<String, dynamic>.from(c)).toList();
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar citas: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  Future<void> _refresh() async => fetchCitas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Citas del Médico"),
        backgroundColor: const Color(0xFF3E7DAB),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3E7DAB)))
          : RefreshIndicator(
              color: const Color(0xFF3E7DAB),
              onRefresh: _refresh,
              child: citas.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 50),
                        Center(child: Text("No hay citas disponibles")),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: citas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final cita = citas[index];
                        final fechaFormateada = cita["fecha"] != null
                            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(cita["fecha"]))
                            : '-';

                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3E7DAB),
                              child: const Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            title: Text(
                              "Paciente: ${cita["paciente"] ?? 'Desconocido'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            subtitle: Text(
                              "Fecha: $fechaFormateada\n"
                              "Hora: ${cita["hora"] ?? '-'}\n",
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF0D47A1)),
                            onTap: () {
                              if (cita["id_paciente"] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalleCitaPacienteScreen(
                                      token: widget.token,
                                      citaData: cita,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// Pantalla de detalle de cita + paciente
class DetalleCitaPacienteScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> citaData;

  const DetalleCitaPacienteScreen({
    super.key,
    required this.token,
    required this.citaData,
  });

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = citaData["fecha"] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(citaData["fecha"]))
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Cita y Paciente"),
        backgroundColor: const Color(0xFF3E7DAB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detalle cita
            Text(
              "Detalle de la Cita",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            _infoTile("Fecha", fechaFormateada),
            _infoTile("Hora", citaData["hora"] ?? '-'),
            const Divider(height: 32, color: Color(0xFF90CAF9), thickness: 1.2),

            // Detalle paciente
            Text(
              "Detalle del Paciente",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),
            _infoTile("Nombre", citaData["paciente"] ?? '-'),
            _infoTile("Médico a cargo", citaData["medico"] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1565C0),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0D47A1)),
            ),
          ),
        ],
      ),
    );
  }
}
