//SERVICES
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
//PAGES
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import '../../loginPage.dart';
import 'monitorAccident.dart';

class  monitorAccidentReport extends StatefulWidget{
  //MONITOR INFORMATION
  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  monitorAccidentReport(this.uid,this.name,this.email,this.laboratory,this.role);

  @override
  _monitorAccidentReport  createState() => new _monitorAccidentReport();
}

class _monitorAccidentReport extends State<monitorAccidentReport>{
//MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  dynamic db = FirebaseFirestore.instance;
  //UTILITIES
  String _selectedAccident;
  final _formkey =  GlobalKey<FormState>();
  dynamic data;

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      _lab = widget.laboratory;
      _email=widget.email;
      _name=widget.name;
      _role=widget.role;
      _uid=widget.uid;
    });
    super.initState();
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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorAccidentReport(_uid, _name, _email, _lab, _role)));
                  },
                )
              ],
            );
          }
      );
    }

    /*
  * Change listener for confirmation of a succesful report
  * */
    _sendDialog(tittle, text){
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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorView()));
                  },
                )
              ],
            );
          }
      );
    }

    /**
     * Sign out functionality
     * */
    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }


    /**
     * The creation of a new accident on firebase with a notification to confirm
     * */
    Future<void> sendAccident() async{
      db.collection('accidents').doc().set({
        'fecha': DateTime.now(),
        'nombreLab' : _lab,
        'tipoAccidente' : _selectedAccident,
      }).then((value) {
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("Accident reported"),
                content: Text(" You have reported the accident"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorView()));
                    },
                  ),
                ],
              );
            }
        );
      });
    }

    /**
     * Check the connection status for fetching information
     * */
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
      }
      else {
        sendAccident();
      }
    }


    /**
     *DIALOG  THAT ASK THE USER IF HE WANTS TO EXIT THE APPLICATION
     */
    Future<bool> onBackPressed(){
      return showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Are you sure ?"),
              content: Text("Returning home view"),
              actions: <Widget>[
                FlatButton(
                  child: Text("YES"),
                  onPressed: (){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new monitorView()));
                  },
                ),
                FlatButton(
                  child: Text("NO"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorAccidentReport(_uid, _name, _email, _lab, _role)));
                  },
                ),
              ],
            );
          }
      );
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
              if(_selectedAccident!=null){
                await _checkInternetConnectivity();
              }
              else{
                showDialog(
                  context: context,
                  builder: (context)=> AlertDialog(
                    title: Text("Error"),
                    content: Text("You must define all spaces"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorAccidentReport(_uid, _name, _email, _lab, _role)));
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


    return Scaffold(
      appBar: new AppBar(
        title: new Text('accident report'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ),
      drawer:  new Drawer(
        child: ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(accountName:  new Text(_name), accountEmail: new Text(_email),
              currentAccountPicture: new CircleAvatar(
                  backgroundImage:  new AssetImage('assets/Login.JPG')
              ) ,
            ),
            CustomDrawerTitle(Icons.home,'  Home',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorView()));
            }),
            CustomDrawerTitle(Icons.error,'  Accidents',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorAccident(_uid, _name, _email, _lab, _role)));
            }),
            CustomDrawerTitle(Icons.attach_money,'  Purchases',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorPurchaseHistory(_uid, _name, _email, _lab, _role)));
            }),
            CustomDrawerTitle(Icons.invert_colors,'  Reagents',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new reagentsUsage(_uid, _name, _email, _lab, _role)));
            }),
            CustomDrawerTitle(Icons.computer,'  Equipment',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorEquipment(_uid, _name, _email, _lab, _role)));
            }),
            CustomDrawerTitle(Icons.exit_to_app,'  Log Out', () {
              _signOut().whenComplete(() {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Login()));
              });
            })
          ],
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
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          style: BorderStyle.solid,
                          width: 5.0
                      )
                  ),
                  child: StreamBuilder<QuerySnapshot>(
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


