//SERVICES
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
//PAGES
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/NonRobustHistory.dart';
import 'package:quicklab/UI/budget/realHistory.dart';
import 'package:quicklab/UI/budget/robustHistory.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import '../../loginPage.dart';

class  BudgetView extends StatefulWidget{

  //Student Information
  final String email;
  final String code;
  final String uid;
  final String name;
  final String robust;
  final String noRobust;
  final String real;
  BudgetView(this.email, this.uid, this.name, this.code, this.robust,this.noRobust,this.real);

  @override
  _BudgetView  createState() => new _BudgetView();
}

class _BudgetView extends State<BudgetView>{

  //Student Information
  String _email;
  String _uid;
  String _name;
  String _code;
  String _robust;
  String _noRobust;
  String _real;
  //Firebase Services
  final db = FirebaseFirestore.instance;
  final AuthService _authS = AuthService();


  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }

  @override
  void initState() {
    _email = widget.email;
    _name = widget.name;
    _uid = widget.uid;
    _code = widget.code;
    _robust= widget.robust;
    _noRobust = widget.noRobust;
    _real = widget.real;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Budget View'),
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
                MaterialPageRoute(builder:  (context) => new profileView(_email, _uid , _name, _code , _robust, _noRobust, _real)));
              }),
              CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ScanView(_email, _uid , _name, _code , _robust, _noRobust, _real)));
              }),
              CustomDrawerTitle(Icons.computer,'  Equipment',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new EquipmentView(_email, _uid , _name, _code,_robust, _noRobust,_real)));
              }),
              CustomDrawerTitle(Icons.monetization_on,'  Budget',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new BudgetView(_email, _uid, _name, _code, _robust, _noRobust,_real)));
              }),
              CustomDrawerTitle(Icons.description,'  PES',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid , _name, _code , _robust, _noRobust, _real)));
              }),
              CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid, _name, _code, _robust, _noRobust,_real)));
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
      body:Stack(
          children: <Widget> [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 300.0,
                  height: 250.0,
                  color: Color(0xff8abedb)
                )
              ],
            ),
            Positioned(
              top: 25,
              left: 50,
              right: 50,
              child: InkWell(
                splashColor: Color(0xff598EA9),
                onTap: (){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new nonRobustHistory(_email, _uid, _name, _code, _robust, _noRobust, _real)));
                },
                child: Container(
                  height: 70.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.8),
                        style: BorderStyle.solid,
                      )
                  ),
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(" Non-Robust budget" ,style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(" Available " ,style: TextStyle( fontSize: 15.0, color:  Colors.grey)),
                            StreamBuilder(
                                stream: db.collection('studentsBudget').where('email', isEqualTo: _email).where('type',isEqualTo: 'nonRobust').snapshots(),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData) return Text("Loading Budget");
                                  DocumentSnapshot budgetNonRobust = snapshot.data.documents[0];
                                  return Text(" \$ ${budgetNonRobust['available']}"  , style: TextStyle( fontSize: 15.0, color: Colors.blueAccent), textAlign: TextAlign.center);
                                }
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('>')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 105,
              left: 50,
              right: 50,
              child: InkWell(
                splashColor: Color(0xff598EA9),
                onTap: (){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new robustHistory(_email, _uid, _name, _code, _robust, _noRobust, _real)));
                },
                child: Container(
                  height: 70.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.8),
                        style: BorderStyle.solid,
                      )
                  ),
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(" Robust budget" ,style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(" Available " ,style: TextStyle( fontSize: 15.0, color:  Colors.grey)),
                            StreamBuilder(
                                stream: db.collection('studentsBudget').where('email', isEqualTo: _email).where('type',isEqualTo: 'robust').snapshots(),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData) return Text("Loading Budget");
                                  DocumentSnapshot budgetRobust = snapshot.data.documents[0];
                                  return Text(" \$ ${budgetRobust['available']}"  , style: TextStyle( fontSize: 15.0, color: Colors.blueAccent), textAlign: TextAlign.center);
                                }
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('>')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 185,
              left: 50,
              right: 50,
              child: InkWell(
                splashColor: Color(0xff598EA9),
                onTap: (){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new realHistory(_email, _uid, _name, _code, _robust, _noRobust, _real)));
                },
                child: Container(
                  height: 70.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.8),
                        style: BorderStyle.solid,
                      )
                  ),
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(" Real budget" ,style: TextStyle( fontSize: 20.0, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(" Available " ,style: TextStyle( fontSize: 15.0, color:  Colors.grey)),
                            StreamBuilder(
                                stream: db.collection('studentsBudget').where('email', isEqualTo: _email).where('type',isEqualTo: 'real').snapshots(),
                                builder: (context, snapshot){
                                  if(!snapshot.hasData) return Text("Loading Budget");
                                  DocumentSnapshot budgetReal = snapshot.data.documents[0];
                                  return Text(" \$ ${budgetReal['available']}"  , style: TextStyle( fontSize: 15.0, color: Colors.blueAccent), textAlign: TextAlign.center);
                                }
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('>')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //TODO GRAFICO BUDGET
          ]),
    );
  }
}
