import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:task_manager/data/Ui/controller/auth_controller.dart';
import '../../design/widgets/app.dart';
import '../../screejn/sign_In.dart';


class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;

  NetworkResponse(
      {required this.isSuccess, required this.statusCode, this.body, this.errorMessage});
}

class NetworkCaller {
  static const String _defaultErrorMessage = 'Something Went Wrong';
  static const String _unAuthorizedMessage = 'Un-Authorized-token';


  static Future<NetworkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      final headers = {
        'Content-Type': 'application/json',
        'token': AuthController.accessToken ?? ''
      };
      _logRequest(url, null, headers);

      Response response = await get(uri, headers: headers);
      _logResponse(url, response);

      if (response.statusCode == 200) {
        final decodedjson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decodedjson,
        );
      } else if (response.statusCode == 401) {
        await _handleUnauthorized();
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizedMessage,
        );
      } else {
        final decodedjson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodedjson['data'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
          isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }


  static Future<NetworkResponse> postRequest(
      {required String url, Map<String, String>? body, bool isFromLogin = false}) async {
    try {
      Uri uri = Uri.parse(url);
      final headers = {
        'Content-Type': 'application/json',
        if (!isFromLogin) 'token': AuthController.accessToken ?? ''
      };

      _logRequest(url, body, headers);
      Response response = await post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);

      if (response.statusCode == 200) {
        final decodedjson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decodedjson,
        );
      } else if (response.statusCode == 401) {
        if (!isFromLogin) {
          await _handleUnauthorized();
        }
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizedMessage,
        );
      } else {
        final decodedjson = jsonDecode(response.body);
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodedjson['data'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(isSuccess: false, statusCode: -1, errorMessage: e.toString());
    }
  }

  static void _logRequest(String url, Map<String, String>? body, Map<String, String>? headers) {
    debugPrint(
        '==============Request================\nUrl:$url\nHEADERS:$headers\nBODY:$body\n=================Request End==============');
  }

  static void _logResponse(String url, Response response) {
    debugPrint(
        '===============Response===============\nUrl:$url\nSTATUS CODE:${response.statusCode}\nBODY:${response.body}\n===============Response End===============');
  }

  static Future<void> _handleUnauthorized() async {
    await AuthController.clearData();
    Navigator.of(Taskmanager.navigator.currentContext!)
        .pushNamedAndRemoveUntil(SignIn.name, (predicate) => false);
  }
}
