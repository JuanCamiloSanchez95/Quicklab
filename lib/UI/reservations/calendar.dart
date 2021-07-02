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
import 'package:table_calendar/table_calendar.dart';

import '../../loginPage.dart';

class  calendarView extends StatefulWidget{
  final String uid;
  final String code;
  final String email;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  calendarView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _calendarView  createState() => new _calendarView();
}

class _calendarView extends State<calendarView>{
 //USER INFORMATION
  String _idUsuario;
  String _code;
  String _email;
  String _name;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  DateTime _dateActual;
  String _connectivityStatus;
  //FIREBASE
  final AuthService _authS = AuthService();
  //UTILITIES
  CalendarController _controller;
  int _day;
  int _month;
  int _year;
  DateTime _date;
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
    _code=widget.code;
    _idUsuario = widget.uid;
    _email = widget.email;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    _name = widget.name;
    _date=DateTime.now();
    _controller=CalendarController();
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

  Future<bool> _backhome(){
    Navigator.push(context, new
    MaterialPageRoute(builder:  (context) => new  profileActivity()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Calendar'),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TableCalendar(
                //initialCalendarFormat: CalendarFormat.week,
                calendarStyle: CalendarStyle(
                  todayColor: Color(0xff8abedb),
                  selectedColor: Color(0xff598EA9),
                  todayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  )
                ),
                onDaySelected: (date,events,functions){
                  setState(() {
                    _day= date.day;
                    _month=date.month;
                    _year=date.year;
                    _date = date;
                  });
                },
                calendarController: _controller,
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      "Events" , style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800), textAlign: TextAlign.center
                  )
                ],
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("reservations").where('studentLogin', isEqualTo: _email).snapshots(),
                builder: (context,snapshot){
                  if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                  final events=snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index){
                      DocumentSnapshot reservation = snapshot.data.documents[index];
                      _dateActual = DateTime.parse(reservation["date"].toDate().toString());
                      int _dayDoc=_dateActual.day;
                      int _monthDoc=_dateActual.month;
                      int _yearDoc=_dateActual.year;
                      int _hour= _dateActual.hour;
                      int _minut= _dateActual.minute;
                      return Visibility(
                        visible: _dayDoc==_date.day && _monthDoc==_date.month && _yearDoc == _date.year,
                        child: ListTile(
                          title: Text(reservation["labName"]
                          ),
                          subtitle: Text("${reservation["course"]}  --  ${_dayDoc}/${_monthDoc}/${_yearDoc} at  ${_hour}:${_minut}"),
                        ),
                      );
                    }
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

