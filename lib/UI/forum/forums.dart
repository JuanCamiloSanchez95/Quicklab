import 'package:flutter/material.dart';

class  ForumView extends StatefulWidget{
  @override
  _ForumView  createState() => new _ForumView();
}

class _ForumView extends State<ForumView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Forum  View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
    );
  }

}