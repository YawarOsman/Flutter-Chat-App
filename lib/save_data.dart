import 'package:shared_preferences/shared_preferences.dart';

class SaveData{
  static  String loggedIn="ISLOGGEDIN";
  static  String userName="USERNAME";
  static String userEmail="USEREMAIL";

  static Future<bool> saveLoggedIn(bool isLoggedIn)async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.setBool(loggedIn, isLoggedIn);
  }
  static Future<bool> saveUserName(String user_name)async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.setString(userName, user_name);
  }
  static Future<bool> saveUserEmail(String user_email)async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.setString(userEmail, user_email);
  }

  static Future<bool?> getLoggedIN()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.getBool(loggedIn);
  }
  static Future<String?> getUserName()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.getString(userName);
  }
  static Future<String?> getUserEmail()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    return await pref.getString(userEmail);
  }

}