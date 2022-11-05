import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Values/DimensApp.dart';

import '../Common/Routes.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
        child: Scaffold(
          body: Center(child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text("Tipo de cuenta", style: TextStyle(fontSize: titleP, color: Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.account_circle, size: 45),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 15.5,
                          padding: const EdgeInsets.all(15.0)
                      ),
                      label: Text("Cuenta Profesional", style: TextStyle(fontSize: titleButtons, fontWeight: FontWeight.bold)),
                      onPressed: ()=>Navigator.pushNamed(context, ROUTE_REGISTER_PROFESIONAL),
                    )
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person, size: 45),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 15.5,
                          padding: const EdgeInsets.all(15.0)
                      ),
                      label:  Text("Cuenta Cliente", style: TextStyle(fontSize: titleButtons, fontWeight: FontWeight.bold)),
                      onPressed: ()=>Navigator.pushNamed(context, ROUTE_REGISTER_CLIENT),
                    )
                ),
              ),
            ],
          )
          ),
        )
    );
  }
}
