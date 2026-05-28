import 'package:flutter/material.dart';
import 'package:app/screens/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/rol.dart';
class Registro extends StatefulWidget {
  const Registro({
    super.key,
  });
@override
  State<Registro> createState() => _RegistroState();
}
class _RegistroState extends State<Registro> {
  final TextEditingController correo= TextEditingController();
  final TextEditingController nombre= TextEditingController();
  final TextEditingController clave= TextEditingController();
  final TextEditingController confirmacionClave= TextEditingController();
  Future<UserCredential> signInWithGoogle() async {//Sacado de la documentacion oficial de firebase
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(
      serverClientId: '29857906401-anpf031vrfnao1064dcmttk59ugfbdmq.apps.googleusercontent.com',
    );

    final GoogleSignInAccount? googleUser = await signIn.authenticate();

    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

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
                            Text("Nuevo aqui?, Registrate! ",style: TextStyle(fontSize: 50,fontWeight: FontWeight.w800,color: Color(0xFF8C5C32),),),                      
                        ),
                      ),
                      const Spacer(flex: 2),
                      SizedBox( 
                        width: MediaQuery.of(context).size.width*0.8,
                        child: TextField(
                          keyboardType: TextInputType.name, 
                          controller: nombre,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: "Nombre",
                            prefixIcon: Icon(Icons.person_2),
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
                        width: MediaQuery.of(context).size.width*0.8,
                        child: TextField(
                          controller: confirmacionClave,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Repite contraseña",
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
                            String camposNulos="";
                            if(nombre.text.isEmpty){
                              camposNulos="Nombre";
                            }
                            if(correo.text.isEmpty){
                              if(camposNulos.isNotEmpty){
                                camposNulos="$camposNulos, Correo";
                              }
                              else{
                                camposNulos="Correo";
                              }                             
                            }
                            if(clave.text.isEmpty){
                              if(camposNulos.isNotEmpty){
                                camposNulos="$camposNulos, Clave";
                              }
                              else{
                                camposNulos="Clave";
                              }                             
                            }
                            if(confirmacionClave.text.isEmpty){
                              if(camposNulos.isNotEmpty){
                                camposNulos="$camposNulos, Confirmacion Clave";
                              }
                              else{
                                camposNulos="Confirmacion Clave";
                              }                             
                            }
                            if(camposNulos.isNotEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: 
                                  Text("Siguientes campos vacios: $camposNulos"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            if(clave.text.length<8){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: 
                                  Text("Minimo 8 o mas caracteres"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            if(clave.text!=confirmacionClave.text){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: 
                                  Text("Claves distintas"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }
                            bool tieneEspecial= false;
                            bool tieneNumero= false;
                            bool tieneMayuscula= false;
                            bool tieneMinuscula= false;
                            for (int i=0; i<clave.text.length; i++){
                              String valor=clave.text[i];
                              if ("!@#\$%^&*()_+-=[]{}|;:,.<>?/".contains(valor)){
                                tieneEspecial=true;
                              }
                              else if ("0123456789".contains(valor)){
                                tieneNumero=true;
                              }
                              else if (valor==valor.toUpperCase() && valor!=valor.toLowerCase()){
                                tieneMayuscula=true;
                              }
                              
                              else if (valor==valor.toLowerCase() && valor!=valor.toUpperCase()){
                                tieneMinuscula=true;
                              }
                            }
                            String camposMal="";
                            if(tieneEspecial==false){
                              camposMal="Caracter especial";
                            }
                            if(tieneNumero==false){
                              if(camposMal.isNotEmpty){
                                camposMal="$camposMal, Numero";
                              }
                              else{
                                camposMal="Numero";
                              }                             
                            }
                            if(tieneMayuscula==false){
                              if(camposMal.isNotEmpty){
                                camposMal="$camposMal, Mayuscula";
                              }
                              else{
                                camposMal="Mayuscula";
                              }                             
                            }
                            if(tieneMinuscula==false){
                              if(camposMal.isNotEmpty){
                                camposMal="$camposMal, Minuscula";
                              }
                              else{
                                camposMal="Minuscula";
                              }                             
                            }
                            if(tieneEspecial==false ||tieneNumero==false ||tieneMayuscula==false ||tieneMinuscula==false){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: 
                                  Text("Faltan siguientes campos: $camposMal"),
                                  backgroundColor: Color(0xffA60321),
                                ),
                              );
                              return;
                            }else if(tieneEspecial==true && tieneNumero==true && tieneMayuscula==true && tieneMinuscula==true && clave.text.length>=8){
                              try{
                                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: correo.text.trim(),
                                  password: clave.text.trim(),
                                );
                                await userCredential.user?.updateDisplayName(nombre.text);
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
                                              'nombre': nombre.text,
                                              'correo': correo.text.trim(),
                                              'rol': 'alumno',
                                            });
                                            await userCredential.user?.sendEmailVerification();
                                            await FirebaseAuth.instance.signOut();
                                            
                                            if (mounted) {
                                              Navigator.pop(dialogContext);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Cuenta Creada, revisa Gmail"), backgroundColor: Colors.green),
                                              );
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                                            }
                                          },
                                          child: const Text("Alumno"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
                                              'nombre': nombre.text,
                                              'correo': correo.text.trim(),
                                              'rol': 'profesor',
                                            });
                                            await userCredential.user?.sendEmailVerification();
                                            await FirebaseAuth.instance.signOut();

                                            if (mounted) {
                                              Navigator.pop(dialogContext);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Cuenta Creada, revisa Gmail"), backgroundColor: Colors.green),
                                              );
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                                            }
                                          },
                                          child: const Text("Profesor"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } on FirebaseAuthException catch (e){
                                if (e.code=='email-already-in-use'){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("El correo ya esta"), 
                                    backgroundColor: Color(0xffA60321),
                                    ),
                                  );
                                }
                                else if(e.code=='invalid-email'){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Correo incorrecto"), 
                                    backgroundColor: Color(0xffA60321),
                                    ),
                                  );
                                }
                              }
                            }
                                  
                          }, child: Center(child: Text("Registrarse"))),
                      ),
                      const Spacer(flex: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: ()async{
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