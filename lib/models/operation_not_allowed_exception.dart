import '../i18n/strings.g.dart';

///Exception thrown when an operation is not allowed, but it's not related to admin privileges
class OperationNotAllowedException implements Exception{
  String message = '';

  OperationNotAllowedException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.operationNotAllowed;
    return message;
  }
}
