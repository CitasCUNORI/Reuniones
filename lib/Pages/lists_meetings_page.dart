import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reuniones/Common/AuthFirebase.dart';
import 'package:reuniones/Common/GeneralsMethods.dart';
import 'package:reuniones/Common/firestore_database.dart';


class PendingMeetingPage extends StatelessWidget with GeneralsMethods{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: Firestore().listMeetingsPendingByProfessional(AuthFirebase().currentUser!.email!),
        builder: (context, snapshot) {
            if(snapshot.hasData){
              if (snapshot.data!.isNotEmpty) {
                return Center(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return designListPendingMeeting(snapshot.data![index]);
                    },
                  ),
                );
              }else{
                return const Center(child: Text("No tiene reuniones pendientes"));
              }
            }
            else{
              return const Center(child: CircularProgressIndicator());
            }
        },
      ),
    );
  }
  
}

class DoneMeetingPage extends StatelessWidget with GeneralsMethods{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: Firestore().listMeetingsDoneByProfessional(AuthFirebase().currentUser!.email!),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            if (snapshot.data!.isNotEmpty) {
              return Center(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return designListDoneMeeting(snapshot.data![index]);
                  },
                ),
              );
            }else{
              return const Center(child: Text("No tiene reuniones completadas"));
            }
          }
          else{
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

}