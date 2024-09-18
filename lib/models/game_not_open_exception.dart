import '../i18n/strings.g.dart';

class GameNotOpenException implements Exception{
  String message = '';

  GameNotOpenException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.gameNotOpenException;
    return message;
  }
}