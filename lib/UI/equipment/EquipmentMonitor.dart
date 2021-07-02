import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/monitorAccident.dart';
import 'package:quicklab/UI/budget/monitorPurchasesHistory.dart';
import 'package:quicklab/UI/equipment/EquipmentDetailMonitor.dart';
import 'package:quicklab/UI/monitorprofile/monitorprofile.dart';
import 'package:quicklab/UI/reagents/reagentsUsage.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';


import '../../loginPage.dart';

class  monitorEquipment extends StatefulWidget{

  final uid;
  final laboratory;
  final email;
  final role;
  final name;

  monitorEquipment(this.uid,this.email,this.name,this.role,this.laboratory);

  @override
  _monitorEquipment  createState() => new _monitorEquipment();
}

class _monitorEquipment extends State<monitorEquipment>{

  //MONITOR INFORMATION
  String _lab;
  String _email;
  String _name;
  String _role;
  String _uid;
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

    //SIGN OUT
    Future _signOut() async {
      logOut();
      await _authS.signOut();
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
          color:  Colors.white,
        );
      }
    }

    Future<bool> _backHome(){
      Navigator.push(context, new
      MaterialPageRoute(builder:  (context) => new monitorView()));
    }


    Widget _loader(BuildContext conext, String url){
      return  Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget _error(BuildContext conext, String url, dynamic error){
      print(error);
      return  Center(
        child: Icon(Icons.error_outline),
      );
    }


    return Scaffold(
      appBar: new AppBar(
        title: new Text('Equipment List'),
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
            Visibility(
              visible: _connectivityStatus=="Without network connection",
              child: _showConnectio(_connectivityStatus),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('equipment').orderBy('name', descending: false).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)return Center(child: Text('Loading data... PLease wait'));
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  controller: controller,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                    DocumentSnapshot equipment = snapshot.data.documents[index];
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              style: BorderStyle.solid,
                            )),
                        height: 100,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 100.0,
                                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                                alignment: Alignment.center,
                                child: CachedNetworkImage(
                                    imageUrl: equipment["image"],
                                    placeholder: _loader,
                                    errorWidget: _error,
                                  ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("${equipment['name']} " , style: TextStyle(fontSize:15.0 , fontWeight: FontWeight.bold)),
                                    Row(
                                        children: <Widget>[
                                          Text( "${equipment["equipmentType"]}", style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center, ),
                                        ]
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.push(context, new
                        MaterialPageRoute(builder:  (context) => new monitorEquipmentDetail(_uid, _name, _email, _lab, _role,equipment['name'], equipment['image'])));
                      },
                    );},
                );
              },
            ),
            SizedBox(
              height: 25.0,
            ),
          ],
        ),
      ),
    );
  }
}

