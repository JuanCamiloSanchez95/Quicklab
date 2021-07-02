import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/accidents/accidentHistory.dart';
import 'package:quicklab/UI/reservations/reservation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class  homeView extends StatefulWidget{

  final String code;
  final String name;
  final String role;
  final String uid;
  final String email;
  homeView( this.code, this.name, this.role, this.uid, this.email);

  @override
  _homeView  createState() => new _homeView();
}

class _homeView extends State<homeView>{

  String _name;
  String _code;
  String _role;
  String _uid;
  String _email;

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _code = widget.code;
    _name = widget.name;
    _role = widget.role;
    _uid = widget.uid;
    _email =widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Home View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ),
      body:Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 300.0,
                height: 300.0,
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
                              child: Text( _role + " : "  + _code),
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
              ),
            ],
          ),
          Positioned(
            top: 250,
            left: 50,
            right: 50,
            child: Container(
              height: 75.0,
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 0.0),
                    child: Text("70 % Remain NON-Robust budget"),
                  ),
                  SizedBox(
                    height: 10.0,
                    width: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.attach_money),
                      SizedBox(
                        height: 5.0,
                        width: 5.0,
                      ),
                      //TODO BUDGET FECTH OVER THE USER
                      Text(" 123123145 " , style: TextStyle( fontSize: 20.0),)
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 350,
              left: 50,
              right: 50,
              child:CustomTitle(_uid, _code, _email, "Reservations")
          ),
          Positioned(
              top: 400,
              left: 50,
              right: 50,
              //TODO RUTA A ACCIDENTES
              child:CustomTitleAccidents(_uid, _code, _email, "Accidents",_name)
          ),
          Positioned(
              top: 450,
              left: 50,
              right: 50,
              //TODO RUTA A COMPRAS
              child:CustomTitlePurchases(_uid, _code, _email, "Purchases",_name)
          )
        ],
      ),
    );
  }
}


class CustomTitle extends StatelessWidget {

  String title;
  String uidInfo;
  String code;
  String emial;
  CustomTitle(this.uidInfo, this.code, this.emial,this.title);

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
        //TODO SEEE
      },
    );
  }
}

class CustomTitleAccidents extends StatelessWidget {

  String name;
  String title;
  String uidInfo;
  String code;
  String emial;
  CustomTitleAccidents(this.uidInfo, this.code, this.emial,this.title,this.name);

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
        //TODO sss
      },
    );
  }
}

class CustomTitlePurchases extends StatelessWidget {

  String name;
  String title;
  String uidInfo;
  String code;
  String emial;
  CustomTitlePurchases(this.uidInfo, this.code, this.emial,this.title,this.name);

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
        //TODO PURCHASE VIEW
      },
    );
  }
}