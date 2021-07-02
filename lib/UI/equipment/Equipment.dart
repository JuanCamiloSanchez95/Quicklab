//SERVICES
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/EquipmentDetail.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';


import '../../loginPage.dart';

class  EquipmentView extends StatefulWidget{

  final String email;
  final String code;
  final String uid;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  EquipmentView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);


  @override
  _EquipmentView  createState() => new _EquipmentView();
}

class _EquipmentView extends State<EquipmentView>{

  final AuthService _authS = AuthService();
  String _email;
  String _name;
  String _uid;
  String _code;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;


  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
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
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    Future _signOut() async {
      logOut();
      await _authS.signOut();
    }

    return Scaffold(
      appBar: new AppBar(
          title: new Text('Equipment  View'),
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
                MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid , _name, _code , _robustBudget, _robustBudget, _robustBudget)));
              }),
              CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                Navigator.push(context, new
                MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid , _name, _code , _robustBudget, _robustBudget, _robustBudget)));
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('equipment').orderBy('totalVisits',descending: true).snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData)return Text('Loading data... PLease wait');
          return  GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing:8.0
            ),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              DocumentSnapshot equip = snapshot.data.documents[index];
              return _buildEquipmentCard(equip['name'], equip['image'], equip['cost'] , index , equip.id , equip['applications'] , equip['costType'], equip['description'], equip['equipmentType'] );
            },
          );}
      ),
    );

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


  Widget _buildEquipmentCard(String name, String cardImage, double cost, int cardIndex, String equipId, String applications, String costtype, String descript, String type){
      return Padding(
        padding: cardIndex.isEven? EdgeInsets.only(right: 5.0): EdgeInsets.only(left: 5.0),
        child: InkWell(
          onTap: (){
            Navigator.push(context, new
            MaterialPageRoute(builder:  (context) => new EquipmentDetailView(equipId, applications, cost, costtype, descript, cardImage, name,type)));
          },
          child: Container(
            height: 400.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                style: BorderStyle.solid,
                width: 1.0
              )
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      //Cache Structure Flutter
                      child: CachedNetworkImage(
                        imageUrl: cardImage,
                        placeholder: _loader,
                        errorWidget: _error,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                      child: Text(
                        name, style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.attach_money,
                              color: Colors.black,
                            ),
                            SizedBox(width: 2.0,),
                            Text(
                              cost.toString(), style: TextStyle(fontSize: 15.0, color: Colors.black), textAlign: TextAlign.center,
                            ),
                          ]
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
  }
}

