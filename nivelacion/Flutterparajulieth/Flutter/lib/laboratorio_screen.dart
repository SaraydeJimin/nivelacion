import 'package:flutter/material.dart';
import 'laboratorio_service.dart';

class LaboratorioScreen extends StatefulWidget {
  final String token;
  final bool isMedico;
  final int? idMedico;

  const LaboratorioScreen({
    Key? key,
    required this.token,
    this.isMedico = false,
    this.idMedico,
  }) : super(key: key);

  @override
  _LaboratorioScreenState createState() => _LaboratorioScreenState();
}

class _LaboratorioScreenState extends State<LaboratorioScreen> {
  late LaboratorioService service;
  List<Map<String, dynamic>> laboratorios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    service = LaboratorioService(token: widget.token);
    fetchLaboratorios();
  }

  Future<void> fetchLaboratorios() async {
    setState(() => loading = true);
    try {
      laboratorios = await service.getAllLaboratorios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar laboratorios: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void showEditarResultadoDialog(Map<String, dynamic> lab) {
    final resultadosController = TextEditingController(text: lab['resultados'] ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Actualizar Resultados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resultadosController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Resultados',
                  labelStyle: TextStyle(color: Colors.blue.shade700),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                    ),
                    onPressed: () {
                      resultadosController.dispose();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final success = await service.updateResultados(
                        lab['id_laboratorio'],   // idLaboratorio
                        lab['tipo_prueba'],      // tipoPrueba
                        lab['id_cita'],          // idCita
                        lab['id_paciente'],      // idPaciente
                        lab['id_medico'],        // idMedico
                        lab['fecha'],            // fecha
                        resultadosController.text, // resultados
                      );
                      resultadosController.dispose();
                      Navigator.pop(context);

                      if (success) {
                        await fetchLaboratorios();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Resultados actualizados correctamente'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al actualizar resultados'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Panel Médico', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                itemCount: laboratorios.length,
                itemBuilder: (context, index) {
                  final lab = laboratorios[index];
                  final resultados = lab['resultados'] ?? 'Pendiente';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shadowColor: Colors.blue.shade100,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade200,
                        child: const Icon(Icons.biotech, color: Colors.white),
                      ),
                      title: Text(
                        'Paciente: ${lab['nombre_paciente']}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Prueba: ${lab['tipo_prueba']}',
                            style: TextStyle(color: Colors.blueGrey.shade700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Resultados: $resultados',
                            style: TextStyle(
                              color: resultados == 'Pendiente' ? Colors.orange : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Fecha: ${lab['fecha']}',
                            style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: widget.isMedico
                          ? IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => showEditarResultadoDialog(lab),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}