//SERVICES
import 'package:firebase_auth/firebase_auth.dart';

/**CLASS THAT IS RESPONSIBLE FOR THE AUTHENTICATION SERVICE USING FIREBASE API
**/
class AuthService{

  //INSTANCE OF FIREBASE
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //SIGNIN METHOD
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential user = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User result= user.user;
      if(user.user!=null){

      }
      return result;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    catch(e){
      print(e);
      return null;
    }
  }

  //SIGNUP METHOD
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      return user;
    }on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
    catch(e){
      print(e);
      return null;
    }
  }

  //LOGOUT METHOD
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  //VERIFY IF THERE IS ANY USER LOGGED
  Future<bool> isUserLoggedIn() async{
    User user = await _auth.currentUser;
    return user !=null;
  }

  //CURRENT USER
  Future<User> currentUser() async{
    User user = await _auth.currentUser;
    return user;
  }

}