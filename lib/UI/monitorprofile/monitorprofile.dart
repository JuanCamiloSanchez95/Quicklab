import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/accidentMonitorReport.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/pes/pesMonitor.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/reservations/reservationMonitor.dart';
//SERVICES
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../loginPage.dart';

class monitorView extends StatefulWidget{
  @override
  _monitorView createState() => _monitorView();
}

class _monitorView extends State<monitorView> {
  //MONITOR INFORMATION
  String _email;
  String _Laboratory;
  String _name;
  String _uid;
  String _role;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  //UTILITIES
  dynamic data;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _connectivityStatus;



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
    _email= "TBD";
    _name="TBD";
    _role = "Monitor";
    _Laboratory="TBD";
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _uid = value.getString('uid');
        _email= value.getString('email');
        _name= value.getString('name');
        _Laboratory= value.getString('lab');
        _role= value.getString('role');
      });
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


    return Scaffold(
      key: _scaffoldKey,
      appBar:  new AppBar(
        title: new Text('Profile'),
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
              MaterialPageRoute(builder:  (context) => new monitorAccident(_uid, _name, _email, _Laboratory, _role)));
            }),
            CustomDrawerTitle(Icons.attach_money,'  Purchases',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorPurchaseHistory(_uid, _name, _email, _Laboratory, _role)));
            }),
            CustomDrawerTitle(Icons.invert_colors,'  Reagents',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new reagentsUsage(_uid, _name, _email, _Laboratory, _role)));
            }),
            CustomDrawerTitle(Icons.computer,'  Equipment',(){
              Navigator.push(context, new
              MaterialPageRoute(builder:  (context) => new monitorEquipment(_uid, _name, _email, _Laboratory, _role)));
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
                                    child: Text(  _role  ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15.0, 0.0, 5.0, 0.0),
                                    child: Text(  _Laboratory ),
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
                    top: 275,
                    left: 50,
                    right: 50,
                    child:CustomTitlesNavigation( "PES", _email,_uid,_name,_Laboratory,_role,
                        (){
                          Navigator.push(context, new
                          MaterialPageRoute(builder:  (context) => new pesMonitorView(_uid,_email, _name, _role, _Laboratory)));
                        }
                    )
                ),
                Positioned(
                    top: 315,
                    left: 50,
                    right: 50,
                    child:CustomTitlesNavigation( "Reservation", _email,_uid,_name,_Laboratory,_role,
                            (){
                          Navigator.push(context, new
                          MaterialPageRoute(builder:  (context) => new monitorReservation(_uid, _name, _email, _Laboratory, _role)));
                        }

                    )
                ),
                Positioned(
                    top: 355,
                    left: 50,
                    right: 50,
                    child:CustomTitlesNavigation( "Accident Report", _email,_uid,_name,_Laboratory,_role,
                            (){
                          Navigator.push(context, new
                          MaterialPageRoute(builder:  (context) => new monitorAccidentReport(_uid, _name, _email, _Laboratory, _role)));
                        }
                    )
                ),
              ]),
        ),
    );
  }

  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }
}



//CUSTOM TITLE FOR THE RESERVATION LINK
class CustomTitlesNavigation extends StatelessWidget {
  String title;
  String email;
  String uidInfo;
  String name;
  String laboratory;
  String role;
  Function onTap;
  CustomTitlesNavigation(this.title,this.email, this.uidInfo, this.name, this.laboratory, this.role, this.onTap);

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
      onTap: onTap
    );
  }
}
