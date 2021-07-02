import 'package:flutter/material.dart';

class  CoursesView extends StatefulWidget{
  @override
  _CoursesView  createState() => new _CoursesView();
}

class _CoursesView extends State<CoursesView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Courses  View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
    );
  }

}