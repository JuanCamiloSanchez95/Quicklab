import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/**
 * Custom title for the drawer
 * */
class CustomDrawerTitle extends StatelessWidget{
  IconData icon;
  String text;
  Function onTap;
  CustomDrawerTitle(this.icon,this.text,this.onTap);

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
              Icon(Icons.arrow_right)
            ],
          ),
        ),
        onTap: onTap
    );
  }
}

