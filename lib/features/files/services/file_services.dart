import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_sharing/features/files/data/file_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileServices {
  static final CollectionReference fileCollection =
      FirebaseFirestore.instance.collection('files');
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static Future<bool> createFile(FileModel file) async {
    try {
      await fileCollection.doc(file.id).set(file.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<FileModel?> getFile(String id) async {
    try {
      var file = await fileCollection.doc(id).get();
      return FileModel.fromMap(file.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateFile(FileModel file) async {
    try {
      await fileCollection.doc(file.id).update(file.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<FileModel>> getFiles() {
    return fileCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FileModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  static Future<String> uploadFile(Uint8List data, String id) async {
    try {
      var ref = storage.ref().child('files/$id');
      await ref.putData(data);
      return await ref.getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  static String getId() {
    return fileCollection.doc().id;
  }

  static Future<bool> deleteFile(String id) async {
    try {
      await fileCollection.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
