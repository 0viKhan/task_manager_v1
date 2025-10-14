import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_models.dart';

class AuthController {
  static UserModel? userModel;
  static String? accessToken;


  static Future<void> saveUserData(UserModel model, String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('user-data', jsonEncode(model.toJson()));
    await sharedPreferences.setString('token', token);
    userModel = model;
    accessToken = token;
  }


  static Future<bool> isUserLoggedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    if (token != null && token.isNotEmpty) {
      accessToken = token;
      String? userData = sharedPreferences.getString('user-data');
      if (userData != null) {
        userModel = UserModel.fromJson(jsonDecode(userData));
      }
      return true;
    }
    return false;
  }

  static Future<void> clearData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    accessToken = null;
    userModel = null;
  }
}
