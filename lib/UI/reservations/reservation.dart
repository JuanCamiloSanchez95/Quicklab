import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/pes/PesModel.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/reservations/reservationHistory.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../loginPage.dart';


class  ReservationView extends StatefulWidget{
  final String uid;
  final String code;
  final String email;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;

  ReservationView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);
  @override
  _ReservationView  createState() => new _ReservationView();
}

class _ReservationView extends State<ReservationView>{


  String _selectedLab;
  String _selecteEquipment;
  String _selectedCourse;

  final _formkey =  GlobalKey<FormState>();
  String _course="";
  int _hours=0;
  String _code="";
  String _email="";
  String _uid="";
  DateTime _date;
  TimeOfDay _time;
  final AuthService _authS = AuthService();
  String _name;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;
  CalendarController _controller;
  int _day;
  int _month;
  int _year;
  DateTime _dateCalendar;
  DateTime _dateActual;



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _uid= widget.uid;
    _code = widget.code;
    _email = widget.email;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    _name = widget.name;
    _time = TimeOfDay.now();
    _controller=CalendarController();
    _dateCalendar=DateTime.now();
    super.initState();
  }




  onChangeDropDownItemlab(String selectedActual){
    setState(() {
      _selectedLab = selectedActual;
    });
  }

  onChangeDropDownItemCourse(String selectedActual){
    setState(() {
      _selectedCourse = selectedActual;
    });
  }

  onChangeDropDownItemE(String selectedActual){
    setState(() {
      _selecteEquipment = selectedActual;
    });
  }

  @override
  Widget build(BuildContext context) {


    //HOURS FIELD
    final hoursField = TextFormField(
      validator: (_val){
        if(_val.isEmpty || double.parse(_val) < 0 ){
          return 'Enter a hour ';
        }
        else{
          return null;
        }
      },
      onChanged: (val){
        setState(() => _hours = int.parse(val));
      },
      autofocus: true,
      keyboardType: TextInputType.emailAddress ,
      style: TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
          hintText: '1',
          labelText: 'Hours',
          hintStyle: TextStyle(
              color: Colors.grey
          )
      ),
    );

    //DIALOG FOR INTERNET SECURE
    _showDialog(tittle, text){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(tittle),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) =>  ReservationView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                  },
                )
              ],
            );
          }
      );
    }


    //DIALOG FOR INTERNET SECURE
    _DialogError(tittle){
      showDialog(
          context: context,
          builder: (context){
            return SimpleDialog(
              title: Text(tittle),
              children: <Widget>[

              ],
            );
          }
      );
    }

    Future<void> sendResev() async{
      FirebaseFirestore.instance.collection('reservations').doc().set({
        'course': _selectedCourse,
        'date': _date,
        'equipName' : _selecteEquipment,
        'hours' : _hours,
        'labName' : _selectedLab,
        'studentCode' : _code,
        'studentLogin' : _email
      });
      Navigator.push(context, MaterialPageRoute(builder:  (context) => ReservationHistoryView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
    }

    Future<bool> verifyReservationConflict() {
      bool resp=false;
      int ans=0;
      //VERIFICO RESERVAS DEL USUARIO
      FirebaseFirestore.instance.collection('reservations').where('date',isGreaterThanOrEqualTo: _date).where("studentLogin", isEqualTo: _email).get().then((snapshot) {
        int _day = _date.day;
        int _month= _date.month;
        int _year= _date.year;
        int _hour = _date.hour;
        int _hourEnd = _time.hour + _hours;
        for(int i = 0 ; i < snapshot.docs.length ; i++){
          DocumentSnapshot docSnapshot = snapshot.docs[i];
          DateTime _dateReservation = DateTime.parse(docSnapshot["date"].toDate().toString());
          int _dayComp = _dateReservation.day;
          int _monthComp=  _dateReservation.month;
          int _yearComp=  _dateReservation.year;
          int _hourComp =  _dateReservation.hour;
          int _hourCompEnd =  _dateReservation.hour+ docSnapshot["hours"];
          //VERIFICO LA FECHA PRIMERO
          if(_day ==_dayComp && _month ==_monthComp && _year==_yearComp ) {
            //VERIFICO HORA DEL DIA
            if(_hourEnd <=_hourCompEnd && _hourEnd >= _hourComp || _hour >= _hourComp && _hourComp<= _hourCompEnd || _hour<= _hourComp && _hourEnd >= _hourCompEnd){
                ans=1;
                resp = true;
                break;
            }
          }
        }
        //VERIFICO RESERVAS DEL LABORATORIO
        FirebaseFirestore.instance.collection('reservations').where('date',isGreaterThanOrEqualTo: _date).where("labName", isEqualTo: _selectedLab).get().then((value) {
          for(int j=0; j< value.docs.length; j++){
            DocumentSnapshot docSnapshot = value.docs[j];
            DateTime _dateReservation = DateTime.parse(docSnapshot["date"].toDate().toString());
            int _dayComp = _dateReservation.day;
            int _monthComp=  _dateReservation.month;
            int _yearComp=  _dateReservation.year;
            int _hourComp =  _dateReservation.hour;
            int _hourCompEnd =  _dateReservation.hour+ docSnapshot["hours"];
            //VERIFICO LA FECHA PRIMERO
            if(_day ==_dayComp && _month ==_monthComp && _year==_yearComp ) {
              //VERIFICO HORA DEL DIA
              if(_hourEnd <=_hourCompEnd && _hourEnd >= _hourComp || _hour >= _hourComp && _hourComp<= _hourCompEnd || _hour<= _hourComp && _hourEnd >= _hourCompEnd){
                ans=2;
                resp = true;
                break;
              }
            }
          }
          //PASO DE RESPUESTA
          if(resp==false){
              sendResev();
          }
          else if(ans==1){
            _showDialog("Error", "You already have a reservation for that date");
          }
          else if(ans==2){
            _showDialog("Error", "The laboratory is already reserved for that day");
          }
          return resp;
        });
      });
    }


    //CONNECTIO CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
      }
      else {
        verifyReservationConflict();
      }
    }


    final buttonReservation = Material(
        color: Color(0xff598EA9),
        borderRadius: BorderRadius.circular(25.0),
        child: FlatButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            onPressed: () async {
              if(_formkey.currentState.validate()){
                await _checkInternetConnectivity();
              }
              else{
                showDialog(
                  context: context,
                  builder: (context)=> AlertDialog(
                    title: Text("Error"),
                    content: Text("You must define at least one laboratory"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder:  (context) => ReservationView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                        },
                      )
                    ],
                  ),
                );
              }
            },
            child: Text("SEND ", style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );

    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }

    Future<bool> onBackPressed(){
      Navigator.push(context, MaterialPageRoute(builder:  (context) => ReservationHistoryView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
    }


    return Scaffold(
      appBar: new AppBar(
        title: new Text('Reservations  View'),
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
      body: WillPopScope(
        onWillPop: onBackPressed,
        child: Container(
          padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
          child: Form(
            key: _formkey,
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                 Text('Reservation', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30.0, color: Color(0xff598EA9),fontWeight: FontWeight.w600 )),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                  height: 30.0,
                  child:  Text('Which course will you require ', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("courses").snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData){
                      return Text("Loading");
                    }
                    else{
                      List<DropdownMenuItem> courseItem =[];
                      for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                        DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                        courseItem.add(
                            DropdownMenuItem(
                              child: SizedBox(
                                width: 200.0,
                                child: Text(
                                  docSnapshot['name'], overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              value:"${docSnapshot['name']}" ,
                            )
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedCourse ,
                              items: courseItem,
                              onChanged: (courseValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected course value is $courseValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedCourse = courseValue;
                                });
                              }
                          )
                        ],
                      );
                    }
                  },
                ),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                hoursField,
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                  height: 30.0,
                  child:  Text('What laboratories will you require for?', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("laboratory").snapshots(),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                        return Text("Loading");
                      }
                      else{
                        List<DropdownMenuItem> laboratoryItem =[];
                        for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                          DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                          laboratoryItem.add(
                              DropdownMenuItem(
                                child: SizedBox(
                                  width: 200.0,
                                  child: Text(
                                      docSnapshot['name'], overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                value:"${docSnapshot['name']}" ,
                              )
                          );
                        }
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DropdownButton(
                                  value: _selectedLab ,
                                  items: laboratoryItem,
                                  onChanged: (equipValue){
                                    final snacBar = SnackBar(
                                      content: Text(
                                        'Selected laboratory value is $equipValue', overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                    Scaffold.of(context).showSnackBar(snacBar);
                                    setState(() {
                                      _selectedLab = equipValue;
                                    });
                                  }
                              )
                            ],
                          );

                      }
                    },
                  ),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                Container(
                  height: 30.0,
                  child:  Text('What Equipment will you require for?', style: const TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.start),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          style: BorderStyle.solid,
                          width: 5.0
                      )
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("equipment").snapshots(),
                    builder: (context, snapshot){
                      if(!snapshot.hasData){
                         return Text("Loading");
                      }
                      else{
                        List<DropdownMenuItem> equipmentItem =[];
                        for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                          DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                          equipmentItem.add(
                              DropdownMenuItem(
                                child: Text(
                                    docSnapshot['name']
                                ),
                                value:"${docSnapshot['name']}" ,
                              )
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DropdownButton(
                                value: _selecteEquipment ,
                                items: equipmentItem,
                                onChanged: (equipValue){
                                  final snacBar = SnackBar(
                                    content: Text(
                                      'Selected Equipment value is $equipValue',
                                    ),
                                  );
                                  Scaffold.of(context).showSnackBar(snacBar);
                                  setState(() {
                                    _selecteEquipment = equipValue;
                                  });
                                }
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(10.0)
                ),
                TableCalendar(
                  initialCalendarFormat: CalendarFormat.twoWeeks,
                  calendarStyle: CalendarStyle(
                      todayColor: Color(0xff8abedb),
                      selectedColor: Color(0xff598EA9),
                      todayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                  ),
                  availableCalendarFormats: {
                    CalendarFormat.twoWeeks: '2 weeks',
                    CalendarFormat.week: 'Week',
                  },
                  onDaySelected: (date,events,functions){
                    setState(() {
                      _day= date.day;
                      _month=date.month;
                      _year=date.year;
                      _dateCalendar = date;
                    });
                  },
                  calendarController: _controller,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        "Schedule - 7am to 5pm" , style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800), textAlign: TextAlign.center
                    )
                  ],
                ),
                SizedBox(
                  height: 8.0,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("reservations").where('date',isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days:15))).snapshots(),
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
                            visible: _dayDoc==_dateCalendar.day && _monthDoc==_dateCalendar.month && _yearDoc == _dateCalendar.year,
                            child: ListTile(
                              title: Text(reservation["labName"]
                              ),
                              subtitle: Text("${_dayDoc}/${_monthDoc}/${_yearDoc} at  ${_hour}:${_minut}  --- ${reservation['hours']} hours \n${reservation['equipName']}  "),
                            ),
                          );
                        }
                    );
                  },
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment:  CrossAxisAlignment.center,
                    children :<Widget>[
                      FlatButton(
                        child: Text(" Choose a date time" , style: const TextStyle(color: Colors.black, fontSize: 15.0), textAlign: TextAlign.start),
                        onPressed: () async{
                          showDatePicker(context: context, initialDate: DateTime.now().add(Duration(seconds: 1)), firstDate: DateTime.now(), lastDate: DateTime(2021)).then((value) {
                            setState(() {
                              if(value != null){
                                showTimePicker(context: context, initialTime: TimeOfDay.now()).then((valued) {
                                  if(valued!=null){
                                    _time = valued;
                                    setState(() {
                                      if(_time.hour<7 || _time.hour > 17 || _time.hour+_hours> 17 ){
                                        _DialogError("Insert a valid hour");
                                      }
                                      else{
                                        this._date = DateTime(
                                            value.year,
                                            value.month,
                                            value.day,
                                            _time.hour,
                                            _time.minute
                                        );
                                      }
                                    });
                                  }
                                });
                              }
                            });
                          });
                        },
                      ),
                      Text(_date == null ? '' : "Date selected", style: const
                      TextStyle(color: Colors.black, fontSize: 10.0),
                        textAlign: TextAlign.start,
                      ),
                    ]
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(_date == null ? '' : _date.toString(), style: const
                  TextStyle(color: Colors.black, fontSize: 10.0),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                buttonReservation
              ],
            ),
          ),
        ),
      ),
    );
  }
}
