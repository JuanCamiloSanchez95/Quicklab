import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/loginPage.dart';


class CurrentUser extends ChangeNotifier{
  String _uid;
  String _email;

  String get getUid => _uid;
  String get getEmail=> _email;

  final AuthService _authS = AuthService();

  Future<String> onStartUp() async{
    String retVal= "error";
    try{
      User _fireBaseuser = _authS.currentUser() as User;
      _uid = _fireBaseuser.uid;
      _email=_fireBaseuser.email;
      retVal= "success";
    }catch(e){
      print(e);
    }
    return retVal;
  }

  Future<bool> signUpUser(String email, String password) async{
    bool retVal=false;
    if(!email.isEmpty){
      retVal=true;
    }
    return retVal;
  }

  Future<bool> logInUser(String email, String uid)async{
    bool retVal = false;
    if(!uid.isEmpty){
      _uid =uid;
      _email=email;
      retVal=true;
    }
    return retVal;
  }


}