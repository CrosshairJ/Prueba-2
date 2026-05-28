import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:app/screens/home_profesor.dart";
import "package:app/screens/home_admin.dart";
import "package:app/screens/home_alumno.dart";

class Rol extends StatelessWidget {
  const Rol({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9D8),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("usuarios").doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {     
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFFF2E9D8),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E293B)),
                ),
              );
            }         
            
            if (snapshot.hasData && snapshot.data!.exists) {
              String rolUsuario = snapshot.data!.get("rol") ?? "";
              
              if (rolUsuario == "admin") {
                return const HomeAdmin();
              } else if (rolUsuario == "alumno") {
                return const HomeAlumno();
              } else if (rolUsuario == "profesor") {
                return const HomeProfesor();
              }
            }  
            
            return const Center(
              child: Text(
                "Cargando datos...",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );           
          }
        ),     
      ),
    );
  }
}