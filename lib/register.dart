import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/services/database.dart';
//PAGES
import 'package:quicklab/loginPage.dart';
import 'package:quicklab/UI/profile/userModel.dart';
//SERVICES
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UI/pes/PesModel.dart';


/**VIEW RESPONSIBLE OF REGISTERING THE USER IN FIREBASE AUTHENTICATION AND FIRESTORE ALSO USING DEFINED THE FORM USED AND VALIDATIONS TROUGHT ALL THE FORM TO MAKE EASIER THE REGISTRATION PROCESS
USERMODEL THAT IS DEFINDED IN /UI/PROFILE/USERMODEL.DART
**/

class Register extends StatefulWidget{
@override
_RegisterViewState createState() =>_RegisterViewState();
}

class _RegisterViewState extends State<Register> {
  final _formkey =  GlobalKey<FormState>();
  final AuthService _authS = AuthService();
  String _name="";
  String _code="";
  String _email="";
  String _password="";
  String passconfirm="";
  String _labName="";
  TextEditingController _nameController;
  TextEditingController _codeController;
  TextEditingController _emailController;

  List<String> _roles = QuickLabUser.getRoles();
  List<DropdownMenuItem<String>> _dropdownMenyItems;
  String _selected;

  List<Laboratory> _laboratories = Laboratory.getLaboratories();
  List<DropdownMenuItem<Laboratory>> _dropdownMenyItemsLab;
  Laboratory _selectedLab;

  //METHOD THAT SAVED THE INFORMATION OF THE REGISTRATION  IN PREFERENCES
  void setInformatioReg() async{
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        preferences.setString('regname',_name);
        preferences.setString('regcode',_code);
        preferences.setString('regemail',_email);
      });
    }
    catch(e){
      print(e);
    }
  }

  //METHOD THAT ERASE THE INFORMATION OF THE REGISTRATION  IN PREFERENCES
  Future erraseReg()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('regname');
    preferences.remove('regcode');
    preferences.remove('regemail');
  }

@override
  void initState() {
    super.initState();
    _dropdownMenyItems = buildDropDown(_roles);
    _dropdownMenyItemsLab = buildDropDownLab(_laboratories);
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _name = value.getString('regname');
        _code = "" ;
        _email=value.getString('regemail');
        _nameController = new TextEditingController(text: _name);
        _codeController = new TextEditingController(text: _code.toString());
        _emailController = new TextEditingController(text: _email);
      });
    });
  }

//THE DROPDOWN TO SEE THE DIFFERENT ROLES THAT THE APPLICATION COULD HANDLE
  List<DropdownMenuItem<String>> buildDropDown(List roles){
    List<DropdownMenuItem<String>> items = List();
    for(String role in roles ){
      items.add(DropdownMenuItem(
        value: role,
        child: Text(role),
      ));
    }
    return items;
  }

  onChangeDropDownItem(String selectedrole){
    setState(() {
      _selected = selectedrole;
    });
  }

  //THE DROPDOWN TO SEE THE DIFFERENT LABORATORIES THAT THE MONITOR COULD HAVE
  List<DropdownMenuItem<Laboratory>> buildDropDownLab(List labs){
    List<DropdownMenuItem<Laboratory>> items = List();
    for(Laboratory laboratory in labs ){
      items.add(DropdownMenuItem(
        value: laboratory,
        child: Text(laboratory.labName),
      ));
    }
    return items;
  }

  onChangeDropDownItemLab(Laboratory selectedLab){
    setState(() {
      _selectedLab = selectedLab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    //NAME FIELD
    final UsernameField = TextFormField(
      controller: _nameController,
      validator: (_val){
        if(_val.isEmpty){
          return 'Enter a name';
        }
        else{
          return null;
        }
      },
      onChanged: (val){
        setState(() => _name =val);
      },
      autofocus: true,
      keyboardType: TextInputType.emailAddress ,
      style: TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
          hintText: 'Adolf June',
          labelText: 'Name',
          hintStyle: TextStyle(
              color: Colors.grey
          )
      ),
    );

    //CODE FIELD
    final codeField = TextFormField(
      controller: _codeController,
      validator: (_val){
        if(_val.isEmpty){
          return 'Enter a code';
        }
        else if(_val.length < 9 ){
          return 'Not valid code';
        }
        else{
          return null;
        }
      },
      //Update of the value on the text field
      onChanged: (val){
        setState(() => _code == val );
      },
      keyboardType: TextInputType.emailAddress ,
      style: TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
          hintText: '20123495',
          labelText: 'Code',
          hintStyle: TextStyle(
              color: Colors.grey
          )
      ),
    );


    //EMAIL FIELD
    final emailField = Column(
      children: <Widget>[
        TextFormField(
          controller: _emailController,
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
          onChanged: (val){
            setState(() => _email =val);
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
          ),
        ),
      ],
    );

    //PASSWORD FIELD
    final passwordField = TextFormField(
      validator: (_val){
        if(_val.isEmpty){
          return 'Enter a password';
        }
        else if(_val.length < 6 ){
          return 'Not valid code';
        }
        else{
          return null;
        }
      },
      //Update of the value on the text field
      onChanged: (val){
        setState(() => _password =val);
      },
          keyboardType: TextInputType.emailAddress ,
          style: TextStyle(
            color: Colors.black,
          ),
          obscureText: true,
          decoration: InputDecoration(
              hintText: '*******',
              labelText: 'Password',
              hintStyle: TextStyle(
                  color: Colors.grey
              )
          ),
        );

    //PASSWORD CONFIRMATION FIELD
    final passwordConfirm = TextFormField(
      validator: (_val){
        if(_val.isEmpty){
          return 'Enter a password';
        }
        else if( passconfirm != _password ){
          return 'Different from password';
        }
        else{
          return null;
        }
      },
      //Update of the value on the text field
      onChanged: (val){
        setState(() => passconfirm =val);
      },
      keyboardType: TextInputType.emailAddress ,
      style: TextStyle(
        color: Colors.black,
      ),
      obscureText: true,
      decoration: InputDecoration(
          hintText: '******',
          labelText: ' Confirm Password',
          hintStyle: TextStyle(
              color: Colors.grey
          )
      ),
    );

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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => Register()));
                  },
                )
              ],
            );
          }
      );
    }

    //Verify the registration of an user in  the fire base data
    Future<void> signUp() async{
      try{
        //USE FIREBASE TO GET THE USER REGISTRATION
        UserCredential result = await _authS.registerWithEmailAndPassword( _email.toString().trim(), _password);
        User user= result.user;
        //REGISTER IN THE STUDENT DATABASE
        if(_selected == 'Student'){
         await DatabaseService(uid: user.uid).setUserData(_email,_selected);
         await DatabaseService(uid: user.uid).setStudentData(_code.toString(),_email,_name,"",_selected);
        }
        //REGISTER IN THE MONITOR DATABASE
        else if(_selected == 'Monitor') {
          await DatabaseService(uid: user.uid).setWorkerData(_email, _name,_labName);
          await DatabaseService(uid: user.uid).setUserData(_email, _selected);
        }
        //REGISTER IN THE USER DATABASE
        showDialog(
          context: context,
          builder: (context)=> AlertDialog(
            title: Text("SignUp Succesful"),
            content: Text("Now you can login"),
            actions: <Widget>[
              FlatButton(
                child: Text("LOGIN NOW"),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder:  (context) => Login()));
                },
              )
            ],
          ),
        );
      }
      catch(e)
      {
        if(e == "The email address is already in use by another account"){
          print("EMAIL ALREADY USED");
        }
        return null;
      }
    }

    void  _getLabName(){
      dynamic dataL;
      FirebaseFirestore.instance.collection("laboratory").get().then((labsnap) {
        labsnap.docs.forEach((labElement) {
          dataL=labElement.data();
          if(dataL["name"].toString().contains(_selectedLab.labName)){
            setState(() {
              _labName=dataL['name'];
              signUp();
              erraseReg();
            });
          }
        });
      });
    }

    //CONNECTION CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        setInformatioReg();
        _showDialog("No internet", "Try again when connected to a net");
      }
      else {
        print(_selected);
        if(_selected=="Monitor"){
          _getLabName();
        }
        else{
          signUp();
          erraseReg();
        }
      }
    }


    //Registration Button for creating new user
    final Summit = Material(
      color: Color(0xff8abedb),
      borderRadius: BorderRadius.circular(15.0),
      child:MaterialButton(
          highlightColor: Colors.lightBlueAccent,
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
          onPressed: () async{
            if(_formkey.currentState.validate())
            {
              await _checkInternetConnectivity();
            }
          },
          child: Text("Sign Up", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center, )
      ),
    );

    //PADDING WIDGET FOR THE FORM
    final paddinSpace=Padding(
      padding: EdgeInsets.all(12.0),
    );

    return MaterialApp(
      title: 'QuickLab Sign Up',
      theme: ThemeData(primaryColor: Color(0xff598EA9)),
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
          child: Form(
            key: _formkey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0)
                ),
                new Text('Registration', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30.0, color: Color(0xff598EA9),fontWeight: FontWeight.w600 )),
                UsernameField,
                paddinSpace,
                emailField,
                paddinSpace,
                codeField,
                paddinSpace,
                passwordField,
                paddinSpace,
                passwordConfirm,
                paddinSpace,
                Container(
                  height: 30.0,
                  child:  Text('Select your role ', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.center),
                ),
                Container(
                  width: 400,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton(
                        value: _selected,
                        items: _dropdownMenyItems,
                        onChanged: onChangeDropDownItem,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Visibility(
                  visible: _selected== "Monitor",
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 30.0,
                        child:  Text('Laboratory', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.center),
                      ),
                      Container(
                        width: 400,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: <Widget>[
                            DropdownButton(
                              value: _selectedLab,
                              items: _dropdownMenyItemsLab,
                              onChanged: onChangeDropDownItemLab,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                SizedBox(
                  height: 15.0,
                ),
                Summit,
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                    MaterialButton(
                      highlightColor: Colors.blue,
                      padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                      minWidth: mq.size.width/2.5,
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder:  (context) => Login()));
                      },
                      child: Text(
                        'Log In',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


