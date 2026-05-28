import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleDia extends StatefulWidget {
  final DateTime fechaSeleccionada;
  const DetalleDia({super.key, required this.fechaSeleccionada});

  @override
  State<DetalleDia> createState() => _DetalleDiaState();
}

class _DetalleDiaState extends State<DetalleDia> {
  final List<String> diasNombres = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    DateTime fechaFiltro = DateTime(widget.fechaSeleccionada.year, widget.fechaSeleccionada.month, widget.fechaSeleccionada.day);
    String fechaNumerica = "${widget.fechaSeleccionada.day}/${widget.fechaSeleccionada.month}";

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Text(
            diasNombres[widget.fechaSeleccionada.weekday - 1],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 2),
          Text(
            fechaNumerica,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ), 
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tareas')
                  .where('usuarioId', isEqualTo: uid)
                  .where('fecha', isEqualTo: Timestamp.fromDate(fechaFiltro)) 
                  .orderBy('horaOrden', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay tareas para hoy", style: TextStyle(color: Color(0xFF64748B))));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    Map<String, dynamic> tarea = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      color: const Color(0xFF1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Text(
                          tarea['hora'] ?? '--:--',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        title: Text(
                          tarea['titulo'] ?? 'Sin título', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          width: 54,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 4,
            ),
            onPressed: () {
              TextEditingController titulo = TextEditingController();
              TextEditingController hora = TextEditingController();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Nueva Tarea", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1E293B))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: titulo, decoration: const InputDecoration(labelText: "Título", labelStyle: TextStyle(color: Color(0xFF64748B)))),
                      TextField(controller: hora, decoration: const InputDecoration(hintText: "Ej: 08:30", labelText: "Hora", labelStyle: TextStyle(color: Color(0xFF64748B)))),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        if (titulo.text.isNotEmpty && hora.text.isNotEmpty) {
                          final RegExp regexHoraEstricta = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5]?[0-9]$');
                          if (regexHoraEstricta.hasMatch(hora.text.trim())) {
                            
                            List<String> partesHora = hora.text.trim().split(":");
                            int horaOrdenCalculado = (int.parse(partesHora[0]) * 100) + int.parse(partesHora[1]);

                            await FirebaseFirestore.instance.collection('tareas').add({
                              'titulo': titulo.text.trim(),
                              'hora': hora.text.trim(),
                              'horaOrden': horaOrdenCalculado,
                              'fecha': Timestamp.fromDate(fechaFiltro),
                              'usuarioId': uid,
                            });                                 
                            if (context.mounted) Navigator.pop(context);
                          } 
                        }
                      },
                      child: const Text("Guardar"),
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}