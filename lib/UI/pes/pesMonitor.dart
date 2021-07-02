import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/pes/pesMonitorDetail.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class pesMonitorView extends StatefulWidget{

  final uid;
  final laboratory;
  final email;
  final role;
  final name;

  pesMonitorView(this.uid,this.email,this.name,this.role,this.laboratory);
  @override
  _pesMonitorView  createState() => new _pesMonitorView();
}

class _pesMonitorView extends State<pesMonitorView>{
  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  //PES INFORMATION
  String _userName;
  String _status;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  //UTILITIES
  dynamic data;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  //CHECK STATUS OF THE CONNECTION  FOR CHANGE THE VALUE ON THE CONNECTION
  void _checkStatus(){
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.none){
        ChangeValues("Without network connection");
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


  @override
  Widget build(BuildContext context) {

    //SIGN OUT
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('PES  Validation'),
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
              stream: FirebaseFirestore.instance.collection('pes').where('laboratory', isEqualTo: _lab).orderBy('status', descending: true).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot pes = snapshot.data.documents[index];
                     DateTime _actual= DateTime.parse(pes["date"].toDate().toString());
                    _status=pes['status'];
                    _userName=pes['userName'];
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            )),
                        height: 100,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                                alignment: Alignment.center,
                                child: Image.asset('assets/microscopio.png'),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(" ${pes['laboratory']} " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Row(
                                          children: <Widget>[
                                            Text( "${_userName}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,overflow: TextOverflow.ellipsis, ),
                                          ]
                                      ),
                                    ),
                                    Row(
                                        children: <Widget>[
                                          Text("${getDay(_actual)} ${_status}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,overflow: TextOverflow.ellipsis, ),
                                        ]
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.push(context, new
                        MaterialPageRoute(builder:  (context) => new pesMonitorDetail(_uid,_email, _name, _role, _lab,pes['course'],_actual,pes['experiment'],pes['laboratoryEquipment'],pes['laboratoryMaterial'],pes['memberChemicalDepartment'],pes['professor'],pes['status'],pes['userName'],pes.id)));
                      },
                    );},
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

String getDay(DateTime time){
  return " ${time.day}-${time.month}-${time.year} ";
}

