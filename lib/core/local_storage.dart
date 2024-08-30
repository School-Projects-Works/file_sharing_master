import 'package:file_sharing/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_strategy/url_strategy.dart';




class LocalStorage {
  static Future<void> initData() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    //open local storage box
    await Hive.openBox('file');
    
    setPathUrlStrategy();
  }

  //save data to local storage
  static void saveData(String key, String value) async{
    await Hive.box('file').put(key, value);
  }

  //get data from local storage
  static String? getData(String key) {
    return Hive.box('file').get(key);
  }

  //remove data from local storage
  static void removeData(String key) async{
    await Hive.box('file').delete(key);
  }
}
