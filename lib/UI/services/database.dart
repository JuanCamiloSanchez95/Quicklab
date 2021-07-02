import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quicklab/UI/profile/userModel.dart';

class DatabaseService {

  final String uid;
  DatabaseService({this.uid});

  //COLLECTION REFERENCE
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference workersCollection = FirebaseFirestore.instance.collection('workers');
  final CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');

  Future updateUserData(String name, String code, String email, String role) async{
    return await userCollection.doc(uid).set({
      'name':name,
      'code':code,
      'email': email,
      'role' : role
    });
  }

  Future setUserData(String email, String role) async{
    return await userCollection.doc(uid).set({
      'email': email,
      'role' : role
    });
  }

  Future setWorkerData(String email, String name, String laboratory)async{
    return await workersCollection.doc(uid).set({
      'email': email,
      'laboratory' : laboratory,
      'name': name
    });
  }

  Future setStudentData(String code, String email, String name, String picture, String role)async{
    return await studentsCollection.doc(uid).set({
      'code':code,
      'courses':"",
      'email': email,
      'name':name,
      'picture' : picture,
      'role' : role
    });
  }


  //get user doc stream
 getUserById() async {
    print( userCollection.doc(uid).get());
return userCollection.doc(uid).snapshots();
}

  //get user stream
  Stream<QuerySnapshot> get users{
    return userCollection.snapshots();
  }

}