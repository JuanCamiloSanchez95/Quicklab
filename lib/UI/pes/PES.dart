import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:quicklab/UI/QR/scan.dart';
import 'package:quicklab/UI/budget/Budget.dart';
import 'package:quicklab/UI/equipment/Equipment.dart';
//PAGES
import 'package:quicklab/UI/pes/SuccesfulView.dart';
import 'package:quicklab/UI/pes/pesHistory.dart';
import 'package:quicklab/UI/profile/profile.dart';
import 'package:quicklab/UI/profile/profileInfo.dart';
import 'package:quicklab/UI/reagents/reagents.dart';
import 'package:quicklab/UI/services/authentication.dart';
import 'package:quicklab/UI/utilities/CustomDrawer.dart';
import 'package:quicklab/UI/utilities/SharedPreferencesUsage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../loginPage.dart';
import 'PesModel.dart';


class  PesView extends StatefulWidget{

  final String uid;
  final String code;
  final String email;
  final String robustBudget;
  final String nonRobustBudget;
  final String realtBudget;
  String username;
  PesView(this.email, this.uid, this.username, this.code, this.robustBudget,this.nonRobustBudget,this.realtBudget);
  @override
  _PesView  createState() => new _PesView();
}


class _PesView extends State<PesView>{


  String _selectedLab;
  String _selectedMaterial;
  String _selectedProfessor;
  String _selectedEquipment;
  String _selectedCourse;

  final AuthService _authS = AuthService();
  String _email;
  String _uid;
  String _code;
  String _robustBudget;
  String _nonRobustBudget;
  String _realBudget;

  final _formkey =  GlobalKey<FormState>();
  String _course="";
  DateTime _date;
  bool _memberChemicalDepartment =false;
  String _userName="";
  String _experiment="";
  bool _checkBoxYes=false;
  bool _checkBoxNo=false;
  //CONTROLLERS
  TextEditingController _courseController;
  TextEditingController _activityController;




  //METHOD THAT SAVED THE INFORMATION OF THE PES FORMAT IN PREFERENCES
  void setInformationPes() async{
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        preferences.setString('courses',_course);
        preferences.setString('activity',_experiment);
      });
    }
    catch(e){
      print(e);
    }
  }

  Future errasePes()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('courses');
    preferences.remove('activity');
  }


  @override
  void initState()  {
    _userName =  widget.username;
    _email = widget.email;
    _uid = widget.uid;
    _code = widget.code;
    _robustBudget = widget.robustBudget;
    _nonRobustBudget = widget.nonRobustBudget;
    _realBudget = widget.realtBudget;
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _course = value.getString('courses');
        _experiment = value.getString('activity');
        _courseController = new TextEditingController(text: _course);
        _activityController = new TextEditingController(text:  _experiment);
      });
    });
  }

  onChangeDropDownItemlab(String selectedActual){
    setState(() {
      _selectedLab = selectedActual;
    });
  }

  onChangeDropDownItemEquip(String selectedActual){
    setState(() {
      _selectedEquipment = selectedActual;
    });
  }

  onChangeDropDownItemMaterial(String selectedActual){
    setState(() {
      _selectedMaterial = selectedActual;
    });
  }

  onChangeDropDownItemProffesor(String selectedActual){
    setState(() {
      _selectedProfessor = selectedActual;
    });
  }

  onChangeDropDownItemCourse(String selectedActual){
    setState(() {
      _selectedCourse = selectedActual;
    });
  }



  Future _signOut() async {
    logOut();
    await _authS.signOut();
  }

  @override
  Widget build(BuildContext context) {

    Future<void> sendPes() async{
      _date = new DateTime.now();
      Pes registrering = Pes(_selectedCourse,_date, _experiment,_selectedLab, _selectedEquipment,_selectedMaterial,_memberChemicalDepartment,_selectedProfessor, _userName, "pendient");
      FirebaseFirestore.instance.collection('pes').doc().set({
        'course': _selectedCourse,
        'date': _date,
        'experiment': _experiment,
        'laboratory' : _selectedLab,
        'laboratoryEquipment': _selectedEquipment,
        'laboratoryMaterial': _selectedMaterial,
        'memberChemicalDepartment': _memberChemicalDepartment,
        'professor': _selectedProfessor,
        'userName':_userName,
        'status': "Waiting"
      });
      errasePes();
      Navigator.push(context, MaterialPageRoute(builder:  (context) => SuccesfulView()));
    }

    //DIALOG FOR INTERNET SECURE
    _showDialog(tittle, text){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text(tittle),
              content: Text(text),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder:  (context) => PesView(_email, _uid, _userName, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                  },
                )
              ],
            );
          }
      );
    }

    //CONNECTIO CONFIRMATION
    _checkInternetConnectivity() async{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none){
        _showDialog("No internet", "Try again when connected to a net");
        setInformationPes();
      }
      else if(result == ConnectivityResult.wifi){
        sendPes();
        errasePes();
      }
      if(result == ConnectivityResult.mobile){
        sendPes();
        errasePes();
      }
    }

    final buttonPes = Material(
        color: Color(0xff598EA9),
        borderRadius: BorderRadius.circular(25.0),
        child: FlatButton(
            highlightColor: Colors.blue,
            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
            onPressed: () async {
                if(_formkey.currentState.validate()){
                  await _checkInternetConnectivity();
                }
              else{
                setInformationPes();
                showDialog(
                  context: context,
                  builder: (context)=> AlertDialog(
                    title: Text("Error"),
                    content: Text("Error in the form  \n please fill all the spaces "),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("OK"),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder:  (context) => PesView(_email, _uid, _userName, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                        },
                      )
                    ],
                  ),
                );
              }
            },
            child: Text("SEND ", style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,)
        )
    );





    return Scaffold(
      appBar: new AppBar(
          title: new Text('PES  View'),
        centerTitle: true,
        backgroundColor: Color(0xff8ADEDB),
      ) ,
        drawer: new Drawer(
          child: ListView(
              children: <Widget>[
                new UserAccountsDrawerHeader(accountName:  new Text(_userName), accountEmail: new Text(_email),
                  currentAccountPicture: new CircleAvatar(
                      backgroundImage:  new AssetImage('assets/Login.JPG')
                  ) ,
                ),
                CustomDrawerTitle(Icons.home,'  Home',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new  profileActivity()));
                }),
                CustomDrawerTitle(Icons.person,'  Profile',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new profileView(_email, _uid , _userName, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                }),
                CustomDrawerTitle(Icons.center_focus_strong,'  QR Scan',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new ScanView(_email, _uid , _userName, _code , _robustBudget, _nonRobustBudget, _realBudget)));
                }),
                CustomDrawerTitle(Icons.computer,'  Equipment',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new EquipmentView(_email, _uid , _userName, _code,_robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.monetization_on,'  Budget',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new BudgetView(_email, _uid, _userName, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.description,'  PES',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new pesHistory(_email, _uid, _userName, _code, _robustBudget, _nonRobustBudget,_realBudget)));
                }),
                CustomDrawerTitle(Icons.invert_colors, '  Reagents',(){
                  Navigator.push(context, new
                  MaterialPageRoute(builder:  (context) => new ReagentsView(_email, _uid , _userName, _code , _robustBudget, _robustBudget, _robustBudget)));
                }),
                CustomDrawerTitle(Icons.exit_to_app,'  Log Out', () {
                  _signOut().whenComplete(() {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => Login()));
                  });
                })
              ]
          ),
        ),
      body: Form(
        key: _formkey,
        child: Container(
            child: ListView(
            padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
            children: <Widget>[
              Container(
                height: 50.0,
                color: Color(0xff598EA9) ,
                child:  Text('Do you belong to the Deparment of   \n Chemical and Food Engineering?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              spacePadd(),
              Row(
                children: <Widget>[
                  Checkbox(value: _checkBoxYes, onChanged: (bool val) {
                    if(_checkBoxNo==true || _checkBoxYes == false ){
                      setState(() {
                        _memberChemicalDepartment=true;
                        _checkBoxNo=false;
                      });
                    }
                    setState(() {
                      _checkBoxYes=val;
                    });
                  }),
                  Text('Yes', style: const TextStyle(color: Colors.black, fontSize: 20.0)),
                ],
              ),
              spacePadd(),
              Row(
                children: <Widget>[
                  Checkbox(value: _checkBoxNo, onChanged: (bool val){
                    if(_checkBoxYes== true || _checkBoxNo == false){
                      setState(() {
                        _memberChemicalDepartment=false;
                        _checkBoxYes=false;
                      });
                    }
                    setState(() {
                        _checkBoxNo=val;
                    });
                  }),
                  Text('No', style: const TextStyle(color: Colors.black, fontSize: 20.0)),
                ],
              ),
            spacePadd(),
              Container(
                height: 50.0,
                color: Color(0xff598EA9) ,
                child:  Text('For wich course of the project do you request  \n this PES?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("courses").snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  else{
                    List<DropdownMenuItem> courseItem =[];
                    for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                      DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                      courseItem.add(
                          DropdownMenuItem(
                            child: SizedBox(
                              width: 200.0,
                              child: Text(
                                docSnapshot['name'], overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value:"${docSnapshot['name']}" ,
                          )
                      );
                    }
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedCourse ,
                              items: courseItem,
                              onChanged: (courseValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected course value is $courseValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedCourse = courseValue;
                                });
                              }
                          )
                        ],
                      );
                  }
                },
              ),
              spacePadd(),
              Container(
                height: 30.0,
                color: Color(0xff598EA9) ,
                child:  Text('Who is the teacher?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              spacePadd(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("professors").snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  else{
                    List<DropdownMenuItem> teacherItem =[];
                    for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                      DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                      teacherItem.add(
                          DropdownMenuItem(
                            child: SizedBox(
                              width: 200.0,
                              child: Text(
                                docSnapshot['name'], overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value:"${docSnapshot['name']}" ,
                          )
                      );
                    }
                    return  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedProfessor ,
                              items: teacherItem,
                              onChanged: (teacherValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected teacher value is $teacherValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedProfessor = teacherValue;
                                });
                              }
                          )
                        ],
                    );
                  }
                },
              ),
              spacePadd(),
              Container(
                height: 30.0,
                color: Color(0xff598EA9) ,
                child:  Text('Description of the activity?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              spacePadd(),
              Container(
                height: 50.0,
                child: TextFormField(
                  controller: _activityController,
                  //Validation of empty space
                  validator: (_val){
                    if(_val.isEmpty){
                      return 'Cannot be Empy';
                    }
                    else{
                      return null;
                    }
                  },
                  //Update of the value on the text field
                  onChanged: (val){
                    setState(() => _experiment =val);
                  },
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Experiment',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              spacePadd(),
              Container(
                height: 30.0,
                color: Color(0xff598EA9) ,
                child:  Text('laboratories require?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("laboratory").snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  else{
                    List<DropdownMenuItem> laboratoryItem =[];
                    for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                      DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                      laboratoryItem.add(
                          DropdownMenuItem(
                            child: SizedBox(
                              width: 200.0,
                              child: Text(
                                docSnapshot['name'], overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value:"${docSnapshot['name']}" ,
                          )
                      );
                    }
                    return  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedLab ,
                              items: laboratoryItem,
                              onChanged: (equipValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected laboratory value is $equipValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedLab = equipValue;
                                });
                              }
                          )
                        ],
                    );
                  }
                },
              ),
              spacePadd(),
              Container(
                height: 50.0,
                color: Color(0xff598EA9),
                child:  Text('laboratory  equipment  require ?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("equipment").snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  else{
                    List<DropdownMenuItem> equipmentItem =[];
                    for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                      DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                      equipmentItem.add(
                          DropdownMenuItem(
                            child: SizedBox(
                              width: 200.0,
                              child: Text(
                                docSnapshot['name'], overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value:"${docSnapshot['name']}" ,
                          )
                      );
                    }
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedEquipment ,
                              items: equipmentItem,
                              onChanged: (equipmentValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected material value is $equipmentValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedEquipment = equipmentValue;
                                });
                              }
                          )
                        ],
                    );
                  }
                },
              ),
              spacePadd(),
              Container(
                height: 30.0,
                color: Color(0xff598EA9) ,
                child:  Text('Which material do you require  ?', style: const TextStyle(color: Colors.white, fontSize: 20.0), textAlign: TextAlign.center),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("material").snapshots(),
                builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Text("Loading");
                  }
                  else{
                    List<DropdownMenuItem> materialitem =[];
                    for(int i = 0 ; i < snapshot.data.docs.length ; i++){
                      DocumentSnapshot docSnapshot = snapshot.data.docs[i];
                      materialitem.add(
                          DropdownMenuItem(
                            child: SizedBox(
                              width: 200.0,
                              child: Text(
                                docSnapshot['name'], overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            value:"${docSnapshot['name']}" ,
                          )
                      );
                    }
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DropdownButton(
                              value: _selectedMaterial ,
                              items: materialitem,
                              onChanged: (materialValue){
                                final snacBar = SnackBar(
                                  content: Text(
                                    'Selected material value is $materialValue', overflow: TextOverflow.ellipsis,
                                  ),
                                );
                                Scaffold.of(context).showSnackBar(snacBar);
                                setState(() {
                                  _selectedMaterial = materialValue;
                                });
                              }
                          )
                        ],
                    );
                  }
                },
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              buttonPes
            ],
          ),
        ),
      )
    );
  }
}

class spacePadd extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    );
  }
}

