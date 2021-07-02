import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';


import '../../loginPage.dart';
import 'EquipmentMonitor.dart';

class  monitorEquipmentDetail extends StatefulWidget{

  final uid;
  final laboratory;
  final email;
  final role;
  final name;
  final equipName;
  final image;
  monitorEquipmentDetail(this.uid,this.email,this.name,this.role,this.laboratory,this.equipName,this.image);

  @override
  _monitorEquipmentDetail  createState() => new _monitorEquipmentDetail();
}

class _monitorEquipmentDetail extends State<monitorEquipmentDetail>{
  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
  String _image;
  String _equipName;
  //FIREBASE SERVICES
  final AuthService _authS = AuthService();
  //UTILITIES
  dynamic data;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _connectivityStatus;
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
    setState(() {
      _lab = widget.laboratory;
      _email=widget.email;
      _name=widget.name;
      _role=widget.role;
      _uid=widget.uid;
      _equipName=widget.equipName;
      _image= widget.image;
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }


    Future<bool> _backHome(){
      Navigator.push(context, new
      MaterialPageRoute(builder:  (context) => new monitorEquipment(_uid, _email, _name, _role, _lab)));
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

    String getDay(DateTime time){
      return " ${time.day}-${time.month}-${time.year} ";
    }



    return Scaffold(
      appBar: new AppBar(
        title: new Text('Reservation history'),
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
      body: WillPopScope(
        onWillPop: _backHome,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 15.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  height: 200.0,
                  width: 200.0,
                  child: CachedNetworkImage(
                    imageUrl: _image,
                    placeholder: _loader,
                    errorWidget: _error,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(_equipName, style: TextStyle(fontSize: 30.0), textAlign: TextAlign.center),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Text("-------------------------------" , textAlign: TextAlign.center,),
            SizedBox(
              height: 10.0,
            ),
            Text("Reservations" , style: TextStyle(fontSize: 20.0 ,fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reservationsgit ').where('equipName', isEqualTo: _equipName).where('labName',isEqualTo: _lab).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot reser = snapshot.data.documents[index];
                    DateTime _dateActual = DateTime.parse(reser["date"].toDate().toString());
                    return Container(
                      padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            )),
                          height: 80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("${reser['studentLogin']} - ${reser['studentCode']} " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                     Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Text(" Hours : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text( "${reser["hours"].toString()}", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center, ),

                                          ]
                                      ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(" Date : " ,style: TextStyle(fontWeight: FontWeight.bold),),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text( getDay(_dateActual) , style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center, ),
                                        ]
                                    )
                                  ],
                                ),
                      );
                    },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
