import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'meetings.dart';


class UserProfessional {
  String? _name;
  String? _uid;
  String? _phone;
  String? _email;
  String? _token;
  Map<String, bool>? _workDays;
  Map<String, bool>? _workHours;
  List<Meeting>? _meetings;


  UserProfessional(
      {String? name, String? uid, String? phone, String? email, String? token,
        Map<String, bool>? workDays, Map<String, bool>? workHours,
        List<Meeting>? meetings}) {
    _name = name;
    _uid = uid;
    _phone = phone;
    _email = email;
    _token= token;
    _workDays = workDays;
    _workHours = workHours;
    _meetings = meetings;
  }

  String? get getEmail => _email;

  String? get getPhone => _phone;

  String? get getUid => _uid;

  String? get getName => _name;

  String? get getToken => _token;

  Map<String, bool>? get getWorkDays => _workDays;

  Map<String, bool>? get getWorkHours => _workHours;

  List<Meeting>? get getMeetings => _meetings;

  set setEmail(String value) {
    _email = value;
  }

  set setPhone(String value) {
    _phone = value;
  }

  set setUid(String value) {
    _uid = value;
  }

  set setName(String value) {
    _name = value;
  }

  set token(String value) {
    _token = value;
  }

  set setWorkDays(Map<String, bool>? value) {
    _workDays = value;
  }
  set setWorkHours(Map<String, bool>? value) {
    _workHours = value;
  }

  set setMeetings(List<Meeting> value) {
    _meetings = value;
  }

  factory UserProfessional.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options){
    final data = snapshot.data();

    return UserProfessional(
      uid: data?['uid'],
      name: data?['name'],
      phone: data?['phone'],
      email: data?['email'],
      token: data?['token'],
      workDays: Map<String, bool>.from(data?["workDays"]),
      workHours: Map<String, bool>.from(data?["workHours"]),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": _name,
      "uid": _uid,
      "phone": _phone,
      "email": _email,
      "token": _token,
      "workDays": _workDays,
      "workHours": _workHours
    };
  }
}