import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class MisRamos extends StatefulWidget {
  const MisRamos({super.key});
  @override
  State<MisRamos> createState() => _MisRamosState();
}

class _MisRamosState extends State<MisRamos> {
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
              stream: FirebaseFirestore.instance.collection("ramos").where("usuarioId", isEqualTo: uid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No estás inscrito en ningún curso", style: TextStyle(color: Color(0xFF64748B))));
                }

                var docs = snapshot.data!.docs;
                Map<String, Map<String, dynamic>> cursosUnicos = {};

                for (var doc in docs) {
                  var datos = doc.data() as Map<String, dynamic>;
                  String cursoId = datos["cursoId"] ?? "";
                  String dia = datos["dia"] ?? "No asignado";

                  if (!cursosUnicos.containsKey(cursoId) || dia != "No asignado") {
                    cursosUnicos[cursoId] = datos;
                  }
                }

                var listaCursos = cursosUnicos.values.toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: listaCursos.length,
                  itemBuilder: (context, index) {
                    var datosRamo = listaCursos[index];
                    String nombreCurso = datosRamo["nombre"] ?? "Sin nombre";
                    String dia = datosRamo["dia"] ?? "No asignado";
                    String bloque = datosRamo["bloqueHorario"] ?? "--:--";
                    String cursoId = datosRamo["cursoId"] ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      color: const Color(0xFF1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(nombreCurso, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          dia == "No asignado" ? "Horario por definir" : "$dia ($bloque)", 
                          style: const TextStyle(color: Colors.white70, fontSize: 13)
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PantallaNotasAlumno(cursoId: cursoId, cursoNombre: nombreCurso, alumnoId: uid),
                        )),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PantallaNotasAlumno extends StatefulWidget {
  final String cursoId;
  final String cursoNombre;
  final String alumnoId;
  const PantallaNotasAlumno({super.key, required this.cursoId, required this.cursoNombre, required this.alumnoId});
  @override
  State<PantallaNotasAlumno> createState() => _PantallaNotasAlumnoState();
}

class _PantallaNotasAlumnoState extends State<PantallaNotasAlumno> {
  final Map<String, double> _notasSimuladas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        title: Text(widget.cursoNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
        stream: FirebaseFirestore.instance.collection("notes")
            .where("cursoId", isEqualTo: widget.cursoId)
            .where("usuarioId", isEqualTo: widget.alumnoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF1E293B)));
          
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Column(
              children: [
                const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
                const Expanded(
                  child: Center(
                    child: Text("El profesor aún no ha registrado notas", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            );
          }

          double promedio = 0;
          double sumaPorcentajes = 0;

          List<Map<String, dynamic>> notasProcesadas = docs.map((doc) {
            var datosNota = doc.data() as Map<String, dynamic>;
            String idNota = doc.id;
            int porcentaje = int.tryParse(datosNota["porcentaje"].toString()) ?? 0;
            double notaReal = double.tryParse(datosNota["nota"].toString()) ?? 1.0;

            double notaAMostrar = _notasSimuladas[idNota] ?? notaReal;

            promedio += notaAMostrar * (porcentaje / 100);
            sumaPorcentajes += porcentaje;

            return {
              "id": idNota,
              "titulo": datosNota["titulo"] ?? "Sin título",
              "nota": notaAMostrar,
              "porcentaje": porcentaje,
            };
          }).toList();

          return Column(
            children: [
              const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Promedio Simulado: ${promedio.toStringAsFixed(2)} (${sumaPorcentajes.toStringAsFixed(0)}%)", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Edita las notas para simular tu promedio (No se guardará en la BD)", 
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: notasProcesadas.length,
                  itemBuilder: (context, index) {
                    var n = notasProcesadas[index];
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
                            onChanged: (val) {
                              double? nuevaNota = double.tryParse(val);
                              if (nuevaNota != null) {
                                setState(() {
                                  _notasSimuladas[n["id"]] = nuevaNota;
                                });
                              }
                            },
                          ),
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
    );
  }
}