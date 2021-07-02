import 'package:shared_preferences/shared_preferences.dart';

Future logOut()async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove('email');
  preferences.remove('uid');
  preferences.remove('role');
  preferences.remove('name');
  preferences.remove('code');
}