import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import "package:app/screens/login.dart";
import "package:app/screens/rol.dart";
import "package:app/screens/registro.dart";
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'U-Track',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Rol();
          }
          return const Inicio();
        },
      ),
    );
  }
}

class Inicio extends StatelessWidget {
  const Inicio({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(   
      backgroundColor: const Color(0xFFF2E9D8),  
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.width * 0.15),
                Image.asset('assets/logo.png'),
                SizedBox(height: MediaQuery.of(context).size.width * 0.3),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), 
                    ),
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                  }, 
                  child: const Text("Iniciar Sesión"),
                ),
                
                const SizedBox(height: 15),
                
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    foregroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                    minimumSize: Size(MediaQuery.of(context).size.width * 0.7, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), 
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Registro()));
                  }, 
                  child: const Text("Registrarse"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}