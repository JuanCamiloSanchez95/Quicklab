import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class reagentsUsage extends StatefulWidget{
  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  reagentsUsage(this.uid,this.name,this.email,this.laboratory,this.role);
  @override
  _reagentsUsage  createState() => new _reagentsUsage();
}

class _reagentsUsage extends State<reagentsUsage>{

  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  final db = FirebaseFirestore.instance;
  //UTILITIES
  dynamic data;
  ScrollController controller = ScrollController();
  String _connectivityStatus;


  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _uid = widget.uid;
    _email = widget.email;
    _name = widget.name;
    _role=widget.role;
    _lab=widget.laboratory;
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //CHECK THE CONSTANTLY STATUS OF THE PAGE
  void _checkStatus(){
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.none){
        ChangeValues("Lost connection");
      }
      else if(result == ConnectivityResult.wifi){
        ChangeValues("Connected");
      }
      if(result == ConnectivityResult.mobile){
        ChangeValues("Connected");
      }
    });
  }

  //CHANGE  THE VALUE OF THE CONNECTION
  void ChangeValues(String text){
    setState(() {
      _connectivityStatus = text;
    });
  }

  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }

  //ADDS A TEXT LABEL TO SHOW WHEN IT DOES NOT HAVE CONNECTION
  Widget _showConnectio(String text){
    if(text == "Without network connection"){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Text(
            text
        ),
      );
    }else{
      return Container(
        width: 400.0,
        height: 10.0,
        color:  Colors.white,
      );
    }
  }

  Future<bool> _backHome(){
    Navigator.push(context, new
    MaterialPageRoute(builder:  (context) => new monitorView()));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Reagents Usage'),
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
        onWillPop: _backHome,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            Visibility(
              visible: _connectivityStatus=="Without network connection",
              child: _showConnectio(_connectivityStatus),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reagentsUsage').orderBy('name', descending: true).limitToLast(20).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot reagent = snapshot.data.documents[index];
                    return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            )),
                        height: 70,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                                  Column(
                                      children: <Widget>[
                                        Text( "Name" , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold), textAlign: TextAlign.center, ),
                                        Text( "${reagent['name']}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w200), textAlign: TextAlign.center, ),
                                      ]
                                  ),
                                  Column(
                                      children: <Widget>[
                                        Text( "Quantity" , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold), textAlign: TextAlign.center, ),
                                        Text( "${reagent['quantity']}" , style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.w200), textAlign: TextAlign.center, ),
                                      ]
                                  )
                            ],
                          ),
                        ),
                      );
                  }
                );
              },
            ),
            SizedBox(
              height: 25.0,
            ),
          ],
        ),
      ),
    );
  }
}
