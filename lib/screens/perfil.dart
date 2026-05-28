import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:app/main.dart"; 

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => PerfilState();
}

class PerfilState extends State<Perfil> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _nombreCtrl = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').doc(currentUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E293B)));
          }

          var datos = snapshot.data!.data() as Map<String, dynamic>;
          
          if (_nombreCtrl.text.isEmpty) {
            _nombreCtrl.text = datos['nombre'] ?? '';
          }

          String rolUsuario = datos['rol'] ?? 'alumno';
          DateTime? fechaBase = (datos['fechaCreacion'] as Timestamp?)?.toDate() ?? 
                                FirebaseAuth.instance.currentUser?.metadata.creationTime;
          String fechaFormateada = fechaBase != null 
              ? "${fechaBase.day}/${fechaBase.month}/${fechaBase.year}" 
              : "No disponible";

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 30, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E293B), width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 65,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person_rounded, size: 75, color: Color(0xFF1E293B)),
                  ),
                ),
                const SizedBox(height: 15),
                
                Text(
                  rolUsuario.toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.5),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _nombreCtrl,
                  style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Nombre Completo",
                    labelStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E293B)),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 2)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),

                Card(
                  elevation: 0,
                  color: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email_outlined, color: Color(0xFF1E293B)),
                          title: const Text("Correo Electrónico", style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          subtitle: Text(datos['correo'] ?? 'Sin correo', style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Divider(color: Color(0xFFCBD5E1), height: 1),
                        ),
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF1E293B)),
                          title: const Text("Miembro Desde", style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          subtitle: Text(fechaFormateada, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _cargando 
                      ? null 
                      : () async {
                          if (_nombreCtrl.text.trim().isEmpty) return;
                          setState(() => _cargando = true);

                          await FirebaseAuth.instance.currentUser?.updateDisplayName(_nombreCtrl.text.trim());
                          await FirebaseFirestore.instance.collection('usuarios').doc(currentUid).update({
                            'nombre': _nombreCtrl.text.trim(),
                          });

                          setState(() => _cargando = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Perfil actualizado con éxito"), backgroundColor: Color(0xFF1E293B))
                            );
                          }
                        },
                    child: _cargando 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Guardar Cambios", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Inicio()),
                        );
                      }
                    },
                    child: const Text("Cerrar Sesión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}