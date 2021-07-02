import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class  purchaseRequest extends StatefulWidget{
  //MONITOR INFORMATION
  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  purchaseRequest(this.uid,this.name,this.email,this.laboratory,this.role);

  @override
  _purchaseRequest  createState() => new _purchaseRequest();
}

class _purchaseRequest extends State<purchaseRequest>{

  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  final db = FirebaseFirestore.instance;
  String _connectivityStatus;
  final _formkey =  GlobalKey<FormState>();
  String _selectedReagent;
  String _provider;


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

  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }

  Future<bool> backHistory(){
    Navigator.push(context, new
    MaterialPageRoute(builder:  (context) => new monitorPurchaseHistory(_uid, _name, _email, _lab, _role)));
  }

  onChangeDropDownItemReagent(String selectedActual){
    setState(() {
      _selectedReagent = selectedActual;
    });
  }



  @override
  Widget build(BuildContext context) {

    //PROVIDER FIELD
    final providerField = TextFormField(
      validator: (_val){
        if(_val.isEmpty){
          return 'Provider name';
        }
        else{
          return null;
        }
      },
      onChanged: (val){
        setState(() => _provider =val);
      },
      autofocus: true,
      keyboardType: TextInputType.emailAddress ,
      style: TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
          hintText: 'Quimicos del nororiente',
          labelText: 'Provider',
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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) =>  purchaseRequest(_uid, _name, _email, _lab, _role)));
                  },
                )
              ],
            );
          }
      );
    }

    Future<void> sendPurchase() async{
      FirebaseFirestore.instance.collection('purcheaches').doc().set({
        'date': DateTime.now(),
        'provider' : _provider,
        'reagent' : _selectedReagent,
      }).then((value) {
           return showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Succesful"),
                  content: Text("The order has been created"),
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
      });
    }

    //CONNECTIO CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
      }
      else{
        sendPurchase();
      }
    }

    Future<bool> onBackPressed(){
      Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorView()));
    }


    final buttonPurchase = Material(
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
                    content: Text("You must define at least one reagent"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder:  (context) => purchaseRequest(_uid, _name , _email, _lab, _role) ));
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

    //MAIN CONSTRUCT OF THE WINDOWN
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Purchase  Request'),
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
                SizedBox(
                  height: 10.0,
                ),
                Container(
                    height: 50.0,
                    child: new Text('Purchase Report', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30.0, color: Color(0xff598EA9),fontWeight: FontWeight.w600 )
                    )
                ),
                SizedBox(
                    height: 10.0,
                ),
                Container(
                  height: 30.0,
                  child:  Text('Reagent is requested ', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
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
                    stream: FirebaseFirestore.instance.collection("reagents").snapshots(),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return Text("Loading");
                      }
                      else{
                        List<DropdownMenuItem> reagentItem =[];
                        for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                          DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                          reagentItem.add(
                              DropdownMenuItem(
                                child: Text(
                                    docSnapshot['name']
                                ),
                                value:"${docSnapshot['name']}" ,
                              )
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DropdownButton(
                                value: _selectedReagent ,
                                items: reagentItem,
                                onChanged: (reagentValue){
                                  final snacBar = SnackBar(
                                    content: Text(
                                      'Selected reagent selected is $reagentValue',
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snacBar);
                                  setState(() {
                                    _selectedReagent = reagentValue;
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
                  height: 10.0,
                ),
                Container(
                  height: 30.0,
                  child:  Text('Name of the provider ', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                SizedBox(
                  height: 5.0,
                ),
                providerField,
                SizedBox(
                  height: 20.0,
                ),
                buttonPurchase
              ],
            ),
          ),
        ),
      ),
    );
  }
}
