import 'package:flutter/material.dart';
import 'citas_disponibles.dart';
import 'crear_formula_screen.dart'; // archivo separado para crear fórmulas
import 'laboratorio_screen.dart'; // pantalla de laboratorio placeholder

class MedicoPanel extends StatefulWidget {
  final String token;
  final int idMedico;

  const MedicoPanel({super.key, required this.token, required this.idMedico});

  @override
  _MedicoPanelState createState() => _MedicoPanelState();
}

class _MedicoPanelState extends State<MedicoPanel> {
  String? _expandedSection;

  Map<String, List<Map<String, dynamic>>> get _sections {
    return {
      'Citas': [
        {
          'title': 'Citas disponibles',
          'icon': Icons.calendar_today,
          'screen': CitasDisponiblesScreen(
            token: widget.token,
            idMedico: widget.idMedico,
          ),
        },
      ],
      'Formulas': [
        {
          'title': 'Crear fórmula',
          'icon': Icons.medical_services,
          'screen': CrearFormulaScreen(
            token: widget.token,
            idMedico: widget.idMedico,
            baseUrl: 'https://localhost:3000', // <- URL de tu API
          ),
        },
      ],
      'Laboratorios': [
        {
          'title': 'Laboratorios',
          'icon': Icons.biotech,
          'screen': LaboratorioScreen(
            token: widget.token,
            isMedico: true,
            idMedico: widget.idMedico,
          ),
        },
      ],
    };
  }

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  @override
void initState() {
  super.initState();
  print('TOKEN: ${widget.token}, ID_MEDICO: ${widget.idMedico}');
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          'Panel del Médico',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF3E7DAB),
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F4FA), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children:
              _sections.keys.map((section) => _buildSectionCard(section)).toList(),
        ),
      ),
    );
  }

  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String section) {
    final bool isExpanded = _expandedSection == section;
    final items = _sections[section] ?? [];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _getSectionIcon(section),
            title: Text(
              section,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E7DAB),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: const Color(0xFF76BDE9),
            ),
            onTap: () => _toggleSection(section),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                children: items.map((item) => _buildSubItem(item)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: ListTile(
        leading: Icon(item['icon'], color: const Color(0xFF76BDE9)),
        title: Text(item['title'], style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF76BDE9)),
        onTap: () {
          if (item['screen'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['screen']),
            );
          }
        },
      ),
    );
  }

  Icon _getSectionIcon(String section) {
    switch (section) {
      case 'Citas':
        return const Icon(Icons.calendar_month, color: Color(0xFF76BDE9));
      case 'Formulas':
        return const Icon(Icons.note_add, color: Color(0xFF76BDE9));
      case 'Laboratorios':
        return const Icon(Icons.biotech, color: Color(0xFF76BDE9));
      default:
        return const Icon(Icons.category, color: Color(0xFF76BDE9));
    }
  }
}