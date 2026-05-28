import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class Tareas extends StatefulWidget {
  const Tareas({super.key});
  @override
  State<Tareas> createState() => _TareasState();
}

class _TareasState extends State<Tareas> {
  final List<String> diasNombres = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late PageController selecPagina;
  int indiceDia = 0;
  bool verTareas = true; 
  
  late DateTime lunesEstaSemana;

  @override
  void initState() {
    super.initState();
    indiceDia = DateTime.now().weekday - 1;
    selecPagina = PageController(initialPage: indiceDia);
    
    DateTime ahora = DateTime.now();
    lunesEstaSemana = DateTime(ahora.year, ahora.month, ahora.day - (ahora.weekday - 1));
  }

  @override
  void dispose() {
    selecPagina.dispose();
    super.dispose();
  }
  void _editarTarea(DocumentSnapshot? doc) {
    var datos = doc != null ? doc.data() as Map : {};
    TextEditingController tCtrl = TextEditingController(text: doc != null ? datos["titulo"] : "");
    TextEditingController hCtrl = TextEditingController(text: doc != null ? datos["hora"] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? "Nueva Tarea" : "Modificar Tarea"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tCtrl, decoration: const InputDecoration(labelText: "Título")),
            TextField(controller: hCtrl, decoration: const InputDecoration(labelText: "Hora (Ej: 08:30)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
            onPressed: () async {
              final RegExp regex = RegExp(r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$");
              
              if (tCtrl.text.isNotEmpty && regex.hasMatch(hCtrl.text.trim())) {
                List<String> partes = hCtrl.text.split(":");
                int o = (int.parse(partes[0]) * 100) + int.parse(partes[1]);
                
                if (doc == null) {
                  await FirebaseFirestore.instance.collection("tareas").add({
                    "titulo": tCtrl.text.trim(),
                    "hora": hCtrl.text.trim(),
                    "horaOrden": o,
                    "fecha": Timestamp.fromDate(DateTime(lunesEstaSemana.year, lunesEstaSemana.month, lunesEstaSemana.day + indiceDia)),
                    "usuarioId": uid
                  });
                } else {
                  await FirebaseFirestore.instance.collection("tareas").doc(doc.id).update({
                    "titulo": tCtrl.text.trim(),
                    "hora": hCtrl.text.trim(),
                    "horaOrden": o,
                  });
                }
                if (context.mounted) Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: Hora inválida. Usa formato HH:mm (ej: 08:30)"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
  void _opcionesTarea(DocumentSnapshot doc) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("¿Qué deseas hacer?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); 
            _editarTarea(doc); 
          },
          child: const Text("Editar"),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection("tareas").doc(doc.id).delete();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    DateTime fechaDelDia = lunesEstaSemana.add(Duration(days: indiceDia));
    DateTime fechaFiltro = DateTime(fechaDelDia.year, fechaDelDia.month, fechaDelDia.day);
    String fechaNumerica = "${fechaDelDia.day}/${fechaDelDia.month.toString()}";

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Text(
            diasNombres[indiceDia],
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 2),
          Text(
            fechaNumerica,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ), 
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Expanded(
            child: PageView.builder(
              controller: selecPagina,
              itemCount: 7,
              onPageChanged: (index) {
                setState(() {
                  indiceDia = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                DateTime fechaPagina = lunesEstaSemana.add(Duration(days: pageIndex));
                DateTime filtroPagina = DateTime(fechaPagina.year, fechaPagina.month, fechaPagina.day);
                
                if (verTareas) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("tareas")
                        .where("usuarioId", isEqualTo: uid)
                        .where("fecha", isEqualTo: Timestamp.fromDate(filtroPagina))
                        .orderBy("horaOrden")
                        .snapshots(), 
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No hay tareas para hoy", style: TextStyle(color: Color(0xFF64748B))));
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index]; 
                          var datos = doc.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            color: const Color(0xFF1E293B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Text(datos["hora"] ?? "--:--", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                              title: Text(datos["titulo"] ?? "Sin título", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              trailing: const Icon(Icons.more_vert, color: Colors.white70),
                              onTap: () => _opcionesTarea(doc), 
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("ramos")
                        .where("usuarioId", isEqualTo: uid)
                        .where("dia", isEqualTo: diasNombres[pageIndex])
                        .orderBy("bloqueOrden")
                        .snapshots(),
                    builder: (context, horariosSnapshot) {
                      if (!horariosSnapshot.hasData || horariosSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No hay clases para hoy", style: TextStyle(color: Color(0xFF64748B))));
                      }

                      return ListView.builder(
                        itemCount: horariosSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var datos = horariosSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            color: const Color(0xFF1E293B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Text(datos["bloqueHorario"] ?? "--:--",
                                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                              title: Text(datos["nombre"] ?? "Sin nombre",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Container(
            margin: const EdgeInsets.only(bottom: 15, left: 60, right: 60, top: 5),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => verTareas = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: verTareas ? const Color(0xFF1E293B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("Tareas", textAlign: TextAlign.center, style: TextStyle(color: verTareas ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => verTareas = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !verTareas ? const Color(0xFF1E293B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("Clases", textAlign: TextAlign.center, style: TextStyle(color: !verTareas ? Colors.white : const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: verTareas ? Padding(
        padding: const EdgeInsets.only(bottom: 65), 
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
                          final RegExp regexHoraEstricta = RegExp(r"^([0-1]?[0-9]|2[0-3]):[0-5]?[0-9]$");
                          if (regexHoraEstricta.hasMatch(hora.text.trim())) {
                            List<String> partesHora = hora.text.trim().split(":");
                            int horaOrden = (int.parse(partesHora[0]) * 100) + int.parse(partesHora[1]);

                            await FirebaseFirestore.instance.collection("tareas").add({
                              "titulo": titulo.text.trim(),
                              "hora": hora.text.trim(),
                              "horaOrden": horaOrden,
                              "fecha": Timestamp.fromDate(fechaFiltro),
                              "usuarioId": uid,
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
      ) : null,
    );
  }
}