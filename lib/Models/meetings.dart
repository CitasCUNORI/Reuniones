import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Meeting {
  String? _eventName;
  DateTime? _from;
  DateTime? _to;
  Color? _background;
  String? _emailProfessional;
  String? _emailClient;
  bool? _isDone;
  bool? _isApproved;


  Meeting(
      { String? eventName, DateTime? from, DateTime? to, Color? background,
        String? emailProfessional,String? emailClient, bool? isDone, bool? isApproved}
      ){
    _eventName = eventName;
    _from = from;
    _to = to;
    _background = background;
    _emailProfessional = emailProfessional;
    _emailClient = emailClient;
    _isDone = isDone;
    _isApproved = isApproved;
  }

  factory Meeting.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Meeting(
      eventName: data?['eventName'],
      from: data?['from'],
      to: data?['to'],
      emailProfessional: data?['emailProfessional'],
      emailClient: data?['emailClient'],
      isDone: data?['isDone'],
      isApproved: data?['isApproved']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "eventName": _eventName,
      "from": _from,
      "to": _to,
      "emailProfessional": _emailProfessional,
      "emailClient": _emailClient,
      "isDone": _isDone,
      "isApproved": _isApproved
    };
  }

  String get getEmailClient => _emailClient!;

  set setEmailClient(String value) {
    _emailClient = value;
  }

  String get getEmailProfessional => _emailProfessional!;

  set setEmailProfessional(String value) {
    _emailProfessional = value;
  }

  Color get getBackground => _background!;


  bool get getIsDone => _isDone!;

  set setBackground(Color value) {
    _background = value;
  }

  DateTime get getTo => _to!;

  set setTo(DateTime value) {
    _to = value;
  }

  DateTime get getFrom => _from!;

  set from(DateTime value) {
    _from = value;
  }

  String get getEventName => _eventName!;

  set setEventName(String value) {
    _eventName = value;
  }

  set setIsDone(bool value) {
    _isDone = value;
  }

  bool get getIsApproved => _isApproved!;

  set setIsApproved(bool value) {
    _isApproved = value;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index]._from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index]._to;
  }

  @override
  String getSubject(int index) {
    return appointments![index]._eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index]._background;
  }

}