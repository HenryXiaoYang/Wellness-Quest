import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService{
  static SharedPreferencesService? _instance;
  static late SharedPreferences _preferences;

  SharedPreferencesService._();

  // Using a singleton pattern
  static Future<SharedPreferencesService> getInstance() async {
    _instance ??= SharedPreferencesService._();
    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  //keep track of the notes index number
  //notes: "notes_index"->"title" "content" "date"
  void storeToken(String token){
    _preferences.setString("token",token);
  }
  String getToken(){
    return _preferences.getString("token") ?? "fail";
  }
}