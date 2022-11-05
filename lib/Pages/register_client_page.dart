import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Common/AuthFirebase.dart';
import '../Common/GeneralsMethods.dart';
import '../Common/NotificationAPI.dart';
import '../Common/Routes.dart';
import '../Common/firestore_database.dart';
import '../Models/user_client.dart';
import '../Models/user_profesional.dart';

class RegisterClientPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterClientPageState();
}

class RegisterClientPageState extends State<RegisterClientPage> with GeneralsMethods{
  /*Controladores*/
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtPhone = TextEditingController();

  /*Objetos*/
  AuthFirebase? authFirebase;



  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Padding(padding:const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 35),
                        const Text("CREAR CUENTA", style: TextStyle(fontSize: 35, color: Colors.lightBlue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 35),
                        Form(
                            key: formKey,
                            child: Column(
                              children: [
                                designFormField("Nombre Completo", txtFullName, Icons.person_outlined, ValidateText.name, false),
                                designFormField("Email", txtEmail, Icons.email_outlined, ValidateText.email, false),
                                designFormField("Teléfono", txtPhone, Icons.phone_android_outlined, ValidateText.phone, false),
                                designFormField("Contraseña", txtPassword, Icons.lock_outline, ValidateText.password, true),
                              ],
                            )
                        ),
                        const SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:  [
                              const Text("¿Ya tienes una cuenta? "),
                              InkWell(
                                  child: const Text("Iniciar sesión", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  onTap: ()=> Navigator.pushNamedAndRemoveUntil(context, ROUTE_LOGIN, (route) => false)
                              )]
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () async{
                                //Primero validamos que todos los campos estén bien
                                if(formKey.currentState!.validate()){ //Si los campos están bien, registramos

                                  await AuthFirebase().signUp(txtEmail.text.trim(), txtPassword.text.trim()).then((e){
                                    if(e != null){ //Si trae algo el error
                                      switch (e.code){
                                        case 'weak-password':
                                          message(context, "Error: La contraseña es demasiado débil");
                                          break;
                                        case 'email-already-in-use':
                                          message(context, "Error: Ya hay una cuenta con este email");
                                          break;
                                      }
                                    }else{ //si no trae nada, iniciamos sesion e insertamos
                                      //Creamos el objeto
                                      final usr = UserClient(
                                        uid: AuthFirebase().currentUser!.uid,
                                        name: txtFullName.text.trim(),
                                        phone: txtPhone.text.trim(),
                                        email: txtEmail.text.trim(),
                                      );
                                      Firestore().insertUserC(usr).whenComplete((){
                                        NotificationAPI.getTokenClient(AuthFirebase().currentUser!.email!); //Obtenemos token y guardamos
                                        Navigator.pushNamedAndRemoveUntil(context, ROUTE_ROOT, (route) => false);
                                      }); //Insertamos en la db
                                    }
                                  }); //REGISTRO

                                }else { //Si hay campos incorrectos, mostramos error
                                  message(context, "Error: Campos incorrectos");
                                }
                              },
                              child: const Text("Crear cuenta")
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
                        const Text("Accede con", style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async{
                                await AuthFirebase().signinWithGoogle(context, false); //Esperar a que se ejecute esta linea
                                final userClient = UserClient(
                                    email: AuthFirebase().currentUser!.email,
                                    phone: AuthFirebase().currentUser!.phoneNumber,
                                    uid: AuthFirebase().currentUser!.uid,
                                    name: AuthFirebase().currentUser!.displayName
                                );
                                await Firestore().insertUserC(userClient).whenComplete((){
                                  NotificationAPI.getTokenClient(AuthFirebase().currentUser!.email!);
                                  Navigator.pushNamedAndRemoveUntil(context, ROUTE_ROOT, (route) => false);
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
                      ],
                    )
                )
            )
        )
    );
  }




}