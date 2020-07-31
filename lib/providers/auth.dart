import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/http_exception.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  Future<String> get userName async {
    final prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getString('username');
  }

  bool get isAuth => token != null;
  String get userId => _userId;

  Future<void> _authenticate(String mode, String email, String password) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$mode?key=AIzaSyBse6NP5VQipm1kEYpl3RLO8G7_X4uFdTA';
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      var body = json.decode(res.body);
      if (body['error'] != null) {
        throw HttpException(body['error']['message']);
      }
      _token = body['idToken'];
      _userId = body['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            body['expiresIn'],
          ),
        ),
      );
    } catch (error) {
      throw error;
    }
    _autoLogout();
    notifyListeners();
  }

  Future<void> signup(String userName, String email, String password) async {
    await _authenticate('signUp', email, password);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', userName);
  }

  Future<void> login(String email, String password) async {
    await _authenticate('signInWithPassword', email, password);
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
