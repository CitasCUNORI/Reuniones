import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFirebase{
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  GoogleSignIn googleSignIn = GoogleSignIn();


  //Iniciar sesión por correo y contraseña
  Future sigIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch (e){
      return e;
    }
  }

  //Crear cuenta por correo y contraseña
  Future signUp(String email, String password) async {
    try{

      await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      currentUser!.sendEmailVerification();

    } on FirebaseAuthException catch (e) {
      return e;
    }
  }

  //Cerrar sesión (void porque no retorna nada)
  Future<void> signOut() async {
    firebaseAuth.signOut();
    googleSignIn.disconnect();
  }

  //Iniciar sesión por google
  Future signinWithGoogle(BuildContext context, bool isLogin) async{
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
    );
     try{
        // Getting users credential
        UserCredential result = await firebaseAuth.signInWithCredential(authCredential);
        if(result.additionalUserInfo!.isNewUser && isLogin){
          currentUser!.delete();
          signOut();
          return 'user-doesnt-exist';
        }

      }on FirebaseAuthException catch(e){
        return e;
      }
  }

  //Recuperar contraseña
  Future resetPassword(String email) async{
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

}
