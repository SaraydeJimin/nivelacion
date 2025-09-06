import 'package:flutter/material.dart';
import 'formulas_service.dart';

class CrearFormulaScreen extends StatefulWidget {
  final String token;
  final int idMedico;
  final String baseUrl;

  const CrearFormulaScreen({
    super.key,
    required this.token,
    required this.idMedico,
    required this.baseUrl,
  });

  @override
  State<CrearFormulaScreen> createState() => _CrearFormulaScreenState();
}

class _CrearFormulaScreenState extends State<CrearFormulaScreen> {
  late FormulaService formulaService;
  List<Map<String, dynamic>> citas = [];
  List<Map<String, dynamic>> medicamentos = [];
  Map<String, dynamic>? selectedCita;
  Map<String, dynamic>? selectedMedicamento;
  List<Map<String, dynamic>> detalles = [];

  final TextEditingController observacionesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    formulaService = FormulaService(
      token: widget.token,
      idMedico: widget.idMedico,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedCitas = await formulaService.fetchCitas();
    final fetchedMedicamentos = await formulaService.fetchMedicamentos();

    setState(() {
      citas = fetchedCitas.where((c) => c['id_paciente'] != null && c['id_paciente'] > 0).toList();
      medicamentos = fetchedMedicamentos;
    });
  }

  void _addDetalle(Map<String, dynamic> medicamento) {
    setState(() {
      detalles.add({
        "id_medicamento": medicamento['id_medicamento'],
        "nombre": medicamento['nombre'],
        "cantidad": 1,
        "dosis": medicamento['concentracion'],
        "duracion": "",
      });
    });
  }

  Future<void> _guardarFormula() async {
    if (selectedCita == null || selectedCita!['id_paciente'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona una cita válida')));
      return;
    }

    final success = await formulaService.crearFormula(
      idCita: selectedCita!['id_cita'],
      idPaciente: selectedCita!['id_paciente'],
      observaciones: observacionesController.text,
      detalles: detalles,
      idMedico: widget.idMedico,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Fórmula creada correctamente'
            : 'Error al crear fórmula'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final azulEPS = Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Fórmula',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: azulEPS,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Selecciona una cita:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedCita,
              isExpanded: true,
              hint: const Text("Elige una cita"),
              items: citas.map((cita) {
                return DropdownMenuItem(
                  value: cita,
                  child: Text(
                    "Paciente: ${cita['paciente']} - ${cita['fecha'].substring(0, 10)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => selectedCita = value),
            ),
            const SizedBox(height: 20),
            const Text("Selecciona un medicamento:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedMedicamento,
              isExpanded: true,
              hint: const Text("Elige un medicamento"),
              items: medicamentos.map((med) {
                return DropdownMenuItem(
                  value: med,
                  child: Text("${med['nombre']} - ${med['concentracion']}", style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => selectedMedicamento = value),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Agregar al detalle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: azulEPS,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: selectedMedicamento == null
                  ? null
                  : () {
                      _addDetalle(selectedMedicamento!);
                      setState(() => selectedMedicamento = null);
                    },
            ),
            const SizedBox(height: 20),
            const Text("Detalles de la fórmula:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...detalles.map((det) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(det['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Cantidad",
                          hintText: det['cantidad'].toString(),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => det['cantidad'] = val,
                        controller: TextEditingController(text: det['cantidad'].toString()),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Dosis",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        readOnly: true,
                        controller: TextEditingController(text: det['dosis']),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Duración",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: (val) => det['duracion'] = val,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => detalles.remove(det)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            TextField(
              controller: observacionesController,
              decoration: InputDecoration(
                labelText: "Observaciones",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarFormula,
              style: ElevatedButton.styleFrom(
                backgroundColor: azulEPS,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Guardar Fórmula"),
            ),
          ],
        ),
      ),
    );
  }
}