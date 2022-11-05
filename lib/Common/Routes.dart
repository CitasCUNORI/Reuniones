import 'package:flutter/material.dart';
import '../Pages/home_page.dart';
import '../Pages/login_page.dart';
import '../Pages/register_client_page.dart';
import '../Pages/register_page.dart';
import '../Pages/register_professional_page.dart';
import '../Pages/root_page.dart';

const String ROUTE_HOME="/home";
const String ROUTE_LOGIN="/login ";
const String ROUTE_REGISTER="/register";
const String ROUTE_REGISTER_CLIENT="/registerClient";
const String ROUTE_REGISTER_PROFESIONAL="/registerProfesional";
const String ROUTE_ROOT="/root";



class Routes{
  //Creamos un metodo statico para las rutas
  static Route<dynamic>generateRoute(RouteSettings settings){
    switch(settings.name){ //para obtener el nombre de la ruta
      case "/home":
        return MaterialPageRoute(builder: (_)=>MyHomePage());
      case "/root":
        return MaterialPageRoute(builder: (_)=>RootPage());
      case "/login":
        return MaterialPageRoute(builder: (_)=>LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_)=>RegisterPage());
      case "/registerClient":
        return MaterialPageRoute(builder: (_)=>RegisterClientPage());
      case "/registerProfesional":
        return MaterialPageRoute(builder: (_)=>RegisterProfesionalPage());
      default:
        return MaterialPageRoute(builder: (_)=>LoginPage());
    }
  }//Fin metodo
}//Fin class