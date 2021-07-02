import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/equipment/EquipmentDetail.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../loginPage.dart';

class  ScanView extends StatefulWidget{
  final String email;
  final String code;
  final String uid;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;

  ScanView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _ScanView  createState() => new _ScanView();
}


class _ScanView extends State<ScanView> {
  String _uidEquipment= 'Not yet Scanned';
  String _image='';
  int _oldVisit;
  int _qrVisits;
  bool _isInitial = false;
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


  void _scanBarcode() async{
    List<Barcode> barcodes = List();
    try{
        barcodes = await FlutterMobileVision.scan(
          waitTap: true,
          showText: true,
        );
        if(barcodes.length>0){
          for(Barcode barcode in barcodes){
            setState(() {
              _uidEquipment = barcode.displayValue;
              db.collection('equipment').doc(_uidEquipment).get().then<dynamic>((DocumentSnapshot snapshot) {
                setState(() {
                  data=snapshot.data();
                  if(data!=null){
                    _image = data['image'];
                    _oldVisit= data['totalVisits'];
                    _qrVisits= data['qrVisits'];
                    int _newVisits =_incrementVisit(_oldVisit);
                    int _newQr =_incrementVisit(_qrVisits);
                    db.collection('equipment').doc(_uidEquipment).update({
                      'qrVisits':_newQr,
                      'totalVisits': _newVisits
                    });
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new EquipmentDetailView(_uidEquipment, data['applications'], data['cost'],data['costType'],data['description'],data['image'],data['name'],data['equipmentType'])));
                  }
                  else{
                    return showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("QR scanned error ?"),
                            content: Text(" Not recognized code for the equipment try it again?"),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("YES"),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder:  (context) => ScanView(_email, _uid , _name, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                                },
                              ),
                              FlatButton(
                                child: Text("NO"),
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder:  (context) => profileActivity()));
                                },
                              ),
                            ],
                          );
                        }
                    );
                  }
                });
              });
            });
          }
        }
    }
    catch(e){
      print(e.toString());
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
    FlutterMobileVision.start().then((value) {
      setState(() {
        _isInitial=true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Scan'),
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
      body: Container(
        padding: EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Scan your equipment QR code'  , style:  TextStyle(fontSize: 18.0, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              padding: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: AssetImage('assets/qrIcon.png'),
                      fit: BoxFit.fill
                  )
              ),
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(
              height: 20.0,
            ),
        Container(
          padding: EdgeInsets.all(35.0),
          child: FlatButton(
            padding: EdgeInsets.all(13.0),
            color:  Color(0xff598EA9),
            onPressed: () async{
                _scanBarcode();
            },
            child: Text('SCAN', style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), side:  BorderSide(color: Colors.blue, width: 2.0)
            ),
          ),
        )],
        ),
      ),
    );
  }

  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }
}





int _incrementVisit(int old){
  return old+1;
}