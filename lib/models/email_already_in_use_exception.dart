import '../i18n/strings.g.dart';

///Exception thrown when an email is already registered in the database
class EmailAlreadyInUseException implements Exception{
  String message = '';

  EmailAlreadyInUseException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.emailInUse;
    return message;
  }
}
