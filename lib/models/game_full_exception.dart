import '../i18n/strings.g.dart';

///Exception thrown when
class GameFullException implements Exception{
  String message = '';

  GameFullException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.gameFullException;
    return message;
  }
}