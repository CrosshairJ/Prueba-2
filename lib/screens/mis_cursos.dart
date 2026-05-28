import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class MisCursos extends StatefulWidget {
  const MisCursos({super.key});
  @override
  State<MisCursos> createState() => _MisCursosState();
}

class _MisCursosState extends State<MisCursos> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        title: const Text("Mis Cursos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("cursos").where("profesorId", isEqualTo: uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No estás inscrito en ningún curso", style: TextStyle(color: Color(0xFF64748B))));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var curso = snapshot.data!.docs[index];
                    var datos = curso.data() as Map<String, dynamic>?;
                    String nombre = datos?["nombre"] ?? "Sin nombre";
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      color: const Color(0xFF1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: const Text("Gestión de alumnos, tareas y horarios", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaAlumnosProfe(cursoId: curso.id, cursoNombre: nombre, profesorUid: uid))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          TextEditingController cursoCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Nuevo Curso", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: cursoCtrl, decoration: const InputDecoration(labelText: "Nombre del Curso", labelStyle: TextStyle(color: Color(0xFF64748B)))),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B)))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (cursoCtrl.text.isNotEmpty) {
                      String nombreCurso = cursoCtrl.text.trim();
                      var col = FirebaseFirestore.instance.collection("cursos");
                      var existe = await col.where("nombre", isEqualTo: nombreCurso).get();
                      if (existe.docs.isNotEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ya existe un curso con ese nombre"), backgroundColor: Color(0xFF1E293B)));
                        }
                        return;
                      }
                      await col.add({
                        "nombre": nombreCurso, 
                        "profesorId": uid,
                        "integrantes": [uid]
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Crear"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PantallaAlumnosProfe extends StatelessWidget {
  final String cursoId;
  final String cursoNombre;
  final String profesorUid;
  const PantallaAlumnosProfe({super.key, required this.cursoId, required this.cursoNombre, required this.profesorUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("cursos").doc(cursoId).snapshots(),
      builder: (context, cursoSnapshot) {
        if (!cursoSnapshot.hasData || !cursoSnapshot.data!.exists) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        var datosCurso = cursoSnapshot.data!.data() as Map<String, dynamic>?;
        List<String> integrantes = datosCurso?["integrantes"] != null ? List<String>.from(datosCurso!["integrantes"]) : [];

        return Scaffold(
          backgroundColor: const Color(0xFFF2E9D8),
          appBar: AppBar(
            title: Text(cursoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)), 
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: const Color(0xFF1E293B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("usuarios").where("rol", isEqualTo: "alumno").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    var alumnosCurso = snapshot.data!.docs.where((doc) => integrantes.contains(doc.id)).toList();
                    if (alumnosCurso.isEmpty) return const Center(child: Text("No hay alumnos en este curso.", style: TextStyle(color: Color(0xFF64748B))));

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 5),
                      itemCount: alumnosCurso.length,
                      itemBuilder: (context, index) {
                        var alumno = alumnosCurso[index];
                        String nombreAlu = (alumno.data() as Map<String, dynamic>?)?["nombre"] ?? "Sin nombre";
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          color: const Color(0xFF1E293B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(nombreAlu, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            trailing: const Icon(Icons.analytics_outlined, color: Colors.white70, size: 20),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaNotas(cursoId: cursoId, alumnoId: alumno.id, alumnoNombre: nombreAlu))),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              color: const Color(0xFFF2E9D8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _dialogTareaMasiva(context, integrantes),
                      child: const Text("Tarea", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _dialogDefinirHorarios(context, integrantes),
                      child: const Text("Horarios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64748B), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _dialogBuscadorAlumnos(context),
                      child: const Text("Alumno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _dialogTareaMasiva(BuildContext context, List<String> integrantes) {
    TextEditingController tCtrl = TextEditingController();
    TextEditingController hCtrl = TextEditingController();
    DateTime? fechaSel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Nueva Tarea General", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tCtrl, decoration: const InputDecoration(labelText: "Título de la Tarea", labelStyle: TextStyle(color: Color(0xFF64748B)))),
              TextField(controller: hCtrl, decoration: const InputDecoration(hintText: "Ej: 08:30", labelText: "Hora", labelStyle: TextStyle(color: Color(0xFF64748B)))),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context, 
                    initialDate: DateTime.now(), 
                    firstDate: DateTime.now().subtract(const Duration(days: 1)), 
                    lastDate: DateTime(DateTime.now().year + 1)
                  );
                  if (picked != null) setDialogState(() => fechaSel = picked);
                },
                child: Text(fechaSel == null ? "Seleccionar Fecha" : "${fechaSel!.day}/${fechaSel!.month}/${fechaSel!.year}"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
              onPressed: () async {
                if (tCtrl.text.isNotEmpty && hCtrl.text.isNotEmpty && fechaSel != null) {
                  final RegExp regexHoraEstricta = RegExp(r"^([0-1]?[0-9]|2[0-3]):[0-5]?[0-9]$");
                  if (regexHoraEstricta.hasMatch(hCtrl.text.trim())) {
                    var batch = FirebaseFirestore.instance.batch();
                    var coll = FirebaseFirestore.instance.collection("tareas");
                    
                    DateTime fechaFiltro = DateTime(fechaSel!.year, fechaSel!.month, fechaSel!.day);
                    
                    List<String> partesHora = hCtrl.text.trim().split(":");
                    int horaOrden = (int.parse(partesHora[0]) * 100) + int.parse(partesHora[1]);

                    for (var id in integrantes) {
                      batch.set(coll.doc(), {
                        "titulo": tCtrl.text.trim(), 
                        "hora": hCtrl.text.trim(), 
                        "horaOrden": horaOrden, 
                        "fecha": Timestamp.fromDate(fechaFiltro), 
                        "usuarioId": id.trim() 
                      });
                    }
                    
                    await batch.commit();
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Formato de hora inválido (HH:MM)"), backgroundColor: Color(0xFF1E293B)));
                  }
                }
              },
              child: const Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }

  void _dialogDefinirHorarios(BuildContext context, List<String> integrantes) {
    String diaSel = "Lunes";
    String bloqueSel = "08:00 - 09:20";
    Map<String, int> mapa = {"08:00 - 09:20": 800, "09:30 - 10:50": 930, "11:00 - 12:20": 1100, "12:30 - 13:50": 1230, "14:00 - 15:20": 1400, "15:30 - 16:50": 1530, "17:00 - 18:20": 1700};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Asignar Horario", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: diaSel,
                decoration: const InputDecoration(labelText: "Día", labelStyle: TextStyle(color: Color(0xFF64748B))),
                items: ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]
                    .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setDialogState(() => diaSel = val!),
              ),
              DropdownButtonFormField<String>(
                value: bloqueSel,
                decoration: const InputDecoration(labelText: "Bloque", labelStyle: TextStyle(color: Color(0xFF64748B))),
                items: mapa.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setDialogState(() => bloqueSel = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
              onPressed: () async {
                var col = FirebaseFirestore.instance.collection("ramos");
                var batch = FirebaseFirestore.instance.batch();

                for (var id in integrantes) {
                  String cleanId = id.trim();
                  var existe = await col
                      .where("usuarioId", isEqualTo: cleanId)
                      .where("cursoId", isEqualTo: cursoId)
                      .where("dia", isEqualTo: diaSel)
                      .where("bloqueHorario", isEqualTo: bloqueSel)
                      .get();

                  if (existe.docs.isEmpty) {
                    batch.set(col.doc(), {
                      "usuarioId": cleanId,
                      "cursoId": cursoId,
                      "nombre": cursoNombre,
                      "dia": diaSel,
                      "bloqueHorario": bloqueSel,
                      "bloqueOrden": mapa[bloqueSel] ?? 9999
                    });
                  }
                }

                await batch.commit();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Asignar"),
            )
          ],
        ),
      ),
    );
  }

  void _dialogBuscadorAlumnos(BuildContext context) {
    String query = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Buscar Alumno", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (val) => setDialogState(() => query = val.trim().toLowerCase()), 
                  decoration: const InputDecoration(hintText: "Escribe el nombre...", prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)))
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("usuarios").where("rol", isEqualTo: "alumno").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      var filtered = snapshot.data!.docs.where((doc) => (doc["nombre"] ?? "").toString().toLowerCase().contains(query)).toList();
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          var alumno = filtered[index];
                          String alumnoIdLimpio = alumno.id.trim();

                          return ListTile(
                            title: Text(alumno["nombre"] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                            trailing: const Icon(Icons.add_circle, color: Color(0xFF1E293B)),
                            onTap: () async {
                              // 1. Añadimos el alumno a la lista de integrantes del curso
                              await FirebaseFirestore.instance.collection("cursos").doc(cursoId).update({
                                "integrantes": FieldValue.arrayUnion([alumnoIdLimpio])
                              });

                              // 2. Creamos la relación base en 'ramos' para que aparezca al alumno inmediatamente
                              var ramosRef = FirebaseFirestore.instance.collection("ramos");
                              var yaVinculado = await ramosRef
                                  .where("usuarioId", isEqualTo: alumnoIdLimpio)
                                  .where("cursoId", isEqualTo: cursoId)
                                  .get();

                              if (yaVinculado.docs.isEmpty) {
                                await ramosRef.add({
                                  "usuarioId": alumnoIdLimpio,
                                  "cursoId": cursoId,
                                  "nombre": cursoNombre,
                                  "dia": "No asignado",
                                  "bloqueHorario": "--:--",
                                  "bloqueOrden": 9999
                                });
                              }

                              if (context.mounted) Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PantallaNotas extends StatefulWidget {
  final String cursoId;
  final String alumnoId;
  final String alumnoNombre;
  const PantallaNotas({super.key, required this.cursoId, required this.alumnoId, required this.alumnoNombre});
  @override
  State<PantallaNotas> createState() => _PantallaNotasState();
}

class _PantallaNotasState extends State<PantallaNotas> {
  List<Map<String, dynamic>> listaNotasLocal = [];
  bool cargado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        title: Text(widget.alumnoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("notes").where("cursoId", isEqualTo: widget.cursoId).where("usuarioId", isEqualTo: widget.alumnoId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          if (!cargado) {
            listaNotasLocal = snapshot.data!.docs.map((doc) {
              var datos = doc.data() as Map<String, dynamic>?;
              return {"id": doc.id, "titulo": datos?["titulo"] ?? "", "nota": double.tryParse(datos?["nota"].toString() ?? "1.0") ?? 1.0, "porcentaje": int.tryParse(datos?["porcentaje"].toString() ?? "0") ?? 0};
            }).toList();
            cargado = true;
          }

          double promedio = 0;
          double sumaPorcentajes = 0;
          for (var n in listaNotasLocal) {
            promedio += n["nota"] * (n["porcentaje"] / 100);
            sumaPorcentajes += n["porcentaje"];
          }

          return Column(
            children: [
              const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "Promedio Ponderado: ${promedio.toStringAsFixed(2)} (${sumaPorcentajes.toStringAsFixed(0)}%)", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: listaNotasLocal.length,
                  itemBuilder: (context, index) {
                    var n = listaNotasLocal[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      color: const Color(0xFF1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text("${n["titulo"]} (${n["porcentaje"]}%)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        trailing: SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            controller: TextEditingController(text: n["nota"].toString())..selection = TextSelection.fromPosition(TextPosition(offset: n["nota"].toString().length)),
                            onChanged: (val) async {
                              double nuevaNota = double.tryParse(val) ?? 1.0;
                              setState(() => listaNotasLocal[index]["nota"] = nuevaNota);
                              await FirebaseFirestore.instance.collection("notes").doc(n["id"]).update({"nota": nuevaNota});
                            },
                          ),
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.call_split, color: Colors.white, size: 20),
                          onPressed: () {
                            TextEditingController p1 = TextEditingController(text: "${(n["porcentaje"] / 2).toStringAsFixed(0)}");
                            TextEditingController p2 = TextEditingController(text: "${(n["porcentaje"] / 2).toStringAsFixed(0)}");
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text("Descomponer Nota"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [Text("Total: ${n["porcentaje"]}%"), TextField(controller: p1, keyboardType: TextInputType.number), TextField(controller: p2, keyboardType: TextInputType.number)],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B)))),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                                    onPressed: () async {
                                      int pct1 = int.tryParse(p1.text) ?? 0;
                                      int pct2 = int.tryParse(p2.text) ?? 0;
                                      if (pct1 + pct2 == n["porcentaje"]) {
                                        Navigator.pop(context);
                                        await FirebaseFirestore.instance.collection("notes").doc(n["id"]).update({"titulo": "${n["titulo"]} Part A", "porcentaje": pct1});
                                        await FirebaseFirestore.instance.collection("notes").add({"cursoId": widget.cursoId, "usuarioId": widget.alumnoId, "titulo": "${n["titulo"]} Part B", "nota": n["nota"], "porcentaje": pct2});
                                        setState(() => cargado = false);
                                      }
                                    },
                                    child: const Text("Dividir"),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          TextEditingController tCtrl = TextEditingController();
          TextEditingController pCtrl = TextEditingController();
          TextEditingController nCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Nueva Nota"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: tCtrl, decoration: const InputDecoration(labelText: "Título")), TextField(controller: pCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Porcentaje")), TextField(controller: nCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Nota"))]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Color(0xFF64748B)))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (tCtrl.text.isNotEmpty && pCtrl.text.isNotEmpty && nCtrl.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection("notes").add({"cursoId": widget.cursoId, "usuarioId": widget.alumnoId, "titulo": tCtrl.text.trim(), "porcentaje": int.tryParse(pCtrl.text) ?? 0, "nota": double.tryParse(nCtrl.text) ?? 1.0});
                      setState(() => cargado = false);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Guardar"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}