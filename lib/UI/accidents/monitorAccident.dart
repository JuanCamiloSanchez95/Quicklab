import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';

import '../../loginPage.dart';

class  monitorAccident extends StatefulWidget{
  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  monitorAccident(this.uid,this.name,this.email,this.laboratory,this.role);
  @override
  _monitorAccident  createState() => new _monitorAccident();
}

class _monitorAccident extends State<monitorAccident>{
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


  /**
   * Check the connection status for fetching information
   * */
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

  /**
   * Change the connectivity variable
   * */
  void ChangeValues(String text){
    setState(() {
      _connectivityStatus = text;
    });
  }

  /**
   * Sign out functionality
   * */
  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }

  /**
   * Date format getter
   * */
  String getDay(DateTime time){
    return " ${time.day}-${time.month}-${time.year} ";
  }

  /*
  * Dialog that verify connection
  * */
  Widget _showConnectio(String text){
    if(text == "Lost connection"){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Text(
            " Wait until the connection is stablish again to fecth the data"
        ),
      );
    }else{
      return Text("");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Accidents'),
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
      body: ListView(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: db.collection('accidents').where('nombreLab', isEqualTo: _lab).orderBy("fecha", descending: true).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.vertical,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot accident = snapshot.data.documents[index];
                    DateTime _dateActual = DateTime.parse(accident["fecha"].toDate().toString());
                    return Container(
                      height: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            style: BorderStyle.solid,
                          )),
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:  MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                    children: <Widget>[
                                      Text(" ${accident['nombreLab']} " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                          children: <Widget>[
                                            Text(" Type : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text( accident['tipoAccidente'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                          ]
                                      ),
                                      Row(
                                          children: <Widget>[
                                            Text(" Date : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text( getDay(_dateActual) , style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                          ]
                                      )
                                    ]
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );},
                );
              },
            ),
            SizedBox(
              height: 25.0,
            ),
            _showConnectio(_connectivityStatus)
          ]
      ),
    );
  }
}
