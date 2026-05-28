import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:app/screens/perfil.dart";

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});
  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int indiceBarra = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallasAdmin = [
      const PanelControlAdmin(),
      const Center(child: Text("Gestión de Cursos / Clases", style: TextStyle(fontSize: 20, color: Color(0xFF8C5C32), fontWeight: FontWeight.bold))),
      const Center(child: Text("Logs / Soporte Técnico", style: TextStyle(fontSize: 20, color: Color(0xFF8C5C32), fontWeight: FontWeight.bold))),
      const Perfil(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceBarra,
        onTap: (index) => setState(() => indiceBarra = index),
        backgroundColor: const Color(0xFF8C5C32),
        selectedItemColor: const Color(0xFFA60321),
        unselectedItemColor: const Color(0xFFD9A577),
        showSelectedLabels: false,
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(fontSize: 15),
        selectedIconTheme: const IconThemeData(size: 50),
        unselectedIconTheme: const IconThemeData(size: 30),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Panel"),
          BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_), label: "Cursos"),
          BottomNavigationBarItem(icon: Icon(Icons.terminal_outlined), activeIcon: Icon(Icons.terminal), label: "Logs"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("U-Track Admin", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.admin_panel_settings, size: 30, color: Color(0xFFA60321))),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: indiceBarra,
                children: pantallasAdmin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PanelControlAdmin extends StatelessWidget {
  const PanelControlAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshotUsuarios) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('cursos').snapshots(),
          builder: (context, snapshotCursos) {
            int totalUsuarios = snapshotUsuarios.hasData ? snapshotUsuarios.data!.docs.length : 0;
            int totalCursos = snapshotCursos.hasData ? snapshotCursos.data!.docs.length : 0;
            
            int alumnos = 0;
            int profesores = 0;
            if (snapshotUsuarios.hasData) {
              for (var doc in snapshotUsuarios.data!.docs) {
                var r = (doc.data() as Map<String, dynamic>?)?['rol'];
                if (r == 'alumno') alumnos++;
                if (r == 'profesor') profesores++;
              }
            }

            return ListView(
              padding: const EdgeInsets.all(15),
              children: [
                const Text("Estados del Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildEstadoCard("Firebase Auth", "Online", Colors.green),
                    const SizedBox(width: 10),
                    _buildEstadoCard("Firestore DB", "Online", Colors.green),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Cantidad de Registros", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricaCard("Total Usuarios", "$totalUsuarios", Icons.people, const Color(0xFF8C5C32)),
                    _buildMetricaCard("Total Cursos", "$totalCursos", Icons.school, const Color(0xFF8C5C32)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Estadísticas de Roles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
                const SizedBox(height: 10),
                _buildGraficoBarrasSimulado(alumnos, profesores),
                const SizedBox(height: 20),
                const Text("Actividad Reciente (Chats)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chats').orderBy('fecha', descending: true).limit(3).snapshots(),
                  builder: (context, snapChats) {
                    if (!snapChats.hasData || snapChats.data!.docs.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(10), child: Text("Sin actividad reciente")));
                    }
                    return Column(
                      children: snapChats.data!.docs.map((doc) {
                        var data = doc.data() as Map<String, dynamic>?;
                        return Card(
                          color: const Color(0xFF8C5C32),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.chat, color: Colors.white70),
                            title: Text(data?['ultimoMensaje'] ?? 'Nuevo chat creado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                            subtitle: const Text("Intercambio de mensajes activo", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEstadoCard(String servicio, String estado, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(radius: 6, backgroundColor: color),
            const SizedBox(width: 10),
            Text("$servicio: ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
            Text(estado, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaCard(String titulo, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titulo, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
              Icon(icon, color: Colors.white70),
            ],
          ),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGraficoBarrasSimulado(int alumnos, int profesores) {
    int maxVal = (alumnos > profesores ? alumnos : profesores);
    if (maxVal == 0) maxVal = 1;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _buildBarraGrafico("Alumnos ($alumnos)", alumnos, maxVal, const Color(0xFFA60321)),
          const SizedBox(height: 10),
          _buildBarraGrafico("Profesores ($profesores)", profesores, maxVal, const Color(0xFF8C5C32)),
        ],
      ),
    );
  }

  Widget _buildBarraGrafico(String etiqueta, int valor, int maxVal, Color color) {
    double porcentaje = valor / maxVal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C5C32))),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            height: 15,
            width: constraints.maxWidth * (porcentaje < 0.05 ? 0.05 : porcentaje),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }
}