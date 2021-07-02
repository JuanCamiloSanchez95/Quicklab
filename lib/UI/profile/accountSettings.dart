import 'package:flutter/material.dart';

class  SettingsView extends StatefulWidget{
  @override
  _SettingsView  createState() => new _SettingsView();
}

class _SettingsView extends State<SettingsView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Account Settings  View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
    );
  }

}