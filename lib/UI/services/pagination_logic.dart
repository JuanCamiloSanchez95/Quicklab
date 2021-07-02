import 'package:flutter/cupertino.dart';

class PaginationLogic extends ChangeNotifier{
  List items;
  bool loading=false;


  void loadData() async{
      loading=true;
      notifyListeners();
      //obtener datos
      if(items==null){
        items=[];
      }
      loading=false;
      notifyListeners();
  }
}