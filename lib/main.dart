import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UI/monitorprofile/monitorprofile.dart';
import 'startpage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  var email = preferences.getString('email');
  var rolActual = preferences.getString('role');
  Widget Actual= verificacionVista(email, rolActual);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(home: Actual
  ));
}

  Widget verificacionVista(String emailActual,String rolActual)  {
  if(emailActual !=null && rolActual=='Student'){
    print("Logged as Student");
    return profileActivity();
  }
  else if(emailActual !=null && rolActual=='Monitor'){
    print("Logged as Monitor");
    return monitorView();
  }
  else{
    print("Not logged yet");
    return startActivity();
  }
}