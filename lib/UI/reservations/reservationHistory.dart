import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/reservations/reservation.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';


class  ReservationHistoryView extends StatefulWidget{
  final String uid;
  final String code;
  final String email;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  ReservationHistoryView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _ReservationHistoryView  createState() => new _ReservationHistoryView();
}

class _ReservationHistoryView extends State<ReservationHistoryView>{
  String _idUsuario;
  String _code;
  String _email;

  final AuthService _authS = AuthService();
  String _name;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  DateTime _dateActual;
  String _connectivityStatus;
  ScrollController controller = ScrollController();




  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _code=widget.code;
    _idUsuario = widget.uid;
    _email = widget.email;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    _name = widget.name;
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

  Future<bool> _backhome(){
    Navigator.push(context, new
    MaterialPageRoute(builder:  (context) => new  profileActivity()));
  }


  final CollectionReference reservationCollection = FirebaseFirestore.instance.collection('Reservation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Reservations history '),
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
                  MaterialPageRoute(builder:  (context) => new profileView(_email, _idUsuario , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                }),
                CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new ScanView(_email, _idUsuario , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                }),
                CustomDrawerTitle(Icons.computer,'  Equipment',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new EquipmentView(_email, _idUsuario , _name, _code,_robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.monetization_on,'  Budget',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new BudgetView(_email, _idUsuario, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.description,'  PES',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new pesHistory(_email, _idUsuario, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _idUsuario, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
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
        onWillPop: _backhome,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            _buttonReser(context, _email,_idUsuario,_name,_code,_robustBudget,_nonRobustBudget,_realBudget),
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reservations').where('studentCode', isEqualTo: _code).where('date', isGreaterThanOrEqualTo: DateTime.now()).orderBy("date", descending: false ).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot reservation = snapshot.data.documents[index];
                    _dateActual = DateTime.parse(reservation["date"].toDate().toString());
                    return Card(
                          child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(" Reservation : " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(child: Text( " ${reservation['labName']}", style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis )),
                                          ]
                                      ),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(" Course : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text( reservation['course'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                          ]
                                      ),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(" Date : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text( getDay(_dateActual) , style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                          ]
                                      )
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
}

String getDay(DateTime time){
  return " ${time.day}-${time.month}-${time.year} ";
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

Widget _buttonReser( dynamic context, String email, String uid,String name, String code,String robustBudget, String nonRobustBudget, String realBudget  ) {
  return Material(
      color: Color(0xff598EA9),
      borderRadius: BorderRadius.circular(25.0),
      child: FlatButton(
          highlightColor: Colors.blue,
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
          onPressed: () async {
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new ReservationView(email, uid , name, code , robustBudget, nonRobustBudget, realBudget)));
          },
          child: Text("Send New Reservation ", style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,)
      )
  );
}


