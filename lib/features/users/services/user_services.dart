import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_sharing/features/users/data/user_model.dart';

class UserServices{
  static CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  static Future<bool> createUser(UserModel user) async {
    try {
      await userCollection.doc(user.id).set(user.toMap());
      return true;
    } catch (e) {
      return false;
    }

  }

  static Future<UserModel?> getUser(String id) async {
    try {
      var user = await userCollection.doc(id).get();
      return UserModel.fromMap(user.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUser(UserModel user) async {
    try {
      await userCollection.doc(user.id).update(user.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<UserModel>> getUsers() {
    return userCollection.snapshots().map((snapshot) => snapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}