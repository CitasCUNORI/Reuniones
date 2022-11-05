import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Common/AuthFirebase.dart';
import 'home_page.dart';
import 'login_page.dart';

class RootPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => RootPageState();
}

class RootPageState extends State<RootPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: AuthFirebase().authStateChanges,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return EmailVerifyPage(snapshot.data);
              }else{
                return LoginPage();
              }
            }
        )
    );
  }
}

class EmailVerifyPage extends StatefulWidget{
  User? userLog;

  EmailVerifyPage(this.userLog); //Recibe el usuario que está logueado


  @override
  State<StatefulWidget> createState() => StateEmailVerifyPage();

}
class StateEmailVerifyPage extends State<EmailVerifyPage>{
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = AuthFirebase().currentUser!.emailVerified;
    if(!isEmailVerified){
      timer = Timer.periodic(const Duration(milliseconds: 1500),
              (_)=> checkEmail());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmail() async{
    await AuthFirebase().currentUser!.reload();
    setState(() {
      isEmailVerified = AuthFirebase().currentUser!.emailVerified;
    });
    if(isEmailVerified) timer?.cancel();
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? MyHomePage(email: widget.userLog!.email)
      : Scaffold(
      appBar: AppBar(
        title: const Text("Verifique su email"),
        actions: [
          InkWell(
              onTap: ()=> AuthFirebase().signOut(),
              child: const Icon(Icons.output_outlined)
          )
        ],
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hemos enviado un correo electronico a ${widget.userLog!.email}, revise su email y la carpeta SPAM",
              textAlign: TextAlign.center
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
              onPressed: (){
                AuthFirebase().currentUser!.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Se he enviado el correo a ${widget.userLog!.email}"))
                );
              },
              // ignore: prefer_const_constructors
              icon: Icon(Icons.email),
              label: Text("Reenviar email")
          )
        ],
      )
  );
}

