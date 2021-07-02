import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/purchaseRequest.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';

import '../../loginPage.dart';

class  monitorPurchaseHistory extends StatefulWidget{
  //MONITOR INFORMATION
  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  monitorPurchaseHistory(this.uid,this.name,this.email,this.laboratory,this.role);

  @override
  _monitorPurchaseHistory  createState() => new _monitorPurchaseHistory();
}

class _monitorPurchaseHistory extends State<monitorPurchaseHistory>{

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
  ScrollController controller = ScrollController();

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
    _checkStatus();
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


  Future<bool> backHome(){
    Navigator.push(context, new
    MaterialPageRoute(builder:  (context) => new monitorView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Purcheases history'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
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
          onWillPop: backHome,
          child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                _buttonPurchase(context, _email, _uid, _name, _lab, _role),
                SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('purcheaches').orderBy('date',descending: true).limit(10).snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                    return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      controller: controller,
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        DocumentSnapshot purchases = snapshot.data.documents[index];
                        DateTime _dateActual = DateTime.parse(purchases["date"].toDate().toString());
                        return Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(right: 2.0, left: 2.0),
                                      child:  Text(" Purchase : " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text( purchases['provider'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, overflow: TextOverflow.visible ),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text( purchases['reagent'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, overflow: TextOverflow.visible),
                                                ]
                                            ),
                                            Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text( getDay(_dateActual) , style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, overflow: TextOverflow.visible),
                                                ]
                                            )
                                          ],
                                        ),
                                    ),

                                  ],
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
        )
    );
  }


  Widget _buttonPurchase( dynamic context, String email, String uid,String name, String lab, String role ) {
    return Material(
        color: Color(0xff598EA9),
        borderRadius: BorderRadius.circular(25.0),
        child: FlatButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            onPressed: () async {
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new purchaseRequest(_uid, _name, _email, _lab, _role)));
            },
            child: Text("New Purchase ", style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );
  }

  String getDay(DateTime time){
    return "${time.day}-${time.month}-${time.year} ";
  }

  //ADDS A TEXT LABEL TO SHOW WHEN IT DOES NOT HAVE CONNECTION
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
}
