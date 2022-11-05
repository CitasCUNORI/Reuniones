import 'package:flutter/material.dart';

typedef VoidCallbackParam(int index);

class MenuBarProfessionals extends StatelessWidget{
  VoidCallbackParam voidCallbackParam;
  int currentIndex;

  MenuBarProfessionals(this.voidCallbackParam, this.currentIndex);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: voidCallbackParam,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil"
        ),

        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Agenda"
        ),

        BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Configuración"
        ),

      ],
      type: BottomNavigationBarType.shifting,
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.blueGrey,
      selectedItemColor: Colors.lightBlue,

    );
  }

}