
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Pages/self_meeting_add_page.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../Common/AuthFirebase.dart';
import '../../../Common/GeneralsMethods.dart';
import '../../../Common/NotificationAPI.dart';
import '../../../Common/firestore_database.dart';
import '../../../Models/meetings.dart';
import '../../../Models/user_profesional.dart';
import '../../../Pages/meeting_add_page.dart';

class AgendaProfessional extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AgendaProfessionalState();
}

class AgendaProfessionalState extends State<AgendaProfessional> with GeneralsMethods {
  CalendarController controlador = CalendarController();
  TimeRegionDetails? timeRegionDetails;

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
                    await Firestore().deleteMeeting(meeting).whenComplete(() {

                      /*Notificaiones al professional*/
                      Firestore().searchUserPByEmail(meeting.getEmailProfessional).then((prof) {

                        NotificationAPI().sendNotification( //Notificaion de cancelación
                          'Reunión cancelada',
                          'Has cancelado una reunion con el usuario ${meeting.getEmailClient}',
                          prof!.getToken!,
                        );

                      });

                      /*Notificaiones al cliente*/
                      Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                        if(client != null){
                          NotificationAPI().sendNotification(
                            'Reunión Cancelada',
                            'El usuario ${meeting.getEmailProfessional} ha cancelado una reunion contigo',
                            client.getToken!,
                          );
                        }
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

                        NotificationAPI().sendNotification( //Notificaion de cancelación
                          'Reunión realizada',
                          'Has marcado una reunion como realizada',
                          prof!.getToken!,
                        );

                      });

                      /*Notificaiones al cliente*/
                      Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                        NotificationAPI().sendNotification(
                          'Reunión Realizada',
                          'El usuario ${meeting.getEmailProfessional} ha marcado como realizada una reunion contigo',
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

  Future _showAprrovedMenu(BuildContext context, Meeting meeting) async{
    return await showDialog(
      context: context,
      builder: (context) {
        return  AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                  onPressed:() async{
                    await Firestore().deleteMeeting(meeting).whenComplete(() {

                      /*Notificaiones al professional*/
                      Firestore().searchUserPByEmail(meeting.getEmailProfessional).then((prof) {

                        NotificationAPI().sendNotification( //Notificaion de cancelación
                          'Reunión rechazada',
                          'Has rechazado la solicitud de ${meeting.getEmailClient}',
                          prof!.getToken!,
                        );

                      });

                      /*Notificaiones al cliente*/
                      Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                        if(client != null){
                          NotificationAPI().sendNotification(
                            'Reunión rechazada',
                            'El profesional ${meeting.getEmailProfessional} ha rechazado tu solicitud',
                            client.getToken!,
                          );
                        }
                      });
                      Navigator.of(context).pop();
                    });
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text("Rechazar solicitud", style: TextStyle(color: Colors.red, fontSize: 17))
              ),
              TextButton.icon(
                  onPressed:() async{
                    meeting.setIsApproved = true;
                    await Firestore().insertMeeting(meeting).whenComplete(() {

                      /*Notificaiones al professional*/
                      Firestore().searchUserPByEmail(meeting.getEmailProfessional).then((prof) {

                        NotificationAPI().sendNotification( //Notificaion de cancelación
                          'Reunión aceptada',
                          'Has aceptado la reunión con ${meeting.getEmailClient}',
                          prof!.getToken!,
                        );

                      });

                      /*Notificaiones al cliente*/
                      Firestore().searchUserCByEmail(meeting.getEmailClient).then((client){

                        NotificationAPI().sendNotification(
                          'Reunión Aceptada',
                          'El usuario ${meeting.getEmailProfessional} ha aceptado tu solicitud de reunion',
                          client!.getToken!,
                        );

                      });
                      Navigator.of(context).pop();
                    });
                  },
                  icon: Icon(Icons.done_outlined,color: Colors.green[700]),
                  label: Text("Aceptar solicitud", style: TextStyle(color: Colors.green[700], fontSize: 17))
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(controlador.selectedDate!=null){ //Combrobación de seleccion
            final inicio = controlador.selectedDate;
            final fin = inicio!.add(const Duration(minutes: 30));
            //Inicializamos el objeto a crear
            final _meeting = Meeting(
              eventName: "",
              from: inicio,
              to: fin,
              emailClient: AuthFirebase().currentUser!.email,
              emailProfessional: AuthFirebase().currentUser!.email,
              isDone: false,
              isApproved: true
            );
            Navigator.push(context, MaterialPageRoute(builder: (builder)=> SelfMeetingAddPage(_meeting)));
          }else{
            message(context, "Debe de seleccionar la casilla de su interés");
          }
        },
        tooltip: 'Registrar auto-cita',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore().getStreamMeeting(AuthFirebase().currentUser!.email!),
        builder: (context, snapshot) {
          return FutureBuilder<UserProfessional?>(
                  future: Firestore().searchUserPByEmail(AuthFirebase().currentUser!.email),
                  builder: (_, AsyncSnapshot<UserProfessional?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: SfCalendar(
                                controller: controlador,
                                dataSource: MeetingDataSource(_getDataSource(snapshot.data!.getMeetings)),
                                firstDayOfWeek: 1,
                                view: CalendarView.workWeek,
                                specialRegions: _getTimeRegions(
                                    snapshot.data!.getWorkDays,
                                    snapshot.data!.getWorkHours),
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  nonWorkingDays:
                                      _getNonWorkingDays(snapshot.data!.getWorkDays),
                                  //filtro de días
                                  timeIntervalHeight: 50,
                                  timeRulerSize: 40,
                                  startHour: 6,
                                  endHour: 21,
                                  dayFormat: 'EEE',
                                  timeFormat: 'jm',
                                  timeInterval: const Duration(minutes: 30),
                                ),
                                monthViewSettings: const MonthViewSettings(
                                  showAgenda: true,
                                ),
                                showDatePickerButton: true,
                                allowedViews: const <CalendarView>[
                                  CalendarView.workWeek,
                                  CalendarView.month,
                                ],

                                onTap: (calendarTapDetails) {
                                  //si ya tiene un evento
                                  if(controlador.selectedDate == null && calendarTapDetails.appointments!.isNotEmpty){
                                    final recurso = calendarTapDetails.appointments!.first as Meeting;
                                    //Comprobamos que la reunion está aprobada por el profesional
                                    if(recurso.getIsApproved){ //Si está aprobada

                                      //Comprobar que no se haya realizado
                                      if(recurso.getIsDone){ //Si ya se realizó
                                        message(context, "No hay acciones para realizar, el evento ha culminado");
                                      }else{ //Si no se ha realizado
                                        _showMenuMeet(context, recurso);
                                      }

                                    }else{
                                      _showAprrovedMenu(context, recurso);
                                    }
                                  }
                                },
                                onLongPress: (calendarLongPressDetails) {
                                  //si ya tiene un evento
                                  if(controlador.selectedDate == null && calendarLongPressDetails.appointments!.isNotEmpty){
                                    final recurso = calendarLongPressDetails.appointments!.first as Meeting;
                                    //Comprobamos que la reunion está aprobada por el profesional
                                    if(recurso.getIsApproved){ //Si está aprobada

                                      //Comprobar que no se haya realizado
                                      if(recurso.getIsDone){ //Si ya se realizó
                                        message(context, "No hay acciones para realizar, el evento ha culminado");
                                      }else{ //Si no se ha realizado
                                        _showMenuMeet(context, recurso);
                                      }

                                    }else{
                                      _showAprrovedMenu(context, recurso);
                                    }
                                  }
                                },
                            )
                          ),
                        ],
                      );
                    }else if(snapshot.hasError){
                      return const Center(child: Text("Ha ocurrido un error"));
                    } else{
                      return const Center (child: CircularProgressIndicator());
                    }
                 }
              );
        }
      ),
    );
  }

  //Recibo un Map de <TimeOfDay, String>
  List<TimeRegion> _getTimeRegions(
      Map<String, bool>? days, Map<String, bool>? hours) {
    final List<TimeRegion> regions = <TimeRegion>[]; //Lista que se retornará

    //Variables que se utilizaran para crear un TimRegion
    DateTime inicio;
    DateTime fin;

    for (MapEntry day in days!.entries) {
      if (day.value != false) {
        //Obtengo los días que si se trabaja

        for (MapEntry hour in hours!.entries) {
          if (hour.value != true) {
            //Obtengo los horarios laborales
            inicio = DateTime(DateTime.now().year, DateTime.now().month,
                _getDay(day.key), _getHoursxDay(hour.key));
            fin = inicio.add(const Duration(hours: 1));

            regions.add(TimeRegion(
              startTime: inicio,
              endTime: fin,
              enablePointerInteraction: false,
              color: Colors.grey.withOpacity(0.5),
              iconData: Icons.block,
              recurrenceRule: 'FREQ=DAILY;INTERVAL=7',
              text: "No disponible",
            ));
          }
        }
      }
    }
    return regions;
  }
  List<Meeting> _getDataSource(List<Meeting>? meetings) {
    List<Meeting> auxMeetings=[];

    //Comprobamos que no traiga nulo
    if(meetings!=null){
      meetings.forEach((element) {

        //Primero comprobamos que la reunión ya se aprobó
        if(element.getIsApproved){
          if(element.getIsDone){
            element.setBackground = Color(Colors.green.value);
          }else{
            element.setBackground = Color(Colors.blue.value);
          }
        }else{
          element.setBackground = Color(Colors.deepOrange.value);
        }


        auxMeetings.add(element);
      });
    }

    return auxMeetings;
  }

  List<int> _getNonWorkingDays(Map<String, bool>? days) {
    List<int> workingdays = [];
    for (MapEntry day in days!.entries) {
      if (day.value != true) {
        //Obtengo los días que NO se trabaja
        switch (day.key) {
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
      } //Fin if
    } //Fin for
    return workingdays;
  }

  //Retorna el primer día de la semana actual, para empezar con las restricciones desde el dia actual
  int _getDay(String date) {
    switch (date) {
      case "Lunes":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 1))
            .day; //Retorna el lunes
      case "Martes":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 2))
            .day; //Retorna el martes
      case "Miercoles":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 3))
            .day; //Retorna el miercoles
      case "Jueves":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 4))
            .day; //Retorna el jueves
      case "Viernes":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 5))
            .day; //Retorna el jueves
      case "Sabado":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 6))
            .day; //Retorna el jueves
      case "Domingo":
        DateTime today = DateTime.now();
        return DateTime.now()
            .subtract(Duration(days: today.weekday - 7))
            .day; //Retorna domingo
      default:
        return 0;
    }
  }

  //Retorna la hora de inicio, ya que automaticante se le sumará una hora posteriormente
  int _getHoursxDay(String hour) {
    return int.parse(hour.substring(0, 2));
  }

  UserProfessional? getUserProfessional() {
    UserProfessional? professional;
    Firestore()
        .searchUserPByEmail(AuthFirebase().currentUser!.email)
        .then((value) => professional = value);
    return professional;
  }
}
