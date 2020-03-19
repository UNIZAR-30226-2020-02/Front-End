import 'package:playstack/models/user.dart';

import 'database.dart';

class AuthService {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  /*
  // create user obj based on firebase user
  User _userFromPostgresUser(Postgres user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        //.map((FirebaseUser user) => _userFromPostgresUser(user));
        .map(_userFromPostgresUser);
  }

  // sign in with email and password
  Future signInWithEmail(String _email, String _password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      FirebaseUser user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String userName) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      // create a new document for the user with the uid
      await DatabaseService(uid: user.uid).updateUserData(userName);
      return _userFromPostgresUser(user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
  */
}
