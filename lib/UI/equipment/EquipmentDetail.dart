import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class  EquipmentDetailView extends StatefulWidget{
  final String id;
  final String application;
  final double cost;
  final String costtype;
  final String descrtip;
  final String image;
  final String name;
  final String type;

  EquipmentDetailView(this.id, this.application,this.cost,this.costtype,this.descrtip,this.image,this.name,this.type);
  @override
  _EquipmentDetailView  createState() => new _EquipmentDetailView();
}

class _EquipmentDetailView extends State<EquipmentDetailView>{


  final db= FirebaseFirestore.instance.collection('Equipment');
  dynamic data;
  String _idEquipment;
  String _name;
  String _applications;
  String _costType;
  String _description;
  String _image;
  double _cost;
  String _type;

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _name = widget.name;
    _applications = widget.application;
    _costType = widget.costtype;
    _description = widget.descrtip;
    _type = widget.type;
    _cost=widget.cost;
    _idEquipment = widget.id;
    _image = widget.image;
    super.initState();
  }

  Widget _loader(BuildContext context, String url){
    return  Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _error(BuildContext context, String url, dynamic error){
    print(error);
    return  Center(
      child: Icon(Icons.error_outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Equipment Detail View ' ),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ),
      body:  ListView(
          children: <Widget>[
            Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:  MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              Container(
                height: 200.0,
                width: 200.0,
                child: CachedNetworkImage(
                  imageUrl: _image,
                  placeholder: _loader,
                  errorWidget: _error,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30.0,4.0,30.0,0.0),
                child: Text(_description, style: TextStyle(fontSize: 12.0), textAlign: TextAlign.justify,),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(_name, style: TextStyle(fontSize: 30.0), textAlign: TextAlign.center),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.attach_money,
                      color: Colors.black,
                    ),
                    Text(
                      _cost.toString(), style: TextStyle(fontSize: 20.0, color: Colors.black), textAlign: TextAlign.center,
                    ),
                    Text(
                      " / ", style: TextStyle(fontSize: 20.0, color: Colors.black , fontWeight: FontWeight.w600), textAlign: TextAlign.center
                    ),
                    Flexible(
                      child: Text(
                          _costType , style: TextStyle(fontSize: 20.0, color: Colors.black), textAlign: TextAlign.center
                      ),
                    )
                  ]
              ),
            ],
          ),
            SizedBox(
              height: 10.0,
            ),
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(10.0,15.0,10.0,0.0),
                child: Text(
                  'Applications',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400
                  ),
                )
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15.0,8.0,15.0,0.0),
              alignment: Alignment.center,
              child: Text(_applications, style: TextStyle(fontSize: 15.0), textAlign: TextAlign.justify,),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(_type, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w800), textAlign: TextAlign.justify,),
            )
          ]
        ),
    );
  }
}