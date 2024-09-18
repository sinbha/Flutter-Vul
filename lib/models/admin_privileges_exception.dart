import '../i18n/strings.g.dart';

///Exception thrown when user wants to access methods without having administrator privileges
class AdminPrivilegesException implements Exception{
  String message = '';

  AdminPrivilegesException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.adminPrivileges;
    return message;
  }
}
