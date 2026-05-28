import 'package:flutter/material.dart';
import 'package:app/screens/cambiarclave.dart';
import 'package:app/screens/rol.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
  });
@override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correo= TextEditingController();
  final TextEditingController clave= TextEditingController();
  Future<UserCredential> signInWithGoogle() async {//Sacado de la documentacion oficial de firebase
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(
      serverClientId: '29857906401-anpf031vrfnao1064dcmttk59ugfbdmq.apps.googleusercontent.com',
    );

    final GoogleSignInAccount? googleUser = await signIn.authenticate();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: "Inicio sesion cancelado");
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E9D8),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2E9D8),
      ),
      body: SafeArea(
        child: 
          SingleChildScrollView(            
            child: 
              SizedBox(
                height: MediaQuery.of(context).size.height-AppBar().preferredSize.height-MediaQuery.of(context).padding.top,
                width: double.infinity,
                child: Column(
                  children: [
                      const Spacer(flex: 1),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.8,
                        child: Align(
                          alignment: Alignment.centerLeft,                       
                          child:     
                            Text("Bienvenido otra vez! ",style: TextStyle(fontSize: 50,fontWeight: FontWeight.w800,color: Color(0xFF8C5C32),),),                      
                        ),
                      ),
                      const Spacer(flex: 2),
                      SizedBox( 
                        width: MediaQuery.of(context).size.width*0.8,
                        child: TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: correo,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: "Correo",
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.8,
                        child: TextField(
                          controller: clave,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18)
                            ),
                          ),
                        ),
                      ),  
                      const SizedBox(height: 15),                
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8C5C32),
                            foregroundColor: Colors.white,                           
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18), 
                            ),
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: ()async{
                            String correoVerificar = correo.text.trim();
                            String claveVerificar = clave.text.trim(); 
                            if(claveVerificar.isEmpty &&correoVerificar.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                  Text("Campos vacios"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            else if(correoVerificar.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                  Text("Correo no ingresado"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            else if(claveVerificar.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                  Text("Clave no ingresada"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            try{
                              final userCredential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: correoVerificar, password: claveVerificar);
                              if (userCredential.user?.emailVerified ?? false){
                                Navigator.pushReplacement(context,
                                 MaterialPageRoute(builder: (context) => Rol()),);
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                    Text("Verifica tu correo"),
                                    backgroundColor: Color(0xffA60321),
                                  ),
                                );
                              }
                            }on FirebaseAuthException catch (e){
                              if(e.code=="user-credential"){
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                    Text("Usuario no encontrado"),
                                    backgroundColor: Color(0xffA60321),
                                  ),
                                );
                              }else if(e.code=="user-credential"){
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                    Text("Contraseña Incorrecta"),
                                    backgroundColor: Color(0xffA60321),
                                  ),
                                );
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: 
                                    Text("Correo o contraseña invalido"),
                                    backgroundColor: Color(0xffA60321),
                                  ),
                                );
                              }
                            }
                                  
                          }, child: Center(child: Text("Iniciar Sesion"))),
                      ),

                      const SizedBox(height: 15),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8C5C32),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                        onPressed:
                          (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Clave()),);
                            }, 
                        child: Text("Olvidaste contraseña?")),                     
                      const Spacer(flex: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: ()async{
                            try{
                                UserCredential userCredential = await signInWithGoogle();
                                if (userCredential.user != null) {
                                  if (mounted) {
                                    final userDoc = await FirebaseFirestore.instance
                                        .collection('usuarios')
                                        .doc(userCredential.user!.uid)
                                        .get();

                                    if (userDoc.exists) {
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) =>  Rol()),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text("Selecciona tu Rol"),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
                                                    'nombre': userCredential.user!.displayName,
                                                    'correo': userCredential.user!.email,
                                                    'rol': 'alumno',
                                                  });
                                                  if (mounted) {
                                                    Navigator.pop(dialogContext);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => Rol()),
                                                    );
                                                  }
                                                },
                                                child: const Text("Alumno"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
                                                    'nombre': userCredential.user!.displayName,
                                                    'correo': userCredential.user!.email,
                                                    'rol': 'profesor',
                                                  });
                                                  if (mounted) {
                                                    Navigator.pop(dialogContext);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => Rol()),
                                                    );
                                                  }
                                                },
                                                child: const Text("Profesor"),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                                } catch (e) {                                 
                                  ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Error en proceso"),
                                          backgroundColor: Color(0xffA60321),
                                        ),
                                      );
                                }
                          }, icon: Icon(Icons.g_mobiledata_rounded,size: 60,)),
                          IconButton(onPressed: (){
                            
                          }, icon: Icon(Icons.facebook_outlined,size: 60)),
                        ],
                      ),
                      const Spacer(flex: 1),
                  ],
                ),
              ),         
          ),
      ),
    );
  }
}