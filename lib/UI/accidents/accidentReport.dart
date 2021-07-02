import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import '../../loginPage.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';

class  AccidentReportView extends StatefulWidget{
   //User infomration for building the view
  final String uid;
  final String code;
  final String email;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  AccidentReportView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _AccidentReportView  createState() => new _AccidentReportView();
}

class _AccidentReportView extends State<AccidentReportView>{

  //Droptdown selectors
  String _selectedLab;
  String _selectedAccident;
  //Student Information
  String _code="";
  String _email="";
  String _uid="";
  String _name;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  //Services
  final AuthService _authS = AuthService();
  dynamic db = FirebaseFirestore.instance;
  final _formkey =  GlobalKey<FormState>();


  @override
  void initState() {
    _uid= widget.uid;
    _code = widget.code;
    _email = widget.email;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    _name = widget.name;
    super.initState();
  }


/*
  * Change listener for the type of laboratorio that is going to be reported
  * */
  onChangeDropDownItemlab(String selectedActual){
    setState(() {
      _selectedLab = selectedActual;
    });
  }

  /*
  * Change listener for the type of accident that is going to be reported
  * */
  onChangeDropDownItemAccident(String selectedActual){
    setState(() {
      _selectedAccident = selectedActual;
    });
  }


  @override
  Widget build(BuildContext context) {

    /*
  * Dialog that verify connection
  * */
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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) =>  AccidentReportView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                  },
                )
              ],
            );
          }
      );
    }

    /**
     * The creation of a new accident on firebase with a notification to confirm
     * */
    Future<void> sendAccident() async{
      db .collection('accidents').doc().set({
        'fecha': DateTime.now(),
        'nombreLab' : _selectedLab,
        'tipoAccidente' : _selectedAccident,
      });
      Navigator.push(context, MaterialPageRoute(builder:  (context) => profileActivity()));
    }

    /**
     * Check the connection status for fetching information
     * */
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
      }
      else if(result == ConnectivityResult.wifi){
        sendAccident();
      }
      if(result == ConnectivityResult.mobile){
        sendAccident();
      }
    }

    /**
     * Sign out functionality
     * */
    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }

    /**
     * Button to send the accident report
     * */
    final buttonReport = Material(
        color: Color(0xff598EA9),
        borderRadius: BorderRadius.circular(25.0),
        child: FlatButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            onPressed: () async {
              if(_formkey.currentState.validate()){
                await _checkInternetConnectivity();
              }
              else{
                showDialog(
                  context: context,
                  builder: (context)=> AlertDialog(
                    title: Text("Error"),
                    content: Text("You must define at least one laboratory"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder:  (context) => AccidentReportView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                        },
                      )
                    ],
                  ),
                );
              }
            },
            child: Text("SEND ", style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );



    Future<bool> onBackPressed(){
       Navigator.push(context, MaterialPageRoute(builder:  (context) => profileActivity()));
    }


    return Scaffold(
      appBar: new AppBar(
        title: new Text('Accident  report'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ),

      drawer: new Drawer(
        child: ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(accountName:  new Text(_name), accountEmail: new Text(_email),
                currentAccountPicture: new CircleAvatar(
                    backgroundImage:  new AssetImage('assets/Login.JPG')
                ) ,
              ),
              CustomDrawerTitle(Icons.home,'  Home',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new  profileActivity()));
              }),
              CustomDrawerTitle(Icons.person,'  Profile',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new profileView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
              }),
              CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ScanView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
              }),
              CustomDrawerTitle(Icons.computer,'  Equipment',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new EquipmentView(_email, _uid , _name, _code,_robustBudget, _nonRobustBudget,_realBudget)));
              }),
              CustomDrawerTitle(Icons.monetization_on,'  Budget',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new BudgetView(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
              }),
              CustomDrawerTitle(Icons.description,'  PES',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget,)));
              }),
              CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
              }),
              CustomDrawerTitle(Icons.exit_to_app,'  Log Out', () {
                _signOut().whenComplete(() {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Login()));
                });
              })
            ]
        ),
      ),
      body: WillPopScope(
        onWillPop: onBackPressed,
        child: Container(
          padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
          child: Form(
            key: _formkey,
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                    height: 50.0,
                    child: new Text('Accident Report', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30.0, color: Color(0xff598EA9),fontWeight: FontWeight.w600 )
                    )
                ),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                  height: 30.0,
                  child:  Text('What type of accident occurs ?', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("accidentType").snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Text("Loading");
                    }
                    else{
                      List<DropdownMenuItem> accidentsItems =[];
                      for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                        DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                        accidentsItems.add(
                            DropdownMenuItem(
                              child: SizedBox(
                                width: 200.0,
                                child: Text(
                                  docSnapshot['type'], overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value:"${docSnapshot['type']}" ,
                            )
                        );
                      }
                      return  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DropdownButton(
                                value: _selectedAccident ,
                                items: accidentsItems,
                                onChanged: (accidentValue){
                                  final snacBar = SnackBar(
                                    content: Text(
                                      'Selected accident value is $accidentValue', overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snacBar);
                                  setState(() {
                                    _selectedAccident = accidentValue;
                                  });
                                }
                            )
                          ],
                        );
                    }
                  },
                ),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                  height: 30.0,
                  child:  Text('Where does the accident occurs ?', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("laboratory").snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Text("Loading");
                    }
                    else{
                      List<DropdownMenuItem> laboratoryItem =[];
                      for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                        DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                        laboratoryItem.add(
                            DropdownMenuItem(
                              child: SizedBox(
                                width: 200.0,
                                child: Text(
                                  docSnapshot['name'], overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value:"${docSnapshot['name']}" ,
                            )
                        );
                      }
                      return  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DropdownButton(
                                value: _selectedLab ,
                                items: laboratoryItem,
                                onChanged: (equipValue){
                                  final snacBar = SnackBar(
                                    content: Text(
                                      'Selected laboratory value is $equipValue', overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snacBar);
                                  setState(() {
                                    _selectedLab = equipValue;
                                  });
                                }
                            )
                          ],
                        );
                    }
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                buttonReport
              ],
            ),
          ),
        ),
      ),
    );
  }
}

