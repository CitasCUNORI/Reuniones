import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:reuniones/Models/meetings.dart';

import '../Models/user_profesional.dart';


enum ValidateText{email, phone, name, password}


mixin GeneralsMethods{


  // Este metodo retorna el diseño de las cajas de texto para los formularios empleados
  Widget designFormField
      (String name, TextEditingController controller, IconData icon, ValidateText type, bool password, {Future<void>? method})
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        inputFormatters: [validateInputFormats(type)],
        keyboardType: keyboardType(type),
        validator: (String? value){
          if(value!.isEmpty){ //Primero validamos que no esté vacío
            return 'Ingrese un ${name}';
          }
          return validateStructure(type, value);
        },
        onTap: ()=>method,
        decoration: InputDecoration(
            labelText: name,
            labelStyle: const TextStyle(color: Colors.blueGrey),
            prefixIcon: Icon(icon, color: Colors.lightBlue),
            enabledBorder: const OutlineInputBorder(
              //Cuando el cursor está fuera del cuadro
                borderSide:
                BorderSide(color: Colors.lightBlue, width: 1.2)),
            focusedBorder: const OutlineInputBorder(
              //Cuando el cursor está en el cuadro
                borderSide: BorderSide(color: Colors.lightBlue))),
      ),
    );
  }

  validateStructure(ValidateText type, String? value){
    switch(type){
      case ValidateText.phone:
        return validatePhone(value!)?null:"La estructura del telefono es incorrecta";
      case ValidateText.email:
        return validateEmail(value!)?null: "La estructura del email es incorrecta";
      default:
        return null;
    }
  }

  static validateEmail(String email){
    String exp = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    return RegExp(exp).hasMatch(email);
  }

  static validatePhone(String phone){
    String exp = r'^\d{8}$';
    return RegExp(exp).hasMatch(phone);
  }


  validateInputFormats(ValidateText type){
    switch(type){
      case ValidateText.phone: //solo numeros
        return FilteringTextInputFormatter.digitsOnly;
      default: //Cualquier otro, todos los dígitos
        return FilteringTextInputFormatter.singleLineFormatter;
    }
  }
  
  keyboardType(ValidateText type){
    switch(type){
      case ValidateText.phone: //solo numeros
        return TextInputType.phone;
      case ValidateText.email: //email
        return TextInputType.emailAddress;
      default: //Cualquier otro, todos los dígitos
        return TextInputType.text;
    }
  }

  //Metodo para mostrar mensajes
  void message(BuildContext context, String mensaje){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget designList(UserProfessional user){
    return ListTile(
      title: Text(user.getName!),
      subtitle: Text(user.getEmail!),
      trailing: Icon(Icons.more_vert),
      leading: Icon(Icons.chrome_reader_mode),
      onTap: (){},
      onLongPress: (){},
    );
  }
  Widget designListPendingMeeting(Meeting meeting){
    return ListTile(
      title: Text(meeting.getEventName),
      subtitle: Text(meeting.getEmailClient),
      leading: const Icon(Icons.pending_actions_outlined),
      onTap: (){},
      onLongPress: (){},
    );
  }

  Widget designListDoneMeeting(Meeting meeting){
    return ListTile(
      title: Text(meeting.getEventName),
      subtitle: Text(meeting.getEmailClient),
      leading: const Icon(Icons.done_all),
      onTap: (){},
      onLongPress: (){},
    );
  }

  Widget itemCardSettings ({String? title, dynamic rightWidget, VoidCallback? onTap}){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 24),
              child: Center(
                child: Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 24),
              child: rightWidget,
            )
          ],
        ),
      ),
    );

  }

  showAboutUS(BuildContext context){
    showAboutDialog(
      context: context,
      applicationIcon: Image.asset('assets/cunori.png'),
      applicationName: "Reuniones",
      applicationVersion: "Version 1.0.0",
      applicationLegalese: 'CUNORI 2022',
      children: [
        const SizedBox(height: 10),
        const Text(
          "Esta aplicacion fue desarrollada por estudiantes de la carrera de ingniería en ciencias y sistemas.",
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 10),
        const Text("Uso exclusivo de cualquier area profesional del CUNORI."),
        const SizedBox(height: 15),
        const Text("Colaboradores",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text("Emilio Calderón"),
            Icon(Icons.arrow_forward_outlined),
            Text(" Versión 1.0.0")
          ],
        )

      ]
    );
  }

  showHelpMeetings(BuildContext context){
    return showDialog(
      context: context,
      builder: (context) {
        return  Dialog(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)),
          child: Padding(
            padding: const EdgeInsets.only(right: 30, left: 30, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    child: Icon(Icons.help, size: 87, color: Colors.blue,)
                ),
                const Text("Estados de las reuniones",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                const SizedBox(height: 15,),
                const Text("Las reuniones pueden tener varios estados. "
                    "Cada estado es representado por un color diferente "
                    "dentro del calendario de cada profesional.",
                  style: TextStyle(fontSize: 14), textAlign: TextAlign.justify),
                const SizedBox(height: 20,),

                Row(
                  children: const [
                    Icon(Icons.circle, size: 35, color: Colors.deepOrange),
                    Text(" Reunión Programada \n(En espera de aprobación)", style: TextStyle(fontSize: 18),)
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.circle, size: 35, color: Colors.blue),
                    Text(" Reunion Aceptada \n(pendiente de realizarse)", style: TextStyle(fontSize: 18),)
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.circle, size: 35, color: Colors.green),
                    Text(" Reunión realizada", style: TextStyle(fontSize: 18),)
                  ],
                ),
                const SizedBox(height: 7),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close")
                )

              ],
            ),
          ),
        );
      },
    );

  }



}

