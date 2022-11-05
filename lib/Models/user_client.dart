import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reuniones/Models/user_profesional.dart';

class UserClient{
  String? _name;
  String? _uid;
  String? _phone;
  String? _email;
  String? _token;
  List<String>? _associates;


  UserClient ({String? name, String? uid, String? phone, String? email,String? token, List<String>? associates}){
    _name = name;
    _uid = uid;
    _phone = phone;
    _email = email;
    _token = token;
    _associates = associates;
  }

  String? get getEmail => _email;

  String? get getPhone => _phone;

  String? get getUid => _uid;

  String? get getName => _name;

  String? get getToken => _token;

  List<String>? get getAssociates => _associates;




  factory UserClient.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options){
    final data = snapshot.data();

    return UserClient(
      name: data?['name'],
      uid: data?['uid'],
      phone: data?['phone'],
      email: data?['email'],
      token: data?['token'],
      associates: data?['associates'] is Iterable? List.from(data?['associates']):null
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": _name,
      "uid": _uid,
      "phone": _phone,
      "email": _email,
      "token": _token,
      if(_associates!=null) "associates": _associates
    };
  }

  set uid(String value) {
    _uid = value;
  }

  set phone(String value) {
    _phone = value;
  }

  set email(String value) {
    _email = value;
  }

  set associates(List<String> value) {
    _associates = value;
  }

  set name(String value) {
    _name = value;
  }

  set token(String value) {
    _token = value;
  }

}



