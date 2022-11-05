import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/NotificationAPI.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'Common/Routes.dart';
import 'Pages/root_page.dart';
//import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void>_firebaseMessaginBackgroundHandler(RemoteMessage message)async{
  //print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    //requestPermission
    NotificationAPI.requestPermission();
    //initInfo
    NotificationAPI().initialseNotifications();

  }


  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        //Para el idioma del calendario

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          SfGlobalLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('es'),
          // ... other locales the app supports
        ],
        locale: const Locale('es'),

        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: Routes.generateRoute,
        home: RootPage(), //RootPage
      ),
    );
  }


}

