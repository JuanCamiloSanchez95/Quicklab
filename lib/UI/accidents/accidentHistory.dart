//SERVICES
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
//PAGES
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/accidents/accidentReport.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import '../../loginPage.dart';

class  accidentView extends StatefulWidget{

  //User infomration for building the view
  final String uid;
  final String code;
  final String email;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  accidentView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);
  @override
  _accidentView  createState() => new _accidentView();
}

class _accidentView extends State<accidentView>{

  //User information
  String _code="";
  String _email="";
  String _uid="";
  String _name;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  //Utilities
  DateTime _dateActual;
  String _connectivityStatus;
  final AuthService _authS = AuthService();



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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Accident  History'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,

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
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
              }),
              CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
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
      body: ListView(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            _buttonAccidentReport(context, _email,_uid,_name,_code,_robustBudget,_nonRobustBudget,_realBudget),
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('accidents').snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot accident = snapshot.data.documents[index];
                    _dateActual = DateTime.parse(accident["fecha"].toDate().toString());
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
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child:  Text(" Accident: " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                      children: <Widget>[
                                        Text(" Laboratory : " , style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text( accident['nombreLab'], style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                      ]
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
                                ],
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

/**
 * Get the correct format to present the information on the view
 * */
String getDay(DateTime time){
  return " ${time.day}-${time.month}-${time.year} ";
}

/**
 * Add the text label if the connection is lost
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

/**
 * Button to send the accident report
 * */
Widget _buttonAccidentReport( dynamic context, String email, String uid,String name, String code,String robustBudget, String nonRobustBudget, String realBudget  ) {
  return Material(
      color: Color(0xff598EA9),
      borderRadius: BorderRadius.circular(25.0),
      child: FlatButton(
          highlightColor: Colors.blue,
          padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
          onPressed: () async {
            Navigator.push(context, new
            MaterialPageRoute(builder:  (context) => new AccidentReportView(email, uid , name, code , robustBudget, nonRobustBudget, realBudget)));
          },
          child: Text("Report new Accident ", style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,)
      )
  );
}