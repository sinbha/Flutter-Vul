
///Exception thrown when user wants to access methods without having administrator privileges
class UnableToAddTeamException implements Exception{
  String message = '';

  UnableToAddTeamException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return 't.exceptions.UnableToAddTeam';
    return message;
  }
}
