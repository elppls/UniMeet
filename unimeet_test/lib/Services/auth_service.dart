import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<bool> signup(String firstname, String lastname, String email,
      String password, String type) async {
    try {
      UserCredential authservice = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? signedInUser = authservice.user;

      if (signedInUser != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(signedInUser.uid)
            .set({
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'profilePicture': '',
          'coverImage': '',
          'bio': '',
          'major': '',
          'token': '',
          'nameHelper': firstname.toLowerCase() + " " + lastname.toLowerCase(),
          'type': type
        });

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }
}
