import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
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

import '../../loginPage.dart';

class  robustHistory extends StatefulWidget{
  final String email;
  final String code;
  final String uid;
  final String name;
  final String robust;
  final String noRobust;
  final String real;
  robustHistory(this.email, this.uid, this.name, this.code, this.robust,this.noRobust,this.real);

  @override
  _robustHistory  createState() => new _robustHistory();
}

class _robustHistory extends State<robustHistory>{
  //STUDENT INFORMATION
  String _email;
  String _uid;
  String _name;
  String _code;
  String _robustBudget;
  String _noRobustBudget;
  String _realBugdet;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  //UTILITIES
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
    _name = widget.name;
    _uid = widget.uid;
    _email = widget.email;
    _robustBudget = widget.robust;
    _noRobustBudget = widget.noRobust;
    _realBugdet = widget.real;
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Robust  history'),
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
                MaterialPageRoute(builder:  (context) => new profileView(_email, _uid , _name, _code , _robustBudget, _noRobustBudget, _realBugdet)));
              }),
              CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ScanView(_email, _uid , _name, _code , _robustBudget, _noRobustBudget, _realBugdet)));
              }),
              CustomDrawerTitle(Icons.computer,'  Equipment',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new EquipmentView(_email, _uid , _name, _code,_robustBudget, _noRobustBudget,_realBugdet)));
              }),
              CustomDrawerTitle(Icons.monetization_on,'  Budget',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new BudgetView(_email, _uid, _name, _code, _robustBudget, _noRobustBudget,_realBugdet)));
              }),
              CustomDrawerTitle(Icons.description,'  PES',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid, _name, _code, _robustBudget, _noRobustBudget,_realBugdet)));
              }),
              CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid , _name, _code , _robustBudget, _noRobustBudget, _realBugdet)));
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
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('budgetExpenses').where('studentCode', isEqualTo: _email).where('accountType', isEqualTo: 'robust').orderBy('date', descending: true).snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    controller: controller,
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                      DocumentSnapshot budget = snapshot.data.documents[index];
                      DateTime _dateActual = DateTime.parse(budget["date"].toDate().toString());
                      return  Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            )),
                        height: 80.0,
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text( 'Concept', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text( budget['concept'], style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center, ),
                                ]
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text( 'Amount :', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ),
                                  SizedBox(
                                    width: 2.0,
                                  ),
                                  Text( "\$ ${budget['amountSpent'].toString()} ", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center, ),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text( 'Date', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center, ),
                                  Text( "${_getDay(_dateActual)}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center, ),
                                ]
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 25.0,
              ),
              _showConnectio(_connectivityStatus)
            ]
        )
    );
  }

  String _getDay(DateTime time){
    return " ${time.day}-${time.month}-${time.year} ";
  }

//ADDS A TEXT LABEL TO SHOW WHEN IT DOES NOT HAVE CONNECTION
  Widget _showConnectio(String text){
    if(text == "Lost connection"){
      return Container(
        alignment: AlignmentDirectional.center,
        child: Text(
          " Wait until the connection is stablish again to fecth the data", textAlign: TextAlign.center,
        ),
      );
    }else{
      return Text("");
    }
  }
}

