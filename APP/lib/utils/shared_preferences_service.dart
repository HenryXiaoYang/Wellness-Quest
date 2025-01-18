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
  int getIndex(){
    return _preferences.getInt("notes_index") ?? 1;
  }
  void increaseNotesIndex(){
    int val=getIndex();
    _preferences.setInt("notes_index",val+1);
  }
  void decreaseNotesIndex(){
    int val=getIndex();
    _preferences.setInt("notes_index",val-1);
  }

  List<String>? getNotes(int index){
    return _preferences.getStringList("note_$index");
  }

  void addNotes(String title, String content){
    int index=getIndex();
    _preferences.setStringList("note_$index", <String>[title,content]);
  }
}