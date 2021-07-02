//PACKAGES
import 'package:flutter/material.dart';
//PAGES
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/budget/purchaseHistory.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/reservations/calendar.dart';
import 'package:quicklab/UI/reservations/reservation.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:quicklab/loginPage.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/accidents/accidentReport.dart';
//SERVICES
import 'package:quicklab/UI/services/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

//PROFILE STATEFULL WIDGET
class profileActivity extends StatefulWidget{
  @override
  _profileActivity createState() => _profileActivity();
}


//HOME VIEW STRUCTURE
class _profileActivity extends State<profileActivity> {
  //USER INFORMATION
  String _email;
  String _name;
  String _uid;
  String _code;
  String _role;
  String _connectivityStatus;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  //FIREBASE SERVICES
  final db = FirebaseFirestore.instance;
  final AuthService _authS = AuthService();
  //UTILITIES
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  dynamic data;




  //GET THE BUDGET INFORMATION OF THE USER
   Future<void> getBudget(){
     db.collection("studentsBudget").where('email', isEqualTo: _email).get().then((snap) {
       snap.docs.forEach((element) {
         data = element.data();
         if(data['type'] == 'robust'){
           setState(() {
             _robustBudget = '${data['available']}';
           });
         }
         else if(data['type'] == 'nonRobust'){
           setState(() {
             _nonRobustBudget = '${data['available']}';
           });
         }
         else{
           _realBudget = '${data['available']}';
         }
       });
     });
   }

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
    super.initState();
    _checkStatus();
    _email= "TBD";
    _name="TBD";
    _code="TBD";
    _role = "TBD";
    _robustBudget = '0.0';
    _nonRobustBudget = '0.0';
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _uid = value.getString('uid');
        _email = value.getString('email');
        _name = value.getString('name');
        _code = value.getString('code');
        _role = value.getString('role');
      });
    }).then((value) {
      db.collection("studentsBudget").where('email', isEqualTo: _email).get().then((snap) {
        if(snap.docs.length>0){
          snap.docs.forEach((element) {
            data = element.data();
            if(data['type'] == 'robust'){
              setState(() {
                _robustBudget = '${data['available']}';
              });
            }
            else if(data['type'] == 'nonRobust'){
              setState(() {
                _nonRobustBudget = '${data['available']}';
              });
            }
            else{
              _realBudget = '${data['available']}';
            }
          });
        }
    });
  });
  }

  //CHECK STATUS OF THE CONNECTION  FOR CHANGE THE VALUE ON THE CONNECTION
  void _checkStatus(){
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.none){
        ChangeValues("Without network connection");
      }
      else if(result == ConnectivityResult.wifi){
        ChangeValues("Connected");
        getBudget();
      }
      if(result == ConnectivityResult.mobile){
        ChangeValues("Connected");
        getBudget();
      }
    });
  }

  //CHANGE  THE VALUE OF THE CONNECTION
  void ChangeValues(String text){
    setState(() {
      _connectivityStatus = text;
    });
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
        color:  Color(0xff8abedb),
      );
    }
  }


  //DIALOG  THAT ASK THE USER IF HE WANTS TO EXIT THE APPLICATION
  Future<bool> onBackPressed(){
    return showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Are you sure ?"),
          content: Text(" You are going to exit the application"),
          actions: <Widget>[
            FlatButton(
              child: Text("YES"),
              onPressed: (){
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text("NO"),
              onPressed: (){
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      }
    );
  }

  //BUILDING THE HOME VIEW
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar:  new AppBar(
          title: new Text('Home'),
          centerTitle: true,
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
                MaterialPageRoute(builder:  (context) => new  profileActivity()));
              }),
              CustomDrawerTitle(Icons.person,'  Profile',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new profileView(_email, _uid , _name, _code,_robustBudget, _nonRobustBudget,_realBudget)));
              }),
              CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ScanView(_email, _uid , _name, _code,_robustBudget, _nonRobustBudget,_realBudget)));
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
            ],
          ),
        ),
        body: WillPopScope(
          onWillPop: onBackPressed,
          child: Stack(
            children: <Widget> [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _showConnectio(_connectivityStatus),
                  Container(
                    width: 300.0,
                    height: 250.0,
                    color: Color(0xff8abedb),
                    child: Align(
                      child: Container(
                        width: 300.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                                  child: Text("Welcome"),
                                ),
                                Text(_name, style: TextStyle(fontSize: 25.0,  fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 0.0),
                                  child: Text( _role + "-"  + _code),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: 150.0,
                                    height: 150.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage("assets/Login.JPG"),
                                            fit: BoxFit.fill
                                        )
                                    ),
                                  )],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Positioned(
                top: 220,
                left: 50,
                right: 50,
                child: Container(
                  height: 75.0,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                      child: Text("Remain Non- Robust budget" ,style: TextStyle( fontSize: 15.0)),
                    ),
                    Row(
                      children: <Widget>[
                        StreamBuilder(
                          stream: db.collection('studentsBudget').where('email', isEqualTo: _email).where('type',isEqualTo: 'nonRobust').snapshots(),
                          builder: (context, snapshot){
                            if(!snapshot.hasData) return Text("0.0");
                            DocumentSnapshot budgetNonRobust = snapshot.data.documents[0];
                            return Visibility(
                              visible: snapshot.hasData,
                              child: Text(" \$${budgetNonRobust["available"]}"  , style: TextStyle( fontSize: 15.0, color: Colors.blueAccent), textAlign: TextAlign.center)
                            );
                          }
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              Positioned(
                top: 300,
                left: 50,
                right: 50,
                child: Container(
                  height: 75.0,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                        child: Text("Remain Robust budget" ,style: TextStyle( fontSize: 15.0)),
                      ),
                      Row(
                        children: <Widget>[
                          StreamBuilder(
                              stream: db.collection('studentsBudget').where('email', isEqualTo: _email).where('type',isEqualTo: 'robust').snapshots(),
                              builder: (context, snapshot){
                                if(!snapshot.hasData) return Text("0.0");
                                DocumentSnapshot budgetRobust = snapshot.data.documents[0];
                                return  Visibility(
                                  visible: snapshot.hasData,
                                  child: Text(" \$${budgetRobust["available"]}"  , style: TextStyle( fontSize: 15.0, color: Colors.blueAccent), textAlign: TextAlign.center)
                                );
                              }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 380,
                  left: 50,
                  right: 50,
                  child:CustomTitleReservation( "Reserve", _email,_uid,_name,_code,_robustBudget,_nonRobustBudget,_realBudget)
              ),
              Positioned(
                  top: 430,
                  left: 50,
                  right: 50,
                  child:CustomTitleAccidents("Report Accident", _email,_uid,_name,_code,_robustBudget,_nonRobustBudget,_realBudget)
              ),
              Positioned(
                  top: 480,
                  left: 50,
                  right: 50,
                  child:CustomTitleCalendar("Calendar", _email,_uid,_name,_code,_robustBudget,_nonRobustBudget,_realBudget)
              ),
          ]),
        ),
      );
  }


  //LOG OUT SERVICE
  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }
}


//CUSTOM TITLE FOR THE RESERVATION LINK
class CustomTitleReservation extends StatelessWidget {
  String title;
  String email;
  String uidInfo;
  String name;
  String code;
  String robust;
  String nonRobust;
  String real;
  CustomTitleReservation(this.title,this.email, this.uidInfo, this.name, this.code, this.robust,this.nonRobust,this.real);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                ),
                //Change Icon
                //Change Text
                Text(title, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
              ],
            ),
            Icon(Icons.arrow_right)
          ],
        ),
      ),
      onTap: (){
        Navigator.push(context, new
        MaterialPageRoute(builder:  (context) => new ReservationView(email,uidInfo,name,code,robust,nonRobust,real)));
      },
    );
  }
}

//CUSTOM TITLE FOR THE ACCIDENTS LINK
class CustomTitleAccidents extends StatelessWidget {
  String title;
  String email;
  String uidInfo;
  String name;
  String code;
  String robust;
  String nonRobust;
  String real;
  CustomTitleAccidents(this.title,this.email, this.uidInfo, this.name, this.code, this.robust,this.nonRobust,this.real);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                ),
                //Change Icon
                //Change Text
                Text(title, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
              ],
            ),
            Icon(Icons.arrow_right)
          ],
        ),
      ),
      onTap: (){
        Navigator.push(context, new
        MaterialPageRoute(builder:  (context) => new AccidentReportView(email,uidInfo,name,code,robust,nonRobust,real)));
      },
    );
  }
}

//CUSTOM TITLE FOR THE Calendar LINK
class CustomTitleCalendar extends StatelessWidget {
  String title;
  String email;
  String uidInfo;
  String name;
  String code;
  String robust;
  String nonRobust;
  String real;
  CustomTitleCalendar(this.title,this.email, this.uidInfo, this.name, this.code, this.robust,this.nonRobust,this.real);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      child: Container(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                ),
                //Change Icon
                //Change Text
                Text(title, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
              ],
            ),
            Icon(Icons.arrow_right)
          ],
        ),
      ),
      onTap: (){
        Navigator.push(context, new
        MaterialPageRoute(builder:  (context) => new calendarView(email,uidInfo,name,code,robust,nonRobust,real)));
      },
    );
  }
}
