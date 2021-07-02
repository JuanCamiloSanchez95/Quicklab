//PACKAGES
import 'package:flutter/material.dart';
//PAGES
import 'package:quicklab/UI/profile/profile.dart';

class SuccesfulView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Material(
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('PES  View'),
          centerTitle: true,
          backgroundColor: Color(0xff8ADEDB),
        ) ,
        body: new Center(
          child: ListView(
            children: <Widget>[
            Column(
              children: <Widget>[
                new Image.asset('assets/SuccesPes.JPG'),
                Container(
                  width: 400,
                  color: Color(0xffbcf1ff),
                  child:  Text( 'Your PES has been sent succesfully ', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20.0, color: Colors.grey,fontWeight: FontWeight.w600)),
                ),
                new SizedBox(height: 10.0),
                FlatButton(
                    color: Color(0xff598EA9),
                    highlightColor: Colors.blue,
                    padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder:  (context) => profileActivity()));
                    },
                    child: Text("Go Back To Home", style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,)
                )
              ],
              mainAxisSize: MainAxisSize.min,
            )],
          ),
        ),
      ),
    );
  }
}

