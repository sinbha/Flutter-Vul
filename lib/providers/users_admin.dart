import 'dart:convert';
import 'dart:io';
import 'package:cx_playground/models/admin_privileges_exception.dart';
import 'package:cx_playground/models/operation_not_allowed_exception.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../i18n/strings.g.dart';
import 'auth.dart';

///Class with methods to perform administrator operations on users
class UsersAdmin extends ChangeNotifier {
  List<Auth> users = [];

  ///Getter of a copy of the users list
  Future<List<Auth>> get getUsers async {
    return [...users];
  }

  ///Gets basic information's from all users in the server
  Future<List<Auth>> getUsersFromServer() async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.get(url, headers: {'users': 'all'});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final List<Auth> loadedUsers = [];
    final extractedData = json.decode(response.body) as List<dynamic>;
    if(extractedData.isEmpty) return loadedUsers;
    for (var userData in extractedData) {
      loadedUsers.add(Auth(
          userData['idUser']!,
          userData['username']!,
          userData['email']!,
          userData['isAdmin'] == '1' ? true : false,
          int.parse(userData['avatarNumber'])
      ));
    }
    users =loadedUsers.reversed.toList();
    return loadedUsers.reversed.toList();
  }

  ///Deletes an user - only accessible to users with administrator privileges
  Future<void> deleteUser(String userAdminId, String userId) async {
    users.removeWhere((element) => element.userId == userId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    await http.post(url, headers: {'removeUser': userAdminId, 'userId': userId});
    notifyListeners();
  }

  ///Method to remove administrator privileges from a user
  ///
  ///Throws [OperationNotAllowedException] if the ser is removing his administrator privileges.
  ///Throws [AdminPrivilegesException] if the user has no privileges to perform this operation.
  ///Trows [HttpException], a generic error handler for server and database errors.
  Future<bool> turnAdmin(String userAdminId, String userId) async {
    users.removeWhere((element) => element.userId == userId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'turnAdmin': userAdminId, 'userid': userId});
    if(response.statusCode != 200) {
      if (response.statusCode == 509) {
        throw OperationNotAllowedException();
      } else if (response.statusCode == 510) {
        throw AdminPrivilegesException();
      } else {
        throw HttpException;
      }
    }
    notifyListeners();
    return true;
  }

  ///Method to give an user administrator privileges
  ///
  ///Throws [OperationNotAllowedException] if the ser is removing his administrator privileges.
  ///Throws [AdminPrivilegesException] if the user has no privileges to perform this operation.
  ///Trows [HttpException], a generic error handler for server and database errors.
  Future<bool> removeAdmin(String userAdminId, String userId) async {
    users.removeWhere((element) => element.userId == userId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeAdmin': userAdminId, 'userid': userId});
    if(response.statusCode != 200) {
      if (response.statusCode == 509) {
        throw OperationNotAllowedException();
      } else if (response.statusCode == 510) {
        throw AdminPrivilegesException();
      } else {
        throw HttpException;
      }
    }
    notifyListeners();
    return true;
  }
}
