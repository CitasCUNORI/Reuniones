import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

import 'firestore_database.dart';

class NotificationAPI{
  late FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();


  static backgroundHandler(RemoteMessage message)async{
    print("${message.data}");
  }

  void initialseNotifications() async{
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidInitializationSettings);

    notifications.initialize(initializationSettings);


    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      //print("----OnMESAGE-----");
      //print('onMessage: ${message.notification?.title}/${message.notification?.body}');

      AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
          "channelId",
          'channelName',
          importance: Importance.max,
          priority: Priority.high
      );

      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails
      );

      await notifications.show(0, message.notification?.title, message.notification?.body, notificationDetails);


   });



  }

  void sendNotification(String title, String body, String token) async{




    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String>{
          'Content-Type':'application/json',
          'Authorization':'key=AAAArAi1uUU:APA91bFcMVbMdB_VubMI8txU3mh9uGfxFM23GjaymO3X6RBAi89X6Y7l4iOdSVInBEs7W4dEhP_6zuJ3tkN2YSmvij8Cwqh3J6U-igcQ9ZoXr1Z_M9eAS2XFw5rnLj-61gqj_UlKF4EL'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data':<String, dynamic>{
            'status':'done',
            'body': body,
            'title':title,

          },

          "notification":<String, dynamic>{
            "title":title,
            "body": body,
            "channelId":"channelId",
          },
          "to":token,
        })
      );
    }catch(e){
      if(kDebugMode){
        print("error push notification");
      }
    }
  }



  static void requestPermission()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: false
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('User granted permission');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('User granted provessional permission');
    }else {
      print('User declined or has not accepted permission');
    }

  }

  static void getTokenClient(String emailClient)async{
    await FirebaseMessaging.instance.getToken().then((token){
      //Guardar token en la base de datos
      Firestore().updateTokenClient(emailClient, token!);
    });
  }

  static void getTokenProfessional(String emailProfessional)async{
    await FirebaseMessaging.instance.getToken().then((token) {
      //Guardar token en la base de datos
      Firestore().updateTokenProfessional(emailProfessional, token!);
    });
  }




}