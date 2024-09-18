///Exception thrown when a game is not registered in the database
class GameDoesntExistException implements Exception{
  String message = '';

  GameDoesntExistException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return 't.exceptions.gameDoesntExist';
    return message;
  }
}