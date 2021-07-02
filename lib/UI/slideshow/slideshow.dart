import 'package:flutter/material.dart';

class  SlideshowView extends StatefulWidget{
  @override
  _SlideshowView  createState() => new _SlideshowView();
}

class _SlideshowView extends State<SlideshowView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Sildeshow  View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ),
    );
  }

}