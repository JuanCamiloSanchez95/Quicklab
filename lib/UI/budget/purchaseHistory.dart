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
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';
import 'budgetModel.dart';

class  PurchaseView extends StatefulWidget{

  final String email;
  final String code;
  final String uid;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  PurchaseView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _purchaseView  createState() => new _purchaseView();
}

class _purchaseView extends State<PurchaseView>{

  final db = FirebaseFirestore.instance;
  final AuthService _authS = AuthService();
  String _email;
  String _name;
  String _uid;
  String _code;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  String _connectivityStatus;
  DateTime _dateActual;
  dynamic data;
  ScrollController controller = ScrollController();
  List<purcheaseObject> purchasesList= [];

  



  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _checkStatus();
    _email = widget.email;
    _name = widget.name;
    _uid = widget.uid;
    _code = widget.code;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    super.initState();
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
        title: new Text('Purchase History'),
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
        scrollDirection: Axis.vertical,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('budgetExpenses').where('studentCode', isEqualTo: _email).where('date', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 31))).orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... Please wait'));
                return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      controller: controller,
                      itemExtent: 50,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                           DocumentSnapshot expenses = snapshot.data.documents[index];
                          _dateActual = DateTime.parse(expenses["date"].toDate().toString());
                          return Container(
                            padding: EdgeInsets.all(5.0),
                            child: ListTile(
                              title: Text("Amount:  \$${expenses['amountSpent'].toString()}"),
                              subtitle: Text("${expenses['accountType']} --  ${expenses['concept']} --  ${getDay(_dateActual)}"),
                            ),
                          );
                      });
              },
            ),
            SizedBox(
              height: 25.0,
            ),
            _showConnection(_connectivityStatus)
          ]
      ),
    );
  }
}

String getDay(DateTime time){
  return " ${time.day}-${time.month}-${time.year} ";
}

//ADDS A TEXT LABEL TO SHOW WHEN IT DOES NOT HAVE CONNECTION
Widget _showConnection(String text){
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

