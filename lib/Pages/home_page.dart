import 'package:flutter/material.dart';
import 'package:reuniones/Menu/Fragments/client/settings_c.dart';
import '../Common/AuthFirebase.dart';
import '../Common/firestore_database.dart';
import '../Menu/Fragments/client/perfil_c.dart';
import '../Menu/Fragments/professional/perfil_p.dart';
import '../Menu/Fragments/professional/settings_p.dart';
import '../Menu/Fragments/client/agenda_c.dart';
import '../Menu/Fragments/professional/agenda_p.dart';
import '../Menu/Fragments/client/associates.dart';
import '../Menu/menu_bar_client.dart';
import '../Menu/menu_bar_professionals.dart';
import '../Models/user_profesional.dart';

class MyHomePage extends StatefulWidget {
  final String? email;
  const MyHomePage({Key? key, this.email}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex=1;

  List fragmentsC = [
    PerfilClient(),
    Associates(),
    AgendaClient(),
    SettingsClient()
  ];

  List fragmentsP = [
    PerfilProfessional(),
    AgendaProfessional(),
    SettingsProfessional()
  ];


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firestore().searchUserPByEmail(AuthFirebase().currentUser!.email),
        builder: (BuildContext context, AsyncSnapshot<UserProfessional?> snapshot){
          if(snapshot.hasData){
            return homeProfessional();
          }else{
            return homeClient();
          }
        }
    );

  }

  onTab(int index){
    setState(() {
      currentIndex = index;
    });
  }

  Widget homeClient(){
    return Scaffold(
      appBar: AppBar(title: Text("${widget.email}")),
      bottomNavigationBar: MenuBarClient(onTab, currentIndex),
      body: fragmentsC[currentIndex],
    );
  }

  Widget homeProfessional(){
    return Scaffold(
      appBar: AppBar(title: Text("${widget.email}")),
      bottomNavigationBar: MenuBarProfessionals(onTab, currentIndex),
      body: fragmentsP[currentIndex],
    );
  }


}