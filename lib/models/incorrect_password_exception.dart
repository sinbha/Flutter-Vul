import '../i18n/strings.g.dart';

///Exception thrown when a password doesn't match the one defined before
class IncorrectPasswordException implements Exception{
  String message = '';

  IncorrectPasswordException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.incorrectPassword;
    return message;
  }
}
