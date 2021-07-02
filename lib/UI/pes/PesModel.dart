class Pes {
  bool deparment=false;
  DateTime date;
  String courses="";
  String teacher="";
  String description="";
  String equipment="";
  String material="";
  String user="";
  String lab="";
  String status="";
  Pes(this.courses,this.date, this.description, this.lab ,this.equipment,this.material,this.deparment,this.teacher,this.user, this.status);
}


class Laboratory{
  String labName;
  int id;
  Laboratory(this.id,this.labName);

  static List<Laboratory> getLaboratories(){
    return <Laboratory>[
      Laboratory(1,"ML-206"),
      Laboratory(2,"ML-305"),
      Laboratory(3,"ML-307"),
      Laboratory(4,"ML-416"),
      Laboratory(5,"ML-418"),
    ];
  }
}

class Status{
  String description;
  int id;
  Status(this.id,this.description);

  static List<Status> getStatus(){
    return <Status>[
      Status(1,"Accepted"),
      Status(2,"Rejected"),
      Status(3,"Revision"),
      Status(4,"Incompleted"),
    ];
  }
}
