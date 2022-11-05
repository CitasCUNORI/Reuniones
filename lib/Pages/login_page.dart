import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/NotificationAPI.dart';
import 'package:reuniones/Common/firestore_database.dart';

import '../Common/AuthFirebase.dart';
import '../Common/GeneralsMethods.dart';
import '../Common/Routes.dart';
import '../Values/DimensApp.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with GeneralsMethods{
  bool? isLogin;
  User? user;

  Future<void> _showDialogReset(BuildContext context) async {
    TextEditingController txtEmail = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text(
                  "Ingrese un email",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                content: Form(
                  key: formKey,
                  child: designFormField("Email", txtEmail,
                      Icons.email_outlined, ValidateText.email, false),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {//Comprobamos que esté bien el formulario

                          AuthFirebase().resetPassword(txtEmail.text).whenComplete((){
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      child: const Text("Aceptar",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ));
        });
  }



  //Controladores
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return  SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Padding(padding:const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text("INICIAR SESIÓN", style: TextStyle(fontSize: titleP, color: Colors.lightBlue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 40),
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                designFormField("Email", txtEmail, Icons.person_outlined, ValidateText.email, false),
                                designFormField("Contraseña", txtPassword, Icons.lock, ValidateText.password, true),
                              ],
                            )
                        ),
                        const SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:  [
                              InkWell(
                                child: const Text("¿Olvidaste tu contrseña?", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                onTap: (){
                                  _showDialogReset(context).whenComplete(() {
                                    message(context, 'Se ha enviado un correo electronico a la direccion ingresada');
                                  });
                                },
                              )]
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: ()  {
                                //Primero vamos a comprobar que todos los campos estén correctos
                                if(formKey.currentState!.validate()){ // si están validados, hacemos login

                                  AuthFirebase().sigIn(txtEmail.text.trim(), txtPassword.text.trim()).then((e){
                                    //Comprobamos que el error no sea nulo
                                    if(e != null){ //Si el error trae algo
                                      switch(e.code){
                                        case 'user-not-found':
                                          message(context, "Error: Usuario no encontrado");
                                          break;
                                        case 'wrong-password':
                                          message(context, "Error: Credenciales incorrectas");
                                          break;
                                      }
                                    }else{
                                      Firestore().searchUserCByEmail(txtEmail.text).then((value){
                                        if(value == null){
                                          NotificationAPI.getTokenProfessional(txtEmail.text);
                                        }else{
                                          print("Aca");
                                          NotificationAPI.getTokenClient(txtEmail.text);
                                        }
                                      });
                                    }
                                  }); //LOGIN

                                }else{ //Si no están validados, mostramos error
                                  message(context, "Error: Hay algunos campos incorrectos");
                                }

                              },
                              child: Text("Iniciar Sesión", style: TextStyle(fontSize: titleButtons))
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: const [
                            Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 17,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 20,
                                )
                            ),
                            Text(" ó "),
                            Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 17,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 20,
                                )
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text("Ingresa con", style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: ()async{
                                await AuthFirebase().signinWithGoogle(context, true).then((result) {
                                  if(result == 'user-doesnt-exist'){
                                    message(context, "Usuario no encontrado.  Intenta crear una cuenta");
                                  }
                                }).whenComplete(() {
                                  Firestore().searchUserCByEmail(AuthFirebase().currentUser!.email).then((value){
                                    if(value == null){
                                      NotificationAPI.getTokenProfessional(AuthFirebase().currentUser!.email!);
                                    }else{
                                      NotificationAPI.getTokenClient(AuthFirebase().currentUser!.email!);
                                    }
                                  });
                                });
                              },
                              child: Container(
                                height: 50, width: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: AssetImage('assets/google.png'),
                                        fit: BoxFit.contain
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
                              const Text("¿Aun no tienes una cuenta?"),
                              const Text("  "),
                              InkWell(
                                child: const Text("Crear una cuenta", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                onTap: (){
                                  Navigator.pushNamed(context, ROUTE_REGISTER);
                                },
                              )]
                        ),
                      ],
                    )
                )
            )
        )
    );
  }


}