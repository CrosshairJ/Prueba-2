import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sala_chat.dart';

class ListaChats extends StatefulWidget {
  const ListaChats({super.key});
  @override
  State<ListaChats> createState() => _ListaChatsState();
}

class _ListaChatsState extends State<ListaChats> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  String queryNombre = "";

  Future<String> obtenerOCrearChat(String destinoUid) async {
    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('miembros', arrayContains: currentUid)
        .get();

    for (var doc in query.docs) {
      List miembros = doc['miembros'] ?? [];
      if (miembros.contains(destinoUid)) return doc.id;
    }

    final nuevoChat = await FirebaseFirestore.instance.collection('chats').add({
      'miembros': [currentUid, destinoUid],
      'ultimoMensaje': '',
      'fecha': FieldValue.serverTimestamp(),
    });
    return nuevoChat.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
              child: TextField(
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Buscar usuario...",
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                  filled: true,
                  fillColor: const Color(0xFFE2E8F0),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => queryNombre = val.trim().toLowerCase()),
              ),
            ),
            const Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 20, endIndent: 20),
            Expanded(
              child: queryNombre.isNotEmpty
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        var usuarios = snapshot.data!.docs.where((doc) {
                          String nombre = (doc['nombre'] ?? '').toString().toLowerCase();
                          return nombre.contains(queryNombre) && doc.id != currentUid;
                        }).toList();

                        if (usuarios.isEmpty) {
                          return const Center(child: Text("No se encontraron usuarios", style: TextStyle(color: Color(0xFF64748B))));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          itemCount: usuarios.length,
                          separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
                          itemBuilder: (context, index) {
                            var u = usuarios[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              title: Text(u['nombre'] ?? '', style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15)),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
                              onTap: () async {
                                String chatId = await obtenerOCrearChat(u.id);
                                if (context.mounted) {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => SalaChat(chatId: chatId, uidActual: currentUid, nombreDestino: u['nombre']),
                                  ));
                                }
                              },
                            );
                          },
                        );
                      },
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .where('miembros', arrayContains: currentUid)
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No tienes chats activos", style: TextStyle(color: Color(0xFF64748B))));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
                          itemBuilder: (context, index) {
                            var chatDoc = snapshot.data!.docs[index];
                            var datosChat = chatDoc.data() as Map<String, dynamic>?;
                            if (datosChat == null || !datosChat.containsKey('miembros')) return const SizedBox.shrink();

                            List miembros = datosChat['miembros'] ?? [];
                            String destinoUid = miembros.firstWhere((m) => m != currentUid, orElse: () => '');
                            if (destinoUid.isEmpty) return const SizedBox.shrink();

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('usuarios').doc(destinoUid).get(),
                              builder: (context, uSnapshot) {
                                if (!uSnapshot.hasData || !uSnapshot.data!.exists) return const SizedBox.shrink();
                                String nombreDestino = uSnapshot.data!['nombre'] ?? 'Usuario';

                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  title: Text(nombreDestino, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15)),
                                  subtitle: Text(datosChat['ultimoMensaje'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 20),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => SalaChat(chatId: chatDoc.id, uidActual: currentUid, nombreDestino: nombreDestino),
                                  )),
                                );
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
    );
  }
}