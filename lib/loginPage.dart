import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//PAGES
import 'package:quicklab/register.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UI/monitorprofile/monitorprofile.dart';
import 'startpage.dart';
//SERVICES
import 'package:quicklab/UI/services/authentication.dart';

//CREATE THE LOGIN STATE
class Login extends StatefulWidget{
  @override
  _LoginViewState createState() =>_LoginViewState();
}

//RESPONSIBLE OF CREATING THE WIGDET
class _LoginViewState extends State<Login> with TickerProviderStateMixin {

  //AUTHENTICACION SERVICE
  final AuthService _authS = AuthService();
  //KEY FOR VALIDATING THE FORM
  final formkey =  GlobalKey<FormState>();
  //CONTROLLERS FOR THE TEXT FIELDS
  final email_Controller = TextEditingController();
  final password_controller = TextEditingController();
  //VARIABLES FOR SAVING INFORMATION
  String email='';
  String password='';
  String rol='';
  String code;
  String userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final db = FirebaseFirestore.instance;
    dynamic data;

    //SIGN IN FUNCTION
    Future<void> signIn() async {
      try{
        SharedPreferences preferences = await SharedPreferences.getInstance();
        User result = await _authS.signInWithEmailAndPassword(email.toString().trim(), password);
        if(result!=null){
          //SHARED PREFERENCE UID
          preferences.setString('uid', result.uid);
          //SHARED PREFERENCE EMAIL
          preferences.setString('email', email_Controller.text);
          db.collection('users').doc(result.uid).get().then((DocumentSnapshot snapshot) {
            setState(() {
              data=snapshot.data();
              rol = data['role'];
              //SHARED PREFERENCE ROLE
              preferences.setString('role', rol);
              //ROLE VERIFICATION FOR NAVIGATION ROUTE
              if(rol=="Student"){
                dynamic dataM;
                db.collection("students").where("email", isEqualTo: email).get().then((snap) {
                  snap.docs.forEach((element) {
                    dataM= element.data();
                    setState(() {
                      //SHARED PREFERENCE CODE
                        code= dataM["code"].toString();
                        print("Inserte codigo ${code}");
                        preferences.setString('code', code.toString());
                        //SHARED PREFERENCE USERNAME
                        userName = dataM['name'];
                        preferences.setString('name', userName);
                    });
                  });
                  Navigator.push(context, MaterialPageRoute(builder:  (context) => profileActivity()));
                });
              }
              if(rol=="Monitor"){
                String lab='';
                dynamic dataM;
                dynamic dataL;
                db.collection("workers").where("email", isEqualTo: email).get().then((snap) {
                  snap.docs.forEach((element) {
                    dataM= element.data();
                    setState(() {
                      lab= dataM['laboratory'];
                      //CONSIGUIENDO EL LAB DEL ARCHIVO
                      db.collection("laboratory").get().then((labsnap) {
                        labsnap.docs.forEach((labElement) {
                          dataL=labElement.data();
                          if(dataL["name"].toString().contains(lab)){
                            setState(() {
                              print(dataL['name']);
                              lab=dataL['name'];
                              userName = dataM['name'];
                              preferences.setString('name', userName);
                              preferences.setString('lab', lab);
                            });
                          }
                        });
                        Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorView()));
                      });
                    });
                  });
                });
              }
            });
          });
        }
      }
      catch(e){
        //DIALOG OF VALIDATION
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context)=> AlertDialog(
              title: Text("SignIn Error"),
              content: Text("Try it again?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Yes"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => Login()));
                  },
                ),
                FlatButton(
                  child: Text("No"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => startActivity()));
                  },
                )
              ],
            ));
      }
    }

    //DIALOG FOR INTERNET SECURE
    _showDialog(tittle, text){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(tittle),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => Login()));
                  },
                )
              ],
            );
          }
      );
    }


    //CONNECTION CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
          _showDialog("No internet", "Try again when connected to a net");
      }
      else if(result == ConnectivityResult.wifi){
        signIn();
      }
      if(result == ConnectivityResult.mobile){
        signIn();
      }
    }

    // LOG IN BUTTON
    final LoginButton = Material(
        color: Color(0xff8abedb),
        child: MaterialButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            minWidth: mq.size.width / 2.5,
            onPressed: () async {
              try{
                if(formkey.currentState.validate())
                {
                   _checkInternetConnectivity();
                }
              }
              catch(e)
              {
                if (e == 'user-not-found') {
                  print('No user found for that email.');
                }
                else if (e == 'wrong-password') {
                  print('The password provided is incorrect for the user.');
                }
              }
            },
            child: Text("LOGIN", style: const
            TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),
              textAlign: TextAlign.center
            )
        )
    );

    //REGISTER A NEW USER BUTTON
    final RegisterButton = Material(
        color: Color(0xff8abedb),
        child: MaterialButton(
            highlightColor: Colors.white,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            minWidth: mq.size.width / 2.5,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Register()));
            },
            child: Text("REGISTER", style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );

    //EMAIL FIELD
    final emailField = Column(
      children: <Widget>[
        TextFormField(
          controller: email_Controller,
          //Validation of empty space
          validator: (_val){
            if(_val.isEmpty){
              return 'Enter an email';
            }
            else if(!_val.contains("@")){
              return 'Incorrect email format';
            }
            else if(!_val.contains("uniandes.edu.co")){
              return 'Not valid email';
            }
            else{
              return null;
            }
          },
          //Update of the value on the text field
          onChanged: (val){
            setState(() => email =val);
          },
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
              hintText: 'email@uniandes.edu.co',
              labelText: 'Email',
              hintStyle: TextStyle(
                  color: Colors.grey
              ),
            prefixIcon: Icon(
              Icons.person,
              color: Colors.black,
              size: 35.0,
            ),
          ),
        ),
      ],
    );

    //PASSOWRD FIELD AND LOGIN BUTTON
    final passwordField = Column(
      children: <Widget>[
        TextFormField(
          controller: password_controller,
          validator: (_val){
            if(_val.isEmpty ||  _val.length<6){
              return 'Enter a validate password';
            }
            else if(_val.length<6){
              return 'Password is to short';
            }
            else{
              return null;
            }
          },
          onChanged: (val){
            setState(() => password =val);
          },
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.black,
          ),
          obscureText: true,
          decoration: InputDecoration(
              hintText: 'password',
              labelText: 'Password',
              hintStyle: TextStyle(
                  color: Colors.grey
              ),
            prefixIcon: Icon(
              Icons.lock,
              color: Colors.black,
              size: 35.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
        ),
        LoginButton
      ],
    );

    //UI DESIGN
    return MaterialApp(
      title: 'QuickLab Log In',
      theme: ThemeData(primaryColor: Color(0xff598EA9)),
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
          child: Form(
            key: formkey,
            child: ListView(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 30.0, 0.0),
                  height: 250.0,
                  child: new CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/Login.JPG')
                  )),
                new Text('LOG IN', textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 50.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w600
                    )),
                emailField,
                passwordField,
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RegisterButton,
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








