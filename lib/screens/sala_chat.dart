import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalaChat extends StatelessWidget {
  final String chatId;
  final String uidActual;
  final String nombreDestino;

  const SalaChat({super.key, required this.chatId, required this.uidActual, required this.nombreDestino});

  @override
  Widget build(BuildContext context) {
    TextEditingController mensajeCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(nombreDestino, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 20)),
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
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('mensajes')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                var docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var m = docs[index].data() as Map<String, dynamic>;
                    bool soyYo = m['emisorId'] == uidActual;

                    return Align(
                      alignment: soyYo ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: soyYo ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(soyYo ? 16 : 4),
                            bottomRight: Radius.circular(soyYo ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          m['texto'] ?? '', 
                          style: TextStyle(
                            color: soyYo ? Colors.white : const Color(0xFF1E293B), 
                            fontSize: 15,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 1),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 15, 
                right: 15, 
                top: 10, 
                bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 15
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mensajeCtrl,
                      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Escribe un mensaje...",
                        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
                        filled: true,
                        fillColor: const Color(0xFFE2E8F0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () async {
                        String texto = mensajeCtrl.text.trim();
                        if (texto.isEmpty) return;
                        mensajeCtrl.clear();

                        await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('mensajes').add({
                          'emisorId': uidActual,
                          'texto': texto,
                          'fecha': FieldValue.serverTimestamp(),
                        });

                        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
                          'ultimoMensaje': texto,
                          'fecha': FieldValue.serverTimestamp(),
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}