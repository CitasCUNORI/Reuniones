import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/meetings.dart';
import '../Models/user_client.dart';
import '../Models/user_profesional.dart';
import 'AuthFirebase.dart';

class Firestore{
  final db = FirebaseFirestore.instance;
  Stream<QuerySnapshot> usersStreamAssociates = FirebaseFirestore.instance.collection('Clients').snapshots();

  Stream<QuerySnapshot> usersStreamProfessionals = FirebaseFirestore.instance.collection('Professionals').snapshots();

  //Stream<QuerySnapshot> meetingStream = FirebaseFirestore.instance.collection('Meeting').snapshots();

  getStreamMeeting(String emailProfessional){
    Stream<QuerySnapshot> meetingStream = FirebaseFirestore.instance.collection('Professionals').doc(emailProfessional)
        .collection('meetings').snapshots();
    return meetingStream;
  }


  /*CRUD FOR USERS*/
  //Inserta un nuevo elemento si el (uid) no existe, si ya existe lo actualiza
  Future insertUserC(UserClient userClient) async {
    final docRef = db
        .collection("Clients")
        .withConverter(
        fromFirestore: UserClient.fromFirestore,
        toFirestore: (UserClient userClient, options)=> userClient.toFirestore(),
    ).doc(userClient.getEmail);
    await docRef.set(userClient);
  }

  //For UserProfessional
  Future insertUserP(UserProfessional userProfessional) async {
    final docRef = db
        .collection("Professionals")
        .withConverter(
      fromFirestore: UserProfessional.fromFirestore,
      toFirestore: (UserProfessional userProfessional, options)=> userProfessional.toFirestore(),
    ).doc(userProfessional.getEmail);
    await docRef.set(userProfessional);
  }

  //Recibe el email del usuairo cliente(logeado) y el email del nuevo asociado
  Future addAssociate(String? emailClient, String emailProfessional) async {
    final ref = db.collection('Clients').doc(emailClient);
    ref.update(
      {
        'associates':FieldValue.arrayUnion([emailProfessional])
      }
    );
  }

  //Buscar un PROFESIONAL POR EMAIL
  Future<UserProfessional?> searchUserPByEmail (String? email)async{
    List<Meeting> auxMeetings = [];

    final ref = db.collection("Professionals").doc(email).withConverter(
        fromFirestore: UserProfessional.fromFirestore,
        toFirestore: (UserProfessional user, _)=> user.toFirestore()
    );
    final docSnap  = await ref.get();
    final professional = docSnap.data(); //Convertimos a objeto USER

    //Obtenemos la lista de meeting del professional
    final refUsers = db.collection("Professionals").doc(email).collection('meetings');
    await refUsers.get().then((QuerySnapshot snapshot){ //esperar a que termine
      snapshot.docs.forEach((element) {
        Meeting meeting = Meeting(
          eventName: element['eventName'],
          from: element['from'].toDate(),
          to: element['to'].toDate(),
          emailProfessional: element['emailProfessional'],
          emailClient: element['emailClient'],
          isDone: element['isDone'],
          isApproved: element['isApproved']
        );
        auxMeetings.add(meeting);
        professional!.setMeetings = auxMeetings;
      });
    });

    return professional;
  }

  
  //Buscar un CLIENTE POR EMAIL
  Future<UserClient?> searchUserCByEmail (String? email) async{
    UserClient? cliente;

    final ref = db.collection("Clients").doc(email).withConverter(
        fromFirestore: UserClient.fromFirestore,
        toFirestore: (UserClient user, _)=> user.toFirestore()
    );
    final docSnap  = await ref.get();
    cliente = docSnap.data(); //Objeto cliente

    return cliente;
  }

  //Retorna una lista de UserProfessionals (objeto) associados a cada cliente
  Future<List<String>?> listEmails(String? emailClient) async{
    UserClient? cliente;

    final ref = db.collection("Clients").doc(emailClient).withConverter(
        fromFirestore: UserClient.fromFirestore,
        toFirestore: (UserClient user, _)=> user.toFirestore()
    );
    final docSnap  = await ref.get();
    cliente = docSnap.data(); //Objeto cliente

    return cliente!.getAssociates;
  }

  Future<List<UserProfessional>?> listAssociatesByClient(String emailClient) async{
    UserClient? cliente;
    List<UserProfessional> professionals=[];

    //Primero recupero el cliente
    final ref = db.collection("Clients").doc(emailClient).withConverter(
        fromFirestore: UserClient.fromFirestore,
        toFirestore: (UserClient user, _)=> user.toFirestore()
    );
    final docSnap  = await ref.get();
    cliente = docSnap.data(); //Objeto cliente


    //obtenemos todos los professionales inscritos
    final refProfeesionals = db.collection('Professionals');
    await refProfeesionals.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {

        if (cliente!.getAssociates!.contains(element['email'])) {
          UserProfessional user = UserProfessional(
              uid: element['uid'],
              name: element['name'],
              phone: element['phone'],
              email: element['email'],
              token: element['token'],
              workDays: Map<String, bool>.from(element["workDays"]),
              workHours: Map<String, bool>.from(element["workHours"])
          );
          professionals.add(user);
        }
      });
    });
    return professionals;
  }

  Future insertMeeting(Meeting meeting) async {
    final docRef = db
        .collection('Professionals').doc(meeting.getEmailProfessional).collection('meetings')
        .withConverter(
      fromFirestore: Meeting.fromFirestore,
      toFirestore: (Meeting meeting, options)=> meeting.toFirestore(),
    ).doc(
        "${meeting.getFrom}-${meeting.getTo}"
    );
    await docRef.set(meeting);
  }

  Future deleteMeeting(Meeting meeting)async{
    final docRef = db
        .collection('Professionals').doc(meeting.getEmailProfessional).collection('meetings')
        .doc('${meeting.getFrom}-${meeting.getTo}');
    await docRef.delete();
  }

  //Todos los meetings de un professional
  Future<List<Meeting>> listMeetingsByProfessional(String emailProfessional) async{
    List<Meeting> meetings=[];
    final refMeetings = db.collection('Professionals').doc(emailProfessional).collection('meetings');
    await refMeetings.get().then((QuerySnapshot snapshot){ //esperar a que termine
      for (var element in snapshot.docs) {
        Meeting meet = Meeting(
          eventName: element['eventName'],
          from: element['from'].toDate(),
          to: element['to'].toDate(),
          emailProfessional: element['emailProfessional'],
          emailClient: element['emailClient'],
          isDone: element['isDone'],
          isApproved: element['isApproved']
        );
        meetings.add(meet);
      }
    });
    return meetings;
  }

  //Los meetings pendientes de un professional
  Future<List<Meeting>?> listMeetingsPendingByProfessional(String emailProfessional) async{
    List<Meeting> meetings=[];
    final refMeetings = db.collection('Professionals').doc(emailProfessional).collection('meetings');
    await refMeetings.get().then((QuerySnapshot snapshot){ //esperar a que termine
      snapshot.docs.forEach((element) {
        if(!element['isDone']){ //Si el meeting NO ESTÁ REALIZADO
          Meeting meet = Meeting(
              eventName: element['eventName'],
              from: element['from'].toDate(),
              to: element['to'].toDate(),
              emailProfessional: element['emailProfessional'],
              emailClient: element['emailClient'],
              isDone: element['isDone'],
              isApproved: element['isApproved']
          );
          meetings.add(meet);
        }
      });
    });
    return meetings;
  }

  //Los meetings pendientes de un professional
  Future<List<Meeting>?> listMeetingsDoneByProfessional(String emailProfessional) async{
    List<Meeting> meetings=[];
    final refMeetings = db.collection('Professionals').doc(emailProfessional).collection('meetings');
    await refMeetings.get().then((QuerySnapshot snapshot){ //esperar a que termine
      snapshot.docs.forEach((element) {
        if(element['isDone']){ //Si el meeting YA ESTÁ REALIZADO
          Meeting meet = Meeting(
            eventName: element['eventName'],
            from: element['from'].toDate(),
            to: element['to'].toDate(),
            emailProfessional: element['emailProfessional'],
            emailClient: element['emailClient'],
            isDone: element['isDone'],
            isApproved: element['isApproved']
          );
          meetings.add(meet);
        }
      });
    });
    return meetings;
  }

  void updateTokenClient(String emailClient, String token)async{
    final refClient = db.collection('Clients').doc(emailClient);
    await refClient.update({'token':token});
  }

  void updateTokenProfessional(String emailProfessional, String token)async{
    final refProf = db.collection('Professionals').doc(emailProfessional);
    await refProf.update({'token':token});
  }




}