import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Common/AuthFirebase.dart';
import '../Common/GeneralsMethods.dart';
import '../Common/NotificationAPI.dart';
import '../Common/Routes.dart';
import '../Common/firestore_database.dart';
import '../Models/user_profesional.dart';

class RegisterProfesionalPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterProfesionalPageState();
}

class RegisterProfesionalPageState extends State<RegisterProfesionalPage> with GeneralsMethods {
  //Controladores
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtDays = TextEditingController();
  TextEditingController txtHours = TextEditingController();

  //Variables
  //Para los días laborales
  Map<String, bool> diasTrabajo = {
    "Lunes":false,
    "Martes":false,
    "Miercoles":false,
    "Jueves":false,
    "Viernes":false,
    "Sabado":false,
    "Domingo":false,
  };

  //Para el horairo de atención
  Map<String, bool>horarioTrabajo ={
    "06:00:00-07:00:00":false,
    "07:00:00-08:00:00":false,
    "08:00:00-09:00:00":false,
    "09:00:00-10:00:00":false,
    "10:00:00-11:00:00":false,
    "11:00:00-12:00:00":false,
    "12:00:00-13:00:00":false,
    "13:00:00-14:00:00":false,
    "14:00:00-15:00:00":false,
    "15:00:00-16:00:00":false,
    "16:00:00-17:00:00":false,
    "17:00:00-18:00:00":false,
    "18:00:00-19:00:00":false,
    "19:00:00-20:00:00":false,
    "20:00:00-21:00:00":false,
  };

  Future<void> callPickers(BuildContext context, Map<String, bool> data,TextEditingController ctrl)async{
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context, setState) => SizedBox(
              height: 500,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text("Seleccione su disponibilidad", textAlign: TextAlign.center, style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const Divider(thickness: 1),
                  Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                              title: Text(data.keys.toList()[index]),
                              value: data.values.toList()[index],
                              onChanged: (value) {
                                setState(() {
                                  data[data.keys.toList()[index]] = value as bool;
                                });
                              });
                        }),
                  ),
                  const Divider(thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed:() {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancelar")
                      ),
                      TextButton(
                          onPressed:() {
                            List<String> aux=[];
                            data.forEach((key, value) {
                              if(value){
                                aux.add(key);
                              }
                            });
                            ctrl.text = aux.toString();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Aceptar")
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(15),
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
                                designFormField(
                                    "Nombre Completo",
                                    txtFullName,
                                    Icons.person_outlined,
                                    ValidateText.name,
                                    false),
                                designFormField(
                                    "Email",
                                    txtEmail,
                                    Icons.email_outlined,
                                    ValidateText.email,
                                    false),
                                designFormField(
                                    "Teléfono",
                                    txtPhone,
                                    Icons.phone_android_outlined,
                                    ValidateText.phone,
                                    false),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: TextFormField(
                                    controller: txtDays,
                                    readOnly: true,
                                    validator: (String? value){
                                      if(value!.isEmpty){
                                        return 'Selecione los días de atención';
                                      }
                                    },
                                    onTap: () => callPickers(context, diasTrabajo, txtDays),
                                    decoration: const InputDecoration(
                                        labelText: "Días de atención",
                                        labelStyle:
                                        TextStyle(color: Colors.blueGrey),
                                        prefixIcon: Icon(Icons.calendar_month,
                                            color: Colors.lightBlue),
                                        enabledBorder: OutlineInputBorder(
                                          //Cuando el cursor está fuera del cuadro
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue,
                                                width: 1.2)),
                                        focusedBorder: OutlineInputBorder(
                                          //Cuando el cursor está en el cuadro
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: TextFormField(
                                    controller: txtHours,
                                    readOnly: true,
                                    validator: (String? value){
                                      if(value!.isEmpty){
                                        return 'Seleccione las horas de atención';
                                      }
                                    },
                                    onTap: () => callPickers(context, horarioTrabajo, txtHours),
                                    decoration: const InputDecoration(
                                        labelText: "Horario de atención",
                                        labelStyle:
                                        TextStyle(color: Colors.blueGrey),
                                        prefixIcon: Icon(Icons.schedule,
                                            color: Colors.lightBlue),
                                        enabledBorder: OutlineInputBorder(
                                          //Cuando el cursor está fuera del cuadro
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue,
                                                width: 1.2)),
                                        focusedBorder: OutlineInputBorder(
                                          //Cuando el cursor está en el cuadro
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue))),
                                  ),
                                ),
                                designFormField("Contraseña", txtPassword,
                                    Icons.lock_outline, ValidateText.password, true),
                              ],
                            )),
                        const SizedBox(height: 15),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("¿Ya tienes una cuenta? "),
                              InkWell(
                                  child: const Text("Iniciar sesión",
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                          TextDecoration.underline)),
                                  onTap: () =>Navigator.pushNamedAndRemoveUntil(context,
                                      ROUTE_LOGIN, (route) => false))
                            ]),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () async{
                                if(formKey.currentState!.validate()){ //Si los campos están bien
                                  await AuthFirebase().signUp(txtEmail.text.trim(), txtPassword.text.trim()).then((e) { //creamos cuenta
                                    //Recibimos el error
                                    if(e != null){ //Si trae algo el error
                                      switch (e.code){
                                        case 'weak-password':
                                          message(context, "Error: La contraseña es demasiado débil");
                                          break;
                                        case 'email-already-in-use':
                                          message(context, "Error: Ya hay una cuenta con este email");
                                          break;
                                      }
                                    }else{ //si no, iniciamos sesion e insertamos
                                      //Creamos el objeto
                                      final usr = UserProfessional(
                                          uid: AuthFirebase().currentUser!.uid,
                                          name: txtFullName.text.trim(),
                                          phone: txtPhone.text.trim(),
                                          email: txtEmail.text.trim(),
                                          workDays: diasTrabajo,
                                          workHours: horarioTrabajo
                                      );
                                      Firestore().insertUserP(usr).whenComplete((){
                                        NotificationAPI.getTokenProfessional(AuthFirebase().currentUser!.email!);
                                        Navigator.pushNamedAndRemoveUntil(context, ROUTE_ROOT, (route) => false);
                                      }); //Insertamos en la db

                                    }
                                  }); //REGISTRO

                                }else{
                                  message(context, "Error: existen algunos campos incorrectos");
                                }
                              },
                              child: const Text("Crear Cuenta")),
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
                                )),
                            Text(" ó "),
                            Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 17,
                                  thickness: 1,
                                  endIndent: 20,
                                  indent: 20,
                                )),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text("Accede con",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: ()async{
                                //Primer comprobemos que el campo días de atención tenga contenido
                                if(txtDays.text.isEmpty){
                                  message(context, "Debe de ingresar los campos: Días de tención y Horario de atención");
                                }else{
                                  await AuthFirebase().signinWithGoogle(context, false); //Esperar a que se ejecute esta linea
                                  final userProfessional = UserProfessional(
                                      email: AuthFirebase().currentUser!.email,
                                      phone: AuthFirebase().currentUser!.phoneNumber,
                                      uid: AuthFirebase().currentUser!.uid,
                                      name: AuthFirebase().currentUser!.displayName,
                                      workDays: diasTrabajo,
                                      workHours: horarioTrabajo
                                  );
                                  Firestore().insertUserP(userProfessional).whenComplete(() {
                                    NotificationAPI.getTokenProfessional(AuthFirebase().currentUser!.email!);
                                    Navigator.pushNamedAndRemoveUntil(context, ROUTE_ROOT, (route) => false);
                                  });

                                }

                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    image: DecorationImage(
                                        image: AssetImage('assets/google.png'),
                                        fit: BoxFit.contain)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )))));
  }
}