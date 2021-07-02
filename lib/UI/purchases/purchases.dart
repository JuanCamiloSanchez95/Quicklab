import 'package:flutter/material.dart';

class  PurchaseView extends StatefulWidget{
  @override
  _PurchaseView  createState() => new _PurchaseView();
}

class _PurchaseView extends State<PurchaseView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Purchase history'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
    );
  }

}