import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/budget/purchaseHistory.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
import 'package:quicklab/UI/forum/forums.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/accountSettings.dart';
import 'package:quicklab/UI/profile/courses.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/reservations/reservationHistory.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import '../../loginPage.dart';

class  profileView extends StatefulWidget{
  final String email;
  final String code;
  final String uid;
  final String name;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  profileView(this.email, this.uid, this.name, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);

  @override
  _profileView  createState() => new _profileView();
}

class _profileView extends State<profileView>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Profile'),
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
      body: Center(
        child: ListView(
          padding: EdgeInsets.fromLTRB(30.0,20.0,30.0,50.0),
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
              alignment: Alignment.center,
              height: 485.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 5.0
                  )
              ),
              child: ListView(
                children: <Widget>[
                  Center(
                    child: Column(
                      children:<Widget>[ Container(
                        width: 200.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/Login.JPG"),
                            fit: BoxFit.fitWidth,
                          )
                        ),
                      ),]
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(_name, style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(_email, style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center),
                  SizedBox(
                    height: 15.0,
                  ),
                  CustomTitle(Icons.book, '  My courses',(){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new CoursesView()));
                  }),
                  SizedBox(
                    height: 15.0,
                  ),
                  CustomTitle(Icons.forum, '  Forum posts',(){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new ForumView()));
                  }),
                  SizedBox(
                    height: 15.0,
                  ),
                  CustomTitle(Icons.list, '  Reservation history',(){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new ReservationHistoryView(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                  }),
                  SizedBox(
                    height: 15.0,
                  ),
                  CustomTitle(Icons.attach_money, '  Purchase history',(){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new PurchaseView(_email, _uid, _name, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                  }),
                  SizedBox(
                    height: 15.0,
                  ),
                  CustomTitle(Icons.settings, '  Settings',(){
                    Navigator.push(context, new
                    MaterialPageRoute(builder:  (context) => new SettingsView()));
                  }),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color:  Color(0xff598EA9),
                  ),
                  height: 100.0,
                  width: 200.0,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(" Your monthly expenses : " , style:  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400)),
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text( ' \$ 0.0 ' ,  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.0,
                  width: 30.0,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                        image: AssetImage('assets/wallet.JPG'),
                            fit: BoxFit.fill
                      )
                    ),
                    height: 100.0,
                    width: 175.0,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }
}



class CustomTitle extends StatelessWidget{
  IconData icon;
  String text;
  Function onTap;
  CustomTitle(this.icon,this.text,this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Color(0xff598EA9),
        child: Container(
          height: 40,
          child: Row(
            mainAxisAlignment:  MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(6.0, 0, 0, 0),
                  ),
                  //Change Icon
                  Icon(icon),
                  //Change Text
                  Text(text, style: const TextStyle(fontSize: 16.0),),
                ],
              ),
            ],
          ),
        ),
        onTap: onTap
    );
  }
}
