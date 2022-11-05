import 'package:flutter/material.dart';
import 'package:reuniones/Common/NotificationAPI.dart';
import '../Common/GeneralsMethods.dart';
import '../Common/firestore_database.dart';
import '../Models/meetings.dart';

class SelfMeetingAddPage extends StatefulWidget{
  final Meeting meeting;
  const SelfMeetingAddPage(this.meeting, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() => SelfMeetingAddPageState();

}

class SelfMeetingAddPageState extends State<SelfMeetingAddPage> with GeneralsMethods{
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _txtTitulo = TextEditingController();
  final TextEditingController _txtFrom = TextEditingController();
  final TextEditingController _txtTo = TextEditingController();


  @override
  void initState() {

    _txtTitulo.text = widget.meeting.getEventName;
    _txtFrom.text = "${widget.meeting.getFrom.day} de "
        "${getMonth(widget.meeting.getFrom.month)} del "
        "${widget.meeting.getFrom.year} a las "
        "${widget.meeting.getFrom.hour}:${widget.meeting.getFrom.minute} hrs";

    _txtTo.text =
    "${widget.meeting.getTo.day} de "
        "${getMonth(widget.meeting.getTo.month)} del "
        "${widget.meeting.getTo.year} a las "
        "${widget.meeting.getTo.hour}:${widget.meeting.getTo.minute} hrs";

    super.initState();
  }

  @override
  void dispose() {
    _txtTitulo.dispose();
    _txtFrom.dispose();
    _txtTo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKey,
                child: Column(
                    children: [
                      designFormField("Títutlo de la auto reunión", _txtTitulo, Icons.title, ValidateText.name, false),
                      const SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _txtFrom,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                              labelText: "Inicio de la reunión",
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              prefixIcon: Icon(Icons.timer_outlined, color: Colors.lightBlue, size: 30),
                              enabledBorder: OutlineInputBorder(
                                //Cuando el cursor está fuera del cuadro
                                  borderSide: BorderSide(
                                      color: Colors.lightBlue,
                                      width: 1.2)),
                              focusedBorder: OutlineInputBorder(
                                //Cuando el cursor está en el cuadro
                                  borderSide: BorderSide(color: Colors.lightBlue))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          controller: _txtTo,
                          readOnly: true,
                          enabled: false,
                          decoration: const InputDecoration(
                              labelText: "Fin de la reunión",
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              prefixIcon: Icon(Icons.timer_off_outlined, color: Colors.lightBlue,size: 30),
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
                    ]
                ),
              ),
            ]
        ),
      ),
    );
  }

  List<Widget> buildEditingActions()=>[
    ElevatedButton.icon(
      icon: const Icon(Icons.done),
      label: const Text("Guardar"),
      onPressed: (){

        //Primero comoprobar si ya ingresó texto
        if(_formKey.currentState!.validate()){ //Si ha llenado el campo
          widget.meeting.setEventName = _txtTitulo.text.trim(); //Obtenemos el titutlo

          Firestore().insertMeeting(widget.meeting).whenComplete((){

            /*Notificaiones al professional*/
            Firestore().searchUserPByEmail(widget.meeting.getEmailProfessional).then((prof) {

              NotificationAPI().sendNotification( //Notificaion de nueva reunion
                  'Nueva auto reunión',
                  'Has programado una auto reunión con éxito',
                  prof!.getToken!,
              );

            });

            Navigator.of(context).pop();
          });
        }

      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent
      ),
    ),

  ];

  String getMonth(int month){
    switch(month){
      case 1:
        return "enero";
      case 2:
        return "febrero";
      case 3:
        return "marzo";
      case 4:
        return "abril";
      case 5:
        return "mayo";
      case 6:
        return "junio";
      case 7:
        return "julio";
      case 8:
        return "agosto";
      case 9:
        return "septiembre";
      case 10:
        return "octubre";
      case 11:
        return "noviembre";
      case 12:
        return "diciembre";
      default:
        return"";
    }
  }

}