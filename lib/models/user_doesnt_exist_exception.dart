import '../i18n/strings.g.dart';

///Exception thrown when a user is not registered in the database
class UserDoesntExistException implements Exception{
  String message = '';

  UserDoesntExistException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.userDoesntExist;
    return message;
  }
}
