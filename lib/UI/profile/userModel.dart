//CLASS THAT MODELS A USER ON THE
class QuickLabUser{
  String uid;
  String name;
  String email="";
  int code=0;
  String role="";
  QuickLabUser({this.uid,this.name,this.email,this.code,this.role});

  static List<String> getRoles(){
    return <String>[
      "Student",
      "Monitor",
    ];
  }
}