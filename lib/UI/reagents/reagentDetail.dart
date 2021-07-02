import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class  ReagentDetailView extends StatefulWidget{

  final String email;
  final String code;
  final String uid;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;

  //REAGENT INFORMATION
  final String availability;
  final int cost;
  final String description;
  final String formula;
  final String nameReagent;
  final String safety;
  final String units;
  final Color colorA;


  ReagentDetailView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget, this.availability,this.cost, this.description,this.formula,this.nameReagent,this.safety,this.units,this.colorA);


  @override
  _ReagentDetailView  createState() => new _ReagentDetailView();
}

class _ReagentDetailView extends State<ReagentDetailView>{


  dynamic data;
  final db = FirebaseFirestore.instance;
  final AuthService _authS = AuthService();
  String _email;
  String _name;
  String _uid;
  String _code;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  String _available;
  int _cost;
  String _description;
  String _formula;
  String _nameReagent;
  String _safety;
  String _units;
  Color _colorA;


  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _email = widget.email;
    _name = widget.name;
    _uid = widget.uid;
    _code = widget.code;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    _available =widget.availability;
     _cost = widget.cost;
     _description = widget.description;
     _formula = widget.formula;
     _nameReagent = widget.nameReagent;
     _safety = widget.safety;
     _units = widget.units;
     _colorA = widget.colorA;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }


    Widget _loader(BuildContext context, String url){
      return  Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget _error(BuildContext context, String url, dynamic error){
      print(error);
      return  Center(
        child: Icon(Icons.error_outline),
      );
    }


    return Scaffold(
      appBar: new AppBar(
        title: new Text('Reagent Detail'),
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
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
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
                Padding(
                  padding: EdgeInsets.fromLTRB(1.0, 50.0, 1.0, 1.0),
                  child: Container(
                    height: 200.0,
                    width: 200.0,
                  child: Image(
                    image: AssetImage("assets/labGirl.png"),
                    fit: BoxFit.fill,
                   )
                  ),
                ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _available, style: TextStyle(color: _colorA, fontSize: 10.0),
                      )
                    ],
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _nameReagent, style: TextStyle(color: Colors.grey, fontSize: 30.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "\$ ${_cost.toString()} / ${_units}", style: TextStyle(color: Color(0xff598EA9), fontSize: 18.0, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          " ${_safety} ", style: TextStyle(color: Colors.grey, fontSize: 10.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          " ${_formula} ", style: TextStyle(color: Colors.blueGrey, fontSize: 12.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          " Description ", style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10.0,0.0,10.0,0.0),
                    child: Text(_description, style: TextStyle(fontSize: 12.0,color: Colors.grey), textAlign: TextAlign.justify,),
                  ),
                ]
              ),
            )
          ]
      ),
    );
  }
}
