import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cx_playground/models/email_already_in_use_exception.dart';
import 'package:cx_playground/models/incorrect_password_exception.dart';
import 'package:cx_playground/models/user_doesnt_exist_exception.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import '../models/http_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

///Class with all methods related to user log in, log out and account registration
class Auth with ChangeNotifier {
  final String _ip = GlobalConfiguration().getValue("ip");
  String _token = '';
  DateTime _expiryDate = DateTime.now();
  String _userId = '';
  bool _isAdmin = false;
  int avatarNumber = -1;
  String _email = '';
  String _username = '';
  Timer _authTimer = Timer(const Duration(days: 51), () {});

  Auth(
      [this._userId = '',
      this._username = '',
      this._email = '',
      this._isAdmin = false,
      this.avatarNumber = -1]);

  ///Checks if an user is logged in
  bool get isAuth {
    return _token != '';
  }

  ///Getter of isAdmin bool
  bool get isAdmin {
    return _isAdmin;
  }

  ///Getter of userId
  String get userId {
    return _userId;
  }

  ///Getter of username
  String get username {
    return _username;
  }

  ///Getter of email
  String get email {
    return _email;
  }

  ///Gets the user picture from the server
  Future<int> getPictureId(String email) async {
    int pictureId = -1;
    Uri url = Uri.parse("http://6d74-193-137-92-95.eu.ngrok.io");
    try {
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.get(url, headers: {'getAvatar': email});
      if (response.statusCode != 200) {
        throw HttpException;
      }
      pictureId = int.parse(response.body);
    } catch (error) {
      rethrow;
    }
    notifyListeners();
    return pictureId;
  }

  ///Getter of the user token
  String get token {
    if (_token != '' && _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return '';
  }

  ///Method used to register the user in the system
  ///
  /// Throws [EmailAlreadyInUseException] if the email is already registered in the database
  /// Throws [HttpException] for generic server and database errors
  Future<void> signup(
      String username, String email, String password, int pictureId) async {
    Uri url = Uri.parse("http://6d74-193-137-92-95.eu.ngrok.io");
    if (pictureId == -1) pictureId = 0;
    try {
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Insecure Communications: Sensitive Information Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(url, headers: {
        'signup': username,
        'email': email,
        'password': password,
        'avatarNumber': pictureId.toString()
      });
      if (response.statusCode != 200) {
        if (response.statusCode == 506) {
          throw EmailAlreadyInUseException();
        } else {
          throw HttpException;
        }
      }
      _token = 'notSet';
      _email = email;
      _username = username;
      _userId = username;
      avatarNumber = pictureId;
      _expiryDate = DateTime.now().add(const Duration(days: 30));
      _isAdmin = false;
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      rethrow;
    }
  }

  ///Method used to log the user in the system
  ///
  /// Throws [UserDoesntExistException] if the user is not registered in the database
  /// Throws [IncorrectPasswordException] if the password doesn't match the one set up before
  /// Throws [HttpException] for generic server and database errors
  Future<void> login(String email, String password) async {
    try {
      final conn = await MySQLConnection.createConnection(
          host: GlobalConfiguration().getValue("host"),
          port: GlobalConfiguration().getValue("port"),
          userName: GlobalConfiguration().getValue("userName"),
          password: GlobalConfiguration().getValue("password"),
          databaseName: GlobalConfiguration().getValue("databaseName"));
      await conn.connect();

      ///Vulnerability: Self SQL Injection
      ///Remove direct communication with database and use the server
      var results = await conn.execute(
          "SELECT idUser, username, bin(isAdmin) as isAdmin, avatarNumber FROM user WHERE email = '$email' and password = '$password'");
      for (final row in results.rows) {
        _token = 'notSet';
        _email = email;
        _userId = row.assoc()['idUser']!;
        _username = row.assoc()['username']!;
        avatarNumber = int.parse(row.assoc()['avatarNumber']!);
        _expiryDate = DateTime.now().add(const Duration(days: 30));
        _isAdmin = row.assoc()['isAdmin'] == '1' ? true : false;
        _autoLogout();
        notifyListeners();
        final userData = json.encode({
          'token': _token,
          'idUser': _userId,
          'username': _username,
          'expiryDate': _expiryDate.toIso8601String(),
          'email': email,
          'avatarNumber': avatarNumber
        });
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;
        await File('$appDocPath/userData.json').writeAsString(userData);
        return;
      }
    } catch (error) {
      rethrow;
    }
  }

  ///Checks if an ser has administrator privileges based on his email
  /// Throws [HttpException] for generic server and database errors
  Future<bool> isAdminEmail(String email) async {
    Uri url = Uri.parse("http://6d74-193-137-92-95.eu.ngrok.io");

    try {
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.get(url, headers: {'isAdmin': email});
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw HttpException;
      }
      return responseData['isAdmin'];
    } catch (error) {
      rethrow;
    }
  }

  ///Checks if the user data stored in the device is still valid and tries to perform auto log in
  Future<bool> tryAutoLogin() async {
    final path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);
    if (!await File('$path/userData.json').exists()) {
      return false;
    }
    final input = await File('$path/userData.json').readAsString();
    print(input);
    final extractedUserData = json.decode(input);
    try {
      final conn = await MySQLConnection.createConnection(
          host: GlobalConfiguration().getValue("host"),
          port: GlobalConfiguration().getValue("port"),
          userName: GlobalConfiguration().getValue("userName"),
          password: GlobalConfiguration().getValue("password"),
          databaseName: GlobalConfiguration().getValue("databaseName"));
      await conn.connect();
      final expiryDate =
          DateTime.parse(extractedUserData['expiryDate']! as String);
      if (expiryDate.isBefore(DateTime.now())) {
        return false;
      }

      ///Vulnerability Public Storage SQL Injection
      ///Fix: Remove the database connection and communicate with the server, and check if the data matches the expected regular expressions
      var results = await conn.execute(
          "SELECT idUser, username, bin(isAdmin) as isAdmin, avatarNumber FROM user WHERE email = '${extractedUserData['email']! as String}'");
      for (final row in results.rows) {
        _token = extractedUserData['token']! as String;
        _userId =
            extractedUserData['userId']! as String == row.assoc()['userId']!
                ? extractedUserData['userId']! as String
                : '';
        _expiryDate = expiryDate;
        _email = extractedUserData['email']! as String == row.assoc()['email']!
            ? extractedUserData['email']! as String
            : '';
        avatarNumber = extractedUserData['avatarNumber']! as String ==
                row.assoc()['userId']!
            ? extractedUserData['userId']! as int
            : -1;
        _isAdmin = row.assoc()['isAdmin']! == '1' ? true : false;
        notifyListeners();
        _autoLogout();
        if (_userId == '' || _email == '' || avatarNumber == -1) return false;
        return true;
      }
      results =
          await conn.execute("SELECT idUser FROM user WHERE email = '$email'");
      for (final row in results.rows) {
        if (row.assoc()['idUser'] != null || row.assoc()['idUser'] != '') {
          throw IncorrectPasswordException();
        }
      }
      throw UserDoesntExistException();
    } catch (error) {
      rethrow;
    }
  }

  ///Method used to log the user in the system with the credentials received by an url
  ///
  /// Throws [UserDoesntExistException] if the user is not registered in the database
  /// Throws [IncorrectPasswordException] if the password doesn't match the one set up before
  /// Throws [HttpException] for generic server and database errors
  Future<void> urlLogin(String email, String password) async {
    try {
      final conn = await MySQLConnection.createConnection(
          host: GlobalConfiguration().getValue("host"),
          port: GlobalConfiguration().getValue("port"),
          userName: GlobalConfiguration().getValue("userName"),
          password: GlobalConfiguration().getValue("password"),
          databaseName: GlobalConfiguration().getValue("databaseName"));
      await conn.connect();

      ///Vulnerability: SQL Injection From URL Scheme or Intent
      ///Fix: Use regular expressions to test if the email matches the expected form,
      /// and use some strong password checker(regular expression)
      var results = await conn.execute(
          "SELECT idUser, username, bin(isAdmin) as isAdmin, avatarNumber FROM user WHERE email = '$email' and password = '$password'");
      for (final row in results.rows) {
        _token = 'notSet';

        ///Vulnerability: Resource Update By URL Data
        ///Fix: User regular expressions to test the values used for input in the method
        _email = email;
        _userId = row.assoc()['idUser']!;
        _username = row.assoc()['username']!;
        avatarNumber = int.parse(row.assoc()['avatarNumber']!);
        _expiryDate = DateTime.now().add(const Duration(days: 30));
        _isAdmin = row.assoc()['isAdmin'] == '1' ? true : false;
        _autoLogout();
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'idUser': _userId,
          'username': _username,
          'expiryDate': _expiryDate.toIso8601String(),
          'email': email,
          'avatarNumber': avatarNumber
        });
        prefs.setString('userData', userData);
        return;
      }

      ///Vulnerability: Parameter tampering
      ///Fix: Change this query to the server, and use a identifier to check if the user has access to that info
      results =
          await conn.execute("SELECT idUser FROM user WHERE email = '$email'");
      for (final row in results.rows) {
        if (row.assoc()['idUser'] != null || row.assoc()['idUser'] != '') {
          throw IncorrectPasswordException();
        }
      }
      throw UserDoesntExistException();
    } catch (error) {
      rethrow;
    }
  }

  ///Log out method
  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = DateTime.now();
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  ///Auto log out feature which will log out the user after a defined time
  void _autoLogout() {
    if (_authTimer.isActive) {
      _authTimer.cancel();
    }
    var seconds = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: seconds),
      logout,
    );
  }

  ///Gets from the server all data needed to present to user
  Map<String, String> getUserData(String token) {
    Map<String, String> response = {};
    response['username'] = _username;
    response['email'] = _email;
    response['picture'] = avatarNumber.toString();
    return response;
  }

  ///Used to change ser data
  ///
  /// Throws [HttpException] for generic server and database errors
  Future<void> changeUserData(
      String username, String email, String password, String picture) async {
    Uri url = Uri.parse("http://6d74-193-137-92-95.eu.ngrok.io");
    try {
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(url, headers: {
        'changeUserData': _userId,
        'email': email,
        'username': username,
        'password': password,
        'avatarNumber': picture
      });
      if (response.statusCode != 200) {
        throw HttpException;
      }
    } catch (error) {
      rethrow;
    }
    _email = email;
    _username = username;
    avatarNumber = int.parse(picture);
    notifyListeners();
  }

  ///With this method the user can delete his own account
  Future<void> deleteUser(String userId) async {
    Uri url = Uri.parse("http://6d74-193-137-92-95.eu.ngrok.io");

    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    await http.post(url, headers: {'removeUser': userId, 'userId': userId});
    logout();
    notifyListeners();
  }
}
