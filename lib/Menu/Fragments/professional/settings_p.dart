import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/GeneralsMethods.dart';
import 'package:reuniones/Common/firestore_database.dart';
import 'package:reuniones/Pages/Edit/days_editing_page.dart';
import 'package:reuniones/Pages/Edit/hours_editing_page.dart';

import '../../../Common/AuthFirebase.dart';

class SettingsProfessional extends StatelessWidget with GeneralsMethods{
  Widget _arrow() {
    return const Icon(
      Icons.arrow_forward_ios,
      size: 20.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: FutureBuilder(
        future: Firestore().searchUserPByEmail(AuthFirebase().currentUser!.email),
        builder: (context, snapshot)  {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Cuenta',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    itemCardSettings(
                      title: 'Días de atención',
                      rightWidget: _arrow(),
                      onTap: () {
                        Navigator.push(context,  MaterialPageRoute(builder: (context) =>
                            DaysEditingPage(snapshot.data!)
                        ));

                      },
                    ),
                    itemCardSettings(
                      title: 'Horario de atención',
                      rightWidget: _arrow(),
                      onTap: () {
                        print(snapshot.data!.getWorkHours);
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          HoursEditingPage(snapshot.data!)
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Others',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    itemCardSettings(
                      title: 'Cambiar contraseña',
                      rightWidget: _arrow(),
                      onTap: () async {
                        await AuthFirebase().resetPassword(AuthFirebase().currentUser!.email!).whenComplete(()
                        =>message(context, "Se ha enviado un correo electronico a ${AuthFirebase().currentUser!.email}")
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Informacion',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    itemCardSettings(
                      title: 'Sobre nosotros',
                      rightWidget: _arrow(),
                      onTap: () {
                        showAboutUS(context);
                      },
                    ),
                    itemCardSettings(
                      title: 'Version',
                      rightWidget: const Center(
                        child: Text('1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            )
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

}