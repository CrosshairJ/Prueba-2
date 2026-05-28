import "package:app/screens/mis_ramos.dart";
import 'package:flutter/material.dart';
import "package:app/screens/tareas.dart";
import "package:app/screens/calendario.dart";
import "package:app/screens/lista_chats.dart";
import "package:app/screens/perfil.dart"; 

class HomeAlumno extends StatefulWidget {
  const HomeAlumno({super.key});

  @override
  State<HomeAlumno> createState() => _HomeAlumnoState();
}

class _HomeAlumnoState extends State<HomeAlumno> {
  int indiceBarra = 0;

  final List<Widget> viewAlumno = [
    const Tareas(),
    const Calendario(),
    const ListaChats(),
    const MisRamos(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indiceBarra,
        onTap: (index) {
          setState(() {
            indiceBarra = index;
          });
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFFF2E9D8),
        unselectedItemColor: const Color(0xFF64748B),
        showSelectedLabels: false,
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        selectedIconTheme: const IconThemeData(size: 38),
        unselectedIconTheme: const IconThemeData(size: 28),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Mi Semana",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: "Calendario",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: "Mis Cursos",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Perfil()),
                      );
                    },
                    icon: const Icon(Icons.person_pin, size: 32, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: indiceBarra,
                children: viewAlumno,
              ),
            ),
          ],
        ),
      ),
    );
  }
}