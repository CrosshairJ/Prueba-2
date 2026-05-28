import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/screens/login.dart';

class Clave extends StatefulWidget {
  const Clave({super.key});

  @override
  State<Clave> createState() => _ClaveState();
}

class _ClaveState extends State<Clave> {
  final TextEditingController correo = TextEditingController();

  @override
  void dispose() {
    correo.dispose();
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Recuperar contraseña",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: correo,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      labelStyle: const TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () async {
                        String email = correo.text.trim();
                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Por favor, ingresa tu correo"), backgroundColor: Color(0xFF1E293B)),
                          );
                          return;
                        }
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Correo de recuperación enviado"), backgroundColor: Colors.green),
                            );
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
                          }
                        } on FirebaseAuthException catch (e) {
                          String mensaje = "Error al enviar el correo";
                          if (e.code == 'user-not-found') mensaje = "Correo no registrado";
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(mensaje), backgroundColor: const Color(0xFF1E293B)),
                            );
                          }
                        }
                      },
                      child: const Text("Enviar correo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}