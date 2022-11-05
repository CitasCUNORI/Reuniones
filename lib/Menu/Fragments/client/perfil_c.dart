import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/AuthFirebase.dart';
import 'package:reuniones/Common/firestore_database.dart';
import 'package:reuniones/Values/DimensApp.dart';

class PerfilClient extends StatelessWidget{

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Firestore().searchUserCByEmail(AuthFirebase().currentUser!.email),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: double.minPositive+15, right: double.minPositive+15, bottom: 20, top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 70,
                        child: Icon(Icons.account_circle, size: 120, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(snapshot.data!.getName!, style: const TextStyle(fontSize: 24), textAlign: TextAlign.center),
                      const SizedBox(height: 5),
                      Text(snapshot.data!.getEmail!),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => AuthFirebase().signOut(),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(30))
                          ),
                          height: buttonsHeight,
                          width: buttonsWith,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Icon(Icons.logout, size: 30, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                      "Cerrar sesión",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          }else if (snapshot.hasError){
            return const Center(
              child: Text('Ha ocurrido un error'),
            );
          }else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

        }
      ),
    );
  }
}