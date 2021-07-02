import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/pes/PesModel.dart';
import 'package:quicklab/UI/pes/pesMonitor.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class  pesMonitorDetail extends StatefulWidget{

  //MONITOR INFORMATION
  final laboratory;
  final email;
  final role;
  final name;
  final uid;
  //PES INFORMATION
  final course;
  final date;
  final exp;
  final equip;
  final mat;
  final member;
  final prof;
  final status;
  final username;
  final uidPes;
  pesMonitorDetail(this.uid,this.email,this.name,this.role,this.laboratory,this.course,this.date,this.exp,this.equip,this.mat,this.member,this.prof,this.status,this.username,this.uidPes);

  @override
  _pesMonitorDetail  createState() => new _pesMonitorDetail();
}

class _pesMonitorDetail extends State<pesMonitorDetail>{
  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  //PES INFORMTAION
  String _course="";
  DateTime _date;
  String _experiment="";
  String _equipment="";
  String _material="";
  String _member ="";
  String _professor="";
  String _statusPes;
  String _userName="";
  String _uidPes;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  final db = FirebaseFirestore.instance;
  //UTILITIES
  dynamic data;
  //STATUS INFORMATION
  List<Status> _status = Status.getStatus();
  List<DropdownMenuItem<Status>> _dropdownMenyItems;
  Status _selected;


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
    setState(() {
      _lab = widget.laboratory;
      _email=widget.email;
      _name=widget.name;
      _role=widget.role;
      _uid=widget.uid;
      //PES INFORMATION INITIALIZATION
      _course=widget.course;
      _date= widget.date;
      _experiment=widget.exp;
      _equipment=widget.equip;
      _material=widget.mat;
      _member=widget.member;
      _professor=widget.prof;
      _statusPes=widget.status;
      _userName=widget.username;
      _uidPes=widget.uidPes;
    });
    super.initState();
    _dropdownMenyItems = buildDropDown(_status);
  }

  List<DropdownMenuItem<Status>> buildDropDown(List status){
    List<DropdownMenuItem<Status>> items = List();
    for(Status stat in status ){
      items.add(DropdownMenuItem(
        value: stat,
        child: Text(stat.description),
      ));
    }
    return items;
  }

  onChangeDropDownItem(Status selectedStatus){
    setState(() {
      _selected = selectedStatus;
    });
  }



  @override
  Widget build(BuildContext context) {

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
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => pesMonitorDetail(_uid,_email, _name, _role, _lab, _course, _date, _experiment, _equipment, _material, _member, _professor, _statusPes, _userName, _uidPes)));
                  },
                )
              ],
            );
          }
      );
    }

    //CONFIRMARION OF CHANGES
      _sendDialog(tittle, text){
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
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => monitorView()));
                    },
                  )
                ],
              );
            }
        );
    }

    Future<void> sendUpdate() async{
      db.collection('Pes').doc(_uidPes).update({
        'status': _selected.description
      }).then((value) {
        _sendDialog("Succesful", "You have updated the status of the Pes request");
      });
    }


    //CONNECTION CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
      }
      else {
        sendUpdate();
      }
    }

    final buttonPes = Material(
        color: Color(0xff598EA9),
        borderRadius: BorderRadius.circular(25.0),
        child: FlatButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            onPressed: () async {
              if(_selected!=null){
                await _checkInternetConnectivity();
              }
              else{
                showDialog(
                  context: context,
                  builder: (context)=> AlertDialog(
                    title: Text("Error"),
                    content: Text("You need to select a status ", textAlign: TextAlign.center),
                    actions: <Widget>[
                      FlatButton(
                          child: Text("OK"),
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder:  (context) => pesMonitorDetail(_uid, _email, _name, _role, _lab, _course, _date, _experiment, _equipment, _material, _member, _professor, _statusPes, _userName, _uidPes)));
                          }
                      ),
                      FlatButton(
                          child: Text("Cancel"),
                          onPressed: (){
                            Navigator.push(context, new
                            MaterialPageRoute(builder:  (context) => new monitorView()));
                          }
                      )
                    ],
                  ),
                );
              }
            },
            child: Text("UPDATE PES", style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );

    //DIALOG  THAT ASK THE USER IF HE WANTS TO EXIT THE APPLICATION
    Future<bool> onBackPressed(){
      return showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("Are you sure ?"),
              content: Text("You will back on the list"),
              actions: <Widget>[
                FlatButton(
                  child: Text("YES"),
                  onPressed: (){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new pesMonitorView(_uid,_email, _name, _role, _lab)));
                  },
                ),
                FlatButton(
                  child: Text("NO"),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => pesMonitorDetail(_uid,_email, _name, _role, _lab, _course, _date, _experiment, _equipment, _material, _member, _professor, _statusPes, _userName, _uidPes)));
                  },
                ),
              ],
            );
          }
      );
    }


    //SIGN OUT
    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }

    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        appBar: new AppBar(
          title: new Text('PES ${_lab} Validation'),
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
                MaterialPageRoute(builder:  (context) => new monitorAccident(_uid, _name, _email, _lab, _role)));
              }),
              CustomDrawerTitle(Icons.attach_money,'  Purchases',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new monitorPurchaseHistory(_uid, _name, _email, _lab, _role)));
              }),
              CustomDrawerTitle(Icons.invert_colors,'  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new reagentsUsage(_uid, _name, _email, _lab, _role)));
              }),
              CustomDrawerTitle(Icons.computer,'  Equipment',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new monitorEquipment(_uid, _name, _email, _lab, _role)));
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
        body: Center(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
                child: Text("PES Validation", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w800),textAlign: TextAlign.center),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Student : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Expanded(child: Text("${_userName}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Course : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Expanded(child: Text("${_course}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,))
                      ],
                    ),
                    Visibility(
                      visible: _member== "Si",
                     child:   Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                         Text("IQUI Student", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                       ],
                     ),
                    )
                  ],
                )
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Information", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    style: BorderStyle.solid,
                  )
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Requested day : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Flexible(child: Text("${getDay(_date)}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center, overflow: TextOverflow.visible))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Experiment : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Flexible(child: Text("${_experiment}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center, overflow: TextOverflow.visible))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Lab. Equipment : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Flexible(child: Text("${_equipment}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center, overflow: TextOverflow.visible,))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Lab. Material : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Flexible(child: Text("${_material}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center, overflow: TextOverflow.visible))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Teacher : ", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(height: 20.0),
                        Flexible(child: Text("${_professor}", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200),textAlign: TextAlign.center, overflow: TextOverflow.visible))
                      ],
                    )
                  ]
                ),
              ),
              SizedBox(
                height: 20.0  ,
              ),
              StreamBuilder(
                  stream: db.collection("pes").doc(_uidPes).snapshots(),
                  builder: (context, snapshot){
                    if(!snapshot.hasData) return Text("Loading Budget");
                    DocumentSnapshot pes= snapshot.data;
                    return   Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("STATUS", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),textAlign: TextAlign.center),
                        SizedBox(
                          height: 10.0  ,
                        ),
                        Visibility(
                          visible: pes["status"] !="Accepted" && pes["status"] !="Rejected",
                          child: DropdownButton(
                            value: _selected,
                            items: _dropdownMenyItems,
                            onChanged: onChangeDropDownItem,
                          ),
                        ),
                        SizedBox(
                          height: 10.0  ,
                        ),
                        Text("The actual status is  ${pes["status"]}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center),
                        SizedBox(
                          height: 10.0  ,
                        ),
                        Visibility(
                          visible: pes["status"] !="Accepted" && pes["status"] !="Rejected",
                          child: buttonPes,
                        )
                      ],
                    );}
              ),
              //SCROLL FOR VALIDATING PES
            ],
          ),
        ),
      ),
    );
  }
}


String getDay(DateTime time){
  return " ${time.day}-${time.month}-${time.year} ";
}
