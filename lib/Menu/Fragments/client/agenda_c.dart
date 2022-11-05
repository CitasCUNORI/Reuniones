import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Pages/meeting_add_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../Common/AuthFirebase.dart';
import '../../../Common/GeneralsMethods.dart';
import '../../../Common/NotificationAPI.dart';
import '../../../Common/firestore_database.dart';
import '../../../Models/meetings.dart';
import '../../../Models/user_profesional.dart';

class AgendaClient extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => AgendaClientState();
}


class AgendaClientState extends State<AgendaClient> with GeneralsMethods{
  //PopupMenu
  List<Meeting>? meetings;
  CalendarController controlador = CalendarController();
  String? emailSelected;

  
  Future _showMenuMeet(BuildContext context, Meeting meeting) async{
    return await showDialog(
      context: context,
      builder: (context) {
        return  AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed:() async{
                  await Firestore().deleteMeeting(meeting).whenComplete((){

                    /*Notificaiones al professional*/
                    Firestore().searchUserPByEmail(meeting.getEmailProfessional).then((prof) {

                      NotificationAPI().sendNotification( //Notificaion de cancelación
                        'Reunión cancelada',
                        'El usuario ${meeting.getEmailClient} ha cancelado una reunión',
                        prof!.getToken!,
                      );

                    });

                    /*Notificaiones al cliente*/
                    Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                      NotificationAPI().sendNotification(
                        'Reunión Cancelada',
                        'Has cancelado una reunion con: ${meeting.getEmailProfessional}',
                        client!.getToken!,
                      );

                    });


                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text("Cancelar reunión", style: TextStyle(color: Colors.red, fontSize: 17))
              ),
              TextButton.icon(
                onPressed:() async{
                  meeting.setIsDone = true;
                  await Firestore().insertMeeting(meeting).whenComplete(() {

                    /*Notificaiones al professional*/
                    Firestore().searchUserPByEmail(meeting.getEmailProfessional).then((prof) {

                      NotificationAPI().sendNotification( //Notificaion de realizada
                        'Reunión realizada',
                        'El usuario ${meeting.getEmailClient} ha marcado como realizada una reunión',
                        prof!.getToken!,
                      );

                    });

                    /*Notificaiones al cliente*/
                    Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                      NotificationAPI().sendNotification(
                        'Reunión Realizada',
                        'Has marcado una reunion como realizada',
                        client!.getToken!,
                      );

                    });


                    Navigator.of(context).pop();
                  });
                },
                icon: Icon(Icons.done_all,color: Colors.green[700]),
                  label: Text("Está realizada", style: TextStyle(color: Colors.green[700], fontSize: 17))
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  void initState(){
    controlador.view = CalendarView.workWeek;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(controlador.selectedDate!=null){ //Combrobación de seleccion

              //Comprobamos que la fecha seleccionada no haya pasado
              if (controlador.selectedDate!.isAfter(DateTime.now())) {
                final inicio = controlador.selectedDate;
                final fin = inicio!.add(const Duration(minutes: 30));
                //Inicializamos el objeto a crear
                final _meeting = Meeting(
                  eventName: "",
                  from: inicio,
                  to: fin,
                  emailClient: AuthFirebase().currentUser!.email,
                  emailProfessional: emailSelected,
                  isDone: false,
                  isApproved: false
                );
                Navigator.push(context, MaterialPageRoute(builder: (builder)=> MeetingAddPage(_meeting)));
              }else{
                message(context, "No puede ingresar nuevas reuniones en fechas pasadas.");
              }
            }else{
              message(context, "Debe de seleccionar la casilla de su interés");
            }
          },
        child: const Icon(Icons.add),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: Firestore().usersStreamAssociates,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: FutureBuilder<List<String>?>(
                      future: Firestore().listEmails(AuthFirebase().currentUser!.email),
                      builder: (_, AsyncSnapshot<List<String>?> snapshot){
                        if(snapshot.hasData){
                          return DropdownButton(
                            items: snapshot.data!.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                             onChanged: (String? value) { //Cuando cambia el valor del professional seleccionado
                              Firestore().listMeetingsByProfessional(value!).then((e) {
                                setState(() {
                                  controlador.selectedDate = null;
                                  meetings = e;
                                  emailSelected = value;
                                });
                              });
                             },
                            value: emailSelected,
                            isExpanded: false,
                          );
                        }else{
                          return const Center(child: Text("No hay professionales asociados"));
                        }
                      }
                  ),
                );
              }
          ),
            StreamBuilder<QuerySnapshot>(
              stream:(emailSelected!=null)? Firestore().getStreamMeeting(emailSelected!): null,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: FutureBuilder<UserProfessional?>(
                    future: Firestore().searchUserPByEmail(emailSelected),
                    builder: (_, AsyncSnapshot<UserProfessional?> snapshot) {
                      if(emailSelected==null){
                        return const Center(child: Text("Seleccione un profesional"));
                      }
                      if(snapshot.hasData){
                        return SfCalendar(
                          controller: controlador,
                          dataSource: MeetingDataSource(
                              _getDataSource(snapshot.data!.getMeetings)
                          ),
                          firstDayOfWeek: 1,
                          view: CalendarView.workWeek,
                          specialRegions: _getTimeRegions(
                              snapshot.data!.getWorkDays,
                              snapshot.data!.getWorkHours
                          ),
                          timeSlotViewSettings: TimeSlotViewSettings(
                            nonWorkingDays: _getNonWorkingDays(snapshot.data!.getWorkDays), //filtro de días
                            timeIntervalHeight: 50,
                            timeRulerSize: 40,
                            startHour: 6,
                            endHour: 21,
                            dayFormat: 'EEE',
                            timeFormat: 'jm',
                            timeInterval: const Duration(minutes: 30),
                          ),
                          monthViewSettings: const MonthViewSettings(
                              showAgenda: true
                          ),
                          showDatePickerButton: true,
                          allowedViews: const <CalendarView>[
                            CalendarView.workWeek,
                            CalendarView.month,
                          ],
                          onTap: (calendarTapDetails) {
                            if(controlador.selectedDate==null && calendarTapDetails.appointments!.isNotEmpty){
                              final recurso = calendarTapDetails.appointments!.first as Meeting;
                              if(recurso.getEventName == 'No disponible'){ //Si el evento no le pertenece al cliente actual
                                message(context, "No hay acciones para este evento, no le pertece.");

                              }else { //Si el evento si le pertenece al usuario actual

                                //Comprobamos que la reunion está aprobada por el profesional
                                if(recurso.getIsApproved){ //Si está aprobada

                                  //Comprobar que no se haya realizado
                                  if(recurso.getIsDone){ //Si ya se realizó
                                    message(context, "No hay acciones para realizar, el evento ha culminado");
                                  }else{ //Si no se ha realizado
                                    _showMenuMeet(context, recurso);
                                  }

                                }else{
                                  message(context, "La reunion aun está pendiente de aprobación");
                                }
                              }
                            }
                          },
                          onLongPress: (calendarLongPressDetails) {
                            //si ya tiene un evento y el evento pertenece al cliente
                            if(controlador.selectedDate==null && calendarLongPressDetails.appointments!.isNotEmpty){
                              final recurso = calendarLongPressDetails.appointments!.first as Meeting;
                              if(recurso.getEventName == 'No disponible'){ //Si el evento no le pertenece al cliente actual
                                message(context, "No hay acciones para este evento, no le pertece.");

                              }else { //Si el evento si le pertenece al usuario actual

                                //Comprobamos que la reunion está aprobada por el profesional
                                if(recurso.getIsApproved){ //Si está aprobada

                                  //Comprobar que no se haya realizado
                                  if(recurso.getIsDone){ //Si ya se realizó
                                    message(context, "No hay acciones para realizar, el evento ha culminado");
                                  }else{ //Si no se ha realizado
                                    _showMenuMeet(context, recurso);
                                  }

                                }else{
                                  message(context, "La reunion aun está pendiente de aprobación");
                                }
                              }
                            }
                          },
                        );
                      }
                      else{
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                    },
                  ),
                );
              }
            )
        ],
      )
    );
  }

  //Recibo un Map de <TimeOfDay, String>
  List<TimeRegion> _getTimeRegions(Map<String, bool>? days, Map<String, bool>? hours) {
    final List<TimeRegion> regions = <TimeRegion>[]; //Lista que se retornará
    DateTime inicio;
    DateTime fin;

    for(MapEntry day in days!.entries){
      if(day.value){ //Obtengo los días que si se trabaja
        //print("DIA ${day.key}:${day.value}");
        for(MapEntry hour in hours!.entries) {
          if (hour.value != true) { //Obtengo los horarios laborales
            inicio = DateTime(DateTime.now().year, DateTime.now().month, _getDay(day.key), _getHoursxDay(hour.key));
            fin = inicio.add(const Duration(hours: 1));
            regions.add(
                TimeRegion(
                  startTime: inicio,
                  endTime: fin,
                  enablePointerInteraction: false,
                  textStyle: const TextStyle(color: Colors.black45, fontSize: 15),
                  color: Colors.grey.withOpacity(0.5),
                  iconData: Icons.block,
                  recurrenceRule: 'FREQ=DAILY;INTERVAL=7',
                )
            );
          }
        }

      }
    }
    return regions;
  }

  List<int> _getNonWorkingDays(Map<String, bool>? days) {
    List<int> workingdays = [];
    for(MapEntry day in days!.entries){
      if(day.value != true){ //Obtengo los días que NO se trabaja
        switch(day.key){
          case "Lunes":
            workingdays.add(1);
            break;
          case "Martes":
            workingdays.add(2);
            break;
          case "Miercoles":
            workingdays.add(3);
            break;
          case "Jueves":
            workingdays.add(4);
            break;
          case "Viernes":
            workingdays.add(5);
            break;
          case "Sabado":
            workingdays.add(6);
            break;
          case "Domingo":
            workingdays.add(7);
            break;
        }
      }//Fin if
    }//Fin for
    return workingdays;
  }



  //Retorna el primer día de la semana actual, para empezar con las restricciones desde el dia actual
  int _getDay(String date){
    switch(date){
      case "Lunes":
        DateTime today = DateTime.now();
        print(" LUNES ${DateTime.now().subtract(Duration(days: today.weekday -1)).day}");
        return DateTime.now().subtract(Duration(days: today.weekday -1)).day; //Retorna el lunes
      case "Martes":
        DateTime today = DateTime.now();
        return DateTime.now().subtract(Duration(days: today.weekday -2)).day; //Retorna el martes
      case "Miercoles":
        DateTime today = DateTime.now();
        print(" MIERCOLES ${DateTime.now().subtract(Duration(days: today.weekday -3)).day}");
        return DateTime.now().subtract(Duration(days: today.weekday -3)).day; //Retorna el miercoles
      case "Jueves":
        DateTime today = DateTime.now();
        return DateTime.now().subtract(Duration(days: today.weekday -4)).day; //Retorna el jueves
      case "Viernes":
        DateTime today = DateTime.now();
        return DateTime.now().subtract(Duration(days: today.weekday -5)).day; //Retorna el viernes
      case "Sabado":
        DateTime today = DateTime.now();
        return DateTime.now().subtract(Duration(days: today.weekday -6)).day; //Retorna el sabado
      case "Domingo":
        DateTime today = DateTime.now();
        return DateTime.now().subtract(Duration(days: today.weekday-7)).day; //Retorna domingo
      default:
        return 0;
    }
  }

  //Retorna la hora de inicio, ya que automaticante se le sumará una hora posteriormente
  int _getHoursxDay(String hour){
    return int.parse(hour.substring(0,2));
  }

  List<Meeting> _getDataSource(List<Meeting>? meetings) {
    List<Meeting> auxMeetings=[];

    //Comprobamos que no traiga nulo
    if(meetings!=null){
      meetings.forEach((element) {
        if(element.getEmailClient == AuthFirebase().currentUser!.email){ //Si tiene la cita con el cliente logueado

          if(!element.getIsApproved){ //Si no ha sido aprobado
            element.setBackground = Color(Colors.deepOrange.value);
          }else{ //Si
            if(element.getIsDone){ //si el meet ya se realizó pintamos de verde
              element.setBackground = Color(Colors.green.value);
            }else{ //Si el meet no se ha llevado a cabo, pintamos de celeste
              element.setBackground = Color(Colors.blue.value);
            }
          }

          auxMeetings.add(element);
        }else{
          element.setBackground = Color(Colors.grey.value);
          element.setEventName = "No disponible";
          auxMeetings.add(element);
        }
      });
    }

    return auxMeetings;
  }
}

