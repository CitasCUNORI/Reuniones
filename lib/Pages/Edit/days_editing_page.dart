import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/AuthFirebase.dart';
import 'package:reuniones/Common/firestore_database.dart';
import 'package:reuniones/Models/user_profesional.dart';

class DaysEditingPage extends StatefulWidget{

  final UserProfessional _userProfessional;
  const DaysEditingPage(this._userProfessional, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState()=> DaysEditingState();

}

class DaysEditingState extends State<DaysEditingPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: buildEditingActions(),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: widget._userProfessional.getWorkDays!.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(widget._userProfessional.getWorkDays!.keys.toList()[index]),
              value: widget._userProfessional.getWorkDays!.values.toList()[index],
              onChanged: (value) {
                setState(() {
                  widget._userProfessional.getWorkDays!
                  [widget._userProfessional.getWorkDays!.keys.toList()[index]] = value as bool;
                });
               }
              );
            }
        ),
      ),
    );
  }

  List<Widget> buildEditingActions()=>[
    ElevatedButton.icon(
      icon: const Icon(Icons.done),
      label: const Text("Guardar"),
      onPressed: ()async{
        await Firestore().insertUserP(
          widget._userProfessional
        ).whenComplete(() => Navigator.of(context).pop());
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent
      ),
    ),

  ];

}