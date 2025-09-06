import 'package:el_escondite_animal/ui/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'creacion_citas.dart';
import 'formulas_ver.dart';
import 'laboratorio_page.dart';

/// =============================================================
/// EPS – SENA: Home Shell (Dashboard + Tabs) – Temática azulita 💙
/// =============================================================
class EpsHomeShell extends StatefulWidget {
  const EpsHomeShell({super.key});

  @override
  State<EpsHomeShell> createState() => _EpsHomeShellState();
}

class _EpsHomeShellState extends State<EpsHomeShell> {
  int _index = 0;
  String _token = '';
  int _userId = 0;
  late Future<String?> _userNameFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
      _userId = prefs.getInt('userId') ?? 0;
      _userNameFuture = _loadNameFromPrefs();
      _isLoading = false;
    });
  }

  Future<String?> _loadNameFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre') ?? prefs.getString('name');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Aquí podrías navegar a la pantalla de login
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const OnboardingScreen()), // <- tu pantalla de login aquí
    (route) => false,
  );
}

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Cerrar sesión'),
            
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE3F2FD),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1565C0))),
      );
    }

    final pages = [
      DashboardPage(userNameFuture: _userNameFuture, token: _token, userId: _userId),
      Container(), // Perfil ya no será usado
      PrescriptionsPage(token: _token, idPaciente: _userId),
      LaboratoriosPage(token: _token, userId: _userId),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: FutureBuilder<String?>(
          future: _userNameFuture,
          builder: (context, snap) {
            final name = snap.data?.trim();
            return Text(
              name == null || name.isEmpty
                  ? 'EPS – SENA'
                  : 'Hola, ${name.split(' ').first} 👋',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            );
          },
        ),
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 1) {
            _confirmLogout(); // Solo abrir diálogo de cerrar sesión
          } else {
            setState(() => _index = i);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF1565C0)),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout),
            selectedIcon: Icon(Icons.logout, color: Color(0xFF1565C0)),
            label: 'Salir',
          ),
        ],
      ),
    );
  }
}

// ===================== Dashboard =====================
class DashboardPage extends StatelessWidget {
  final Future<String?> userNameFuture;
  final String token;
  final int userId;

  const DashboardPage({super.key, required this.userNameFuture, required this.token, required this.userId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1565C0),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<String?>(
            future: userNameFuture,
            builder: (context, snap) {
              final name = snap.data?.trim();
              return Text(
                name == null || name.isEmpty ? 'Bienvenido/a' : 'Bienvenido/a, ${name.split(' ').first}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Acciones rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1976D2))),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _QuickAction(
                icon: Icons.add_circle_outline,
                label: 'Agendar cita',
                color: const Color(0xFF64B5F6),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppointmentsPage(idPaciente: userId, token: token),
                    ),
                  );
                },
              ),
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Ver fórmulas',
                color: const Color(0xFF42A5F5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PrescriptionsPage(token: token, idPaciente: userId),
                    ),
                  );
                },
              ),
              _QuickAction(
                icon: Icons.biotech_outlined,
                label: 'Laboratorios',
                color: const Color(0xFF1E88E5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LaboratoriosPage(token: token, userId: userId),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===================== Quick Action Card =====================
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickAction({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}