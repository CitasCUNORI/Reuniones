import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Common/firestore_database.dart';
import '../../Models/user_profesional.dart';

class HoursEditingPage extends StatefulWidget{
  final UserProfessional _userProfessional;

  const HoursEditingPage(this._userProfessional, {Key? key}):super(key: key);

  @override
  State<HoursEditingPage> createState() => _HoursEditingPageState();
}

class _HoursEditingPageState extends State<HoursEditingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: buildEditingActions(),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: widget._userProfessional.getWorkHours!.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                  title: Text(widget._userProfessional.getWorkHours!.keys.toList()[index]),
                  value: widget._userProfessional.getWorkHours!.values.toList()[index],
                  onChanged: (value) {
                    setState(() {
                      widget._userProfessional.getWorkHours!
                      [widget._userProfessional.getWorkHours!.keys.toList()[index]] = value as bool;
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