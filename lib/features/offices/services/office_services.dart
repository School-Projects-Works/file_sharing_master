import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/office_model.dart';

class OfficeServices{
  static final CollectionReference officeCollection = FirebaseFirestore.instance.collection('offices');

  static Future<bool> createOffice(OfficeModel office) async {
    try {
      await officeCollection.doc(office.id).set(office.toMap());
      return true;
    } catch (e) {
      return false;
    }

  }

  static Future<OfficeModel?> getOffice(String id) async {
    try {
      var office = await officeCollection.doc(id).get();
      return OfficeModel.fromMap(office.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateOffice(OfficeModel office) async {
    try {
      await officeCollection.doc(office.id).update(office.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<OfficeModel>> getOffices() {
    return officeCollection.snapshots().map((snapshot) => snapshot.docs.map((doc) => OfficeModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  static String getOfficeId() {
    return officeCollection.doc().id;
  }

  static deleteOffice(affiliation)async {
    await officeCollection.doc(affiliation.id).delete();
  }
}