import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIDKey = "USERKEY";
  static String userNameKey = "USERNAME";
  static String userEmailKey = "EMAIL";
  static String userPhotoKey = "USERPIC";
  static String displayNameKey = "USERDISPLAYNAME";

  Future<bool> saveUserId(String getUserID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userIDKey, getUserID);
  }

  Future<bool> saveUserDisplayName(String getUserDisplayName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(displayNameKey, getUserDisplayName);
  }

  Future<bool> saveEmailKey(String getUserEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserPhoto(String getUserPhoto) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userPhotoKey, getUserPhoto);
  }

  Future<String?> getUserId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userIDKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userNameKey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(displayNameKey);
  }

  Future<String?> getUseremail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userEmailKey);
  }

  Future<String?> getUserPhoto() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userPhotoKey);
  }
}
