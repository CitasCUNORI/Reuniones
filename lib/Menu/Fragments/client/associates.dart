import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Common/AuthFirebase.dart';
import '../../../Common/GeneralsMethods.dart';
import '../../../Common/firestore_database.dart';
import '../../../Models/user_client.dart';
import '../../../Models/user_profesional.dart';

class Associates extends StatefulWidget {
  @override
  State<Associates> createState() => _AssociatesState();
}

class _AssociatesState extends State<Associates> with GeneralsMethods {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController txtEmail = TextEditingController();

  Future<void> showAddAssociate(BuildContext context) async {
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

                              // Comprobamos que el usuario ya esté registrado
                              await Firestore().searchUserPByEmail(txtEmail.text.trim()).then((userP) {
                                if (userP != null) {
                                  //Enviamos a la base de dato
                                  Firestore().addAssociate(AuthFirebase().currentUser!.email, userP.getEmail!);
                                  Navigator.of(context).pop();
                                } else {
                                  message(context,"Error: El email del usuario no está registrado");
                                }
                              });
                            }
                          },
                          child: const Text("Aceptar",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ));
        });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            showAddAssociate(context);
          },
          tooltip: "Asociate con otro usuario",
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore().usersStreamAssociates,
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child:  CircularProgressIndicator());
              }
              return FutureBuilder<List<UserProfessional>?>(
                  future:Firestore().listAssociatesByClient(AuthFirebase().currentUser!.email!),
                  builder:(_, snapshot) {
                    if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return designList(snapshot.data![index]);
                          },
                        );

                    }else if(!snapshot.hasData){
                      return const Center(child: Text("No hay professionales asociados"));
                    }else{
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
              );
            }
        )
    );
  }


}
