import '../i18n/strings.g.dart';

///Exception thrown when an operation is not allowed, but it's not related to admin privileges
class ReservationDoesNotExistException implements Exception{
  String message = '';

  ReservationDoesNotExistException([String? message]){
    if(message != null) this.message = message;
  }

  @override
  String toString() {
    if(message == '') return t.exceptions.reservationDoesntExist;
    return message;
  }
}