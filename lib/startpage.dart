import 'package:flutter/material.dart';
import 'package:quicklab/loginPage.dart';


class startActivity extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'QuickLab Demo',
        theme: ThemeData(primaryColor: Color(0xff598EA9)),
        home: Scaffold(
          body: Center(
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    //SvgPicture.asset('assets/icons/logoFirstPage.svg'),
                    Image.asset('assets/LogoQuickLab.JPG'),
                    Text( 'QuickLab ', style: const TextStyle(fontSize: 40.0, color: Colors.black,fontWeight: FontWeight.w600, fontStyle: FontStyle.italic ) ) ,
                    Text( 'With Quicklab you will have a faster and more satisfactory experience in your laboratory reservations ', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20.0, color: Colors.grey,fontWeight: FontWeight.w600)),
                    SizedBox(height: 10.0),
                    BotonGo(),
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ],
            ),
          ),
        )
    );
  }
}

//BUTTON RESPONSIBLE OF THE NAVIGATION TO THE LOGIN PAGE
class BotonGo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
   return new FlatButton(
        color: Color(0xff598EA9),
        highlightColor: Colors.blue,
        onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder:  (context) => Login()));
        },
        shape: StadiumBorder(),
        child: Text("GO!", style: const TextStyle(color: Colors.white70))
    );
  }
}

