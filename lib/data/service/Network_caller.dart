import 'dart:convert';
import 'dart:io'; // For SocketException
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:task_manager/data/Ui/controller/auth_controller.dart';
import '../../screejn/sign_In.dart';
import '../../design/widgets/app.dart';

class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;
  final bool isFromCache; // <-- Add this to know if data came from cache

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
    this.isFromCache = false,
  });
}

class NetworkCaller {
  static const String _defaultErrorMessage = 'Something Went Wrong';
  static const String _unAuthorizedMessage = 'Un-Authorized';

  // ================== GET request ==================
  static Future<NetworkResponse> getRequest({required String url}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'token': AuthController.accessToken ?? ''
    };

    try {
      // Check connectivity
      bool online = await _hasNetworkConnection();

      if (!online) {
        // No internet → load cached data
        final cached = await _getCachedResponse(url);
        if (cached != null) {
          debugPrint("⚙️ Loaded cached data for $url");
          return NetworkResponse(
            isSuccess: true,
            statusCode: 200,
            body: cached,
            isFromCache: true,
          );
        } else {
          return NetworkResponse(
            isSuccess: false,
            statusCode: -1,
            errorMessage: "No Internet and no cached data found.",
          );
        }
      }

      _logRequest(url, null, headers);
      final response = await get(Uri.parse(url), headers: headers);
      _logResponse(url, response);

      // Process response and cache if success
      final processed = _processResponse(response);
      if (processed.isSuccess && processed.body != null) {
        await _cacheResponse(url, processed.body!);
      }

      return processed;
    } on SocketException {
      // Network error → fallback to cache
      final cached = await _getCachedResponse(url);
      if (cached != null) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          body: cached,
          isFromCache: true,
        );
      }
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: "No Internet Connection",
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ================== POST request ==================
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (!isFromLogin) 'token': AuthController.accessToken ?? ''
    };

    try {
      _logRequest(url, body?.map((k, v) => MapEntry(k, v.toString())), headers);
      final response = await post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);
      return _processResponse(response, isFromLogin: isFromLogin);
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ================== PRIVATE HELPERS ==================

  static void _logRequest(
      String url, Map<String, String>? body, Map<String, String>? headers) {
    debugPrint(
        '==============Request================\nUrl: $url\nHEADERS: $headers\nBODY: $body\n=================Request End==============');
  }

  static void _logResponse(String url, Response response) {
    debugPrint(
        '==============Response===============\nUrl: $url\nSTATUS CODE: ${response.statusCode}\nBODY: ${response.body}\n===============Response End===============');
  }

  static NetworkResponse _processResponse(Response response,
      {bool isFromLogin = false}) {
    try {
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      } else if (response.statusCode == 401) {
        if (!isFromLogin) _handleUnauthorized();
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: _unAuthorizedMessage,
        );
      } else {
        return NetworkResponse(
          isSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decoded['data'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<void> _handleUnauthorized() async {
    await AuthController.clearData();
    if (Taskmanager.navigator.currentContext != null) {
      Navigator.of(Taskmanager.navigator.currentContext!)
          .pushNamedAndRemoveUntil(SignIn.name, (route) => false);
    }
  }

  // ================== CACHING ==================
  static Future<void> _cacheResponse(String url, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(url, jsonEncode(body));
  }

  static Future<Map<String, dynamic>?> _getCachedResponse(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(url);
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> _hasNetworkConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
