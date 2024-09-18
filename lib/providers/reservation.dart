import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cx_playground/models/admin_privileges_exception.dart';
import 'package:cx_playground/models/game_full_exception.dart';
import 'package:cx_playground/models/reservations_mode.dart';
import 'package:cx_playground/providers/games.dart';
import 'package:cx_playground/providers/users_admin.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import '../models/game_not_open_exception.dart';
import '../models/reservation_does_not_exist_exception.dart';
import 'auth.dart';
import 'game.dart';

///Class that contains all information related to a Reservation
class Reservation with ChangeNotifier{
  String idBooking = '';
  late DateTime initDate;
  late DateTime endDate;
  String idUser = '';
  int nMax = -1;
  int nMin = -1;
  String game = '';
  List<Reservation> reservations = [];
  List<Tuple2<DateTime, DateTime>> available = [];
  List<Auth> users = [];
  bool isAuthor = false;
  String gameName = '';

  Reservation([this.idBooking = '', initDate, endDate, this.idUser = '',
      this.nMax = 1, this.nMin = 1, this.game = '']) {
    this.initDate = initDate ?? DateTime.now();
    this.endDate = endDate ?? DateTime.now();
  }

  ///Gets data from the server about all bookings of a [Game]
  /// Throws [HttpException] for generic server and database errors
  Future<List<Reservation>> getBookings(gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'reservations': gameId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final reservationData = json.decode(response.body);
    List<Reservation> reservations = [];
    for(final reserve in reservationData){
      DateTime end = DateTime.tryParse(reserve['endDate']!)!;
      if(DateTime.now().isBefore(end)) {
        reservations.add(Reservation(
            reserve['idBooking']!,
            DateTime.tryParse(reserve['initDate']!)!,
            end,
            reserve['idUser']!,
            int.parse(reserve['nMax']!),
            int.parse(reserve['nMin']!),
            gameId
        ));
      }
    }
    return reservations;
  }

  ///Gets data from the server about all users in a booking
  Future<Map<String,int>> getReservationsPlayer(gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'reservationsPlayerFull': 'all'});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    Map<String,int> reservationData = Map.castFrom(json.decode(response.body)) ;
    return reservationData;
  }

  ///Gets data from the server about all bookings of a [Game] where the user is not in
  Future<List<Reservation>> getBookingsWhereUserNotIn(gameId, String userId) async {
    users = await UsersAdmin().getUsersFromServer();
    Map<String,int> reservationsPlayer = await getReservationsPlayer(gameId);
    List<Reservation> reservationsTotal = await getBookings(gameId);
    reservationsTotal.removeWhere((element) => element.idUser == userId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.get(url, headers: {'reservationsWhereUserIn': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final reservationData = json.decode(response.body);
    List<String> reservationsUserIn = [];
    for(final reserve in reservationData){
      reservationsUserIn.add(reserve['reservationId']);
    }
    for(final reserve in reservationsUserIn){
     reservationsTotal.removeWhere((element) => element.idBooking == reserve);
    }
    for(final reserve in reservationsPlayer.entries){
      reservationsTotal.removeWhere((element) => element.idBooking == reserve.key && element.nMax <= (reserve.value + 1));
    }
    reservationsTotal.removeWhere((element) => element.nMin >= element.nMax);
    reservations = reservationsTotal;
    return reservationsTotal;
  }

  bool notReserved(List<Reservation> reservations, DateTime date, int duration){
    DateTime end = date.add(Duration(minutes: duration));
    for(final reserve in reservations){
      if((date.isAfter(reserve.initDate) && date.isBefore(reserve.endDate)) || date.isAtSameMomentAs(reserve.initDate)){
        return false;
      }
      if((end.isAfter(reserve.initDate) && end.isBefore(reserve.endDate)) || end.isAtSameMomentAs(reserve.endDate)){
        return false;
      }
    }
    return true;
  }

  Future<List<Tuple2<DateTime, DateTime>>> availableMoments(String game, DateTime day, int duration) async {
    List<Reservation> reservations = await getBookings(game);
    List<Tuple2<DateTime,DateTime>> map = [];
    DateTime lowerBound = day.day == DateTime.now().day ? (DateTime.now().hour > 8 ? DateTime.now() : DateTime.now().subtract(Duration(minutes: DateTime.now().minute + 1)).add(Duration(hours: 8 - DateTime.now().hour))) : day.add(const Duration(hours: 8, minutes: 00));
    DateTime init = day.subtract(Duration(minutes: day.minute)).subtract(Duration(seconds: day.second));
    DateTime end = init.add(Duration(hours: 20 - day.hour, minutes: 1));
    const increment = Duration(minutes: 5);
    while(init.add(Duration(minutes: duration)).isBefore(end) || init.add(Duration(minutes: duration)).isAtSameMomentAs(end)){
      DateTime endSlot = init.add(Duration(minutes: duration));
      if((init.isAfter(lowerBound) || init.isAtSameMomentAs(lowerBound)) && notReserved(reservations, init, duration) && endSlot.isBefore(end)){
        map.add(Tuple2(init, endSlot));
      }
      init = init.add(increment);
    }
    available = map;
    return map;
  }

  ///Creates a [Reservation]
  ///Throws [HttpException] for generic server and database errors
  Future<String> createReservation(String initDate, String endDate, String userId, String nMax, String nMin, String idGame) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'createReservation': initDate, 'endDate': endDate, 'userId': userId, 'nMax': nMax, 'nMin': nMin, 'idGame': idGame});
      if(response.statusCode != 200) {
          throw HttpException;
      }
      return response.body;
    }catch(error){
      rethrow;
    }
  }

  ///Deletes a [Reservation] from the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteReservation(String bookingId, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeReservation': bookingId, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
  }

  ///Deletes a [Reservation] from the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteReservationAdmin(String bookingId, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeReservationAdmin': bookingId, 'userId': userId});
    if(response.statusCode != 200) {
      if(response.statusCode == 510) throw AdminPrivilegesException();
      throw HttpException;
    }
  }

  ///Updates a [Reservation] data in the server
  ///Throws [ReservationDoesNotExistException] if the reservations is not found in the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> updateReservation(String bookingId, String initDate, String endDate, String nMax, String nMin) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'updateBooking': bookingId, 'initDate': initDate, 'endDate': endDate, 'nMax': nMax, 'nMin': nMin});
      if(response.statusCode != 200) {
        if (response.statusCode == 513) {
          throw ReservationDoesNotExistException();
        } else {
          throw HttpException;
        }
      }
    } catch(error){
      rethrow;
    }
  }

  ///Adds an player to a [Reservation] data in the server
  ///Throws [GameFullException] if the reservations is already full
  ///Throws [GameNotOpenException] if the reservations is already full
  ///Throws [HttpException] for generic server and database errors
  Future<void> addUserToReservation(String bookingId, String idUser) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'addUserBooking': bookingId, 'idUser': idUser});
      if(response.statusCode != 200) {
        if (response.statusCode == 514) {
          throw GameFullException();
        } else if(response.statusCode == 515) {
          throw GameNotOpenException();
        } else {
          throw HttpException;
        }
      }
    } catch(error){
      rethrow;
    }
  }

  ///gets all [Reservation]'s from a player
  ///Throws [HttpException] for generic server and database errors
  Future<List<Reservation>> getAllReservationsUser(String userId, ReservationsMode reservationsMode, [int idGame = -2]) async {
    List<Game> games = await Games().getGamesFromServer();
    List<Reservation> allReservations = [];
    List<Reservation> myReservations = [];
    List<Reservation> participating = [];
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.get(
          url, headers: {'reservations': 'all'});
      if(response.statusCode != 200) {
        throw HttpException;
      }
      var reservationData = json.decode(response.body);
      for(final reserve in reservationData){
        var res = Reservation(
            reserve['idBooking']!,
            DateTime.tryParse(reserve['initDate']!)!,
            DateTime.tryParse(reserve['endDate']!)!,
            reserve['idUser']!,
            int.parse(reserve['nMax']!),
            int.parse(reserve['nMin']!),
            reserve['idGame']!
        );
        res.gameName = games.firstWhere((element) => element.id == res.game).name;
        if(res.idUser == userId) res.isAuthor = true;
        allReservations.add(res);
      }
      if(reservationsMode == ReservationsMode.all && idGame == -1){
        reservations = allReservations;
        return reservations;
      }
      if(reservationsMode == ReservationsMode.filter){
        reservations = [];
        for (var element in allReservations) {
          if(element.game == idGame.toString()) reservations.add(element);
        }
        return reservations;
      }
      if(reservationsMode != ReservationsMode.participating){
        myReservations = [...allReservations];
        myReservations.removeWhere((element) => element.idUser != userId);
      }
      if(reservationsMode != ReservationsMode.myReservations){
        ///Vulnerability: Insecure Communications: Communication Over HTTP
        ///Fix: Host the server in an https website
        ///Vulnerability: Remote Inputs
        final response = await http.get(url, headers: {'reservationsWhereUserIn': userId});
        if(response.statusCode != 200) {
          throw HttpException;
        }
        final reservationData = json.decode(response.body);
        List<String> reservationsUserIn = [];
        for(final reserve in reservationData){
          reservationsUserIn.add(reserve['reservationId']);
        }
        for(final reserve in allReservations){
          if(reservationsUserIn.contains(reserve.idBooking)){
            participating.add(reserve);
          }
        }
      }
      if(reservationsMode == ReservationsMode.all){
        reservations = myReservations;
        reservations.addAll(participating);
      } else if(reservationsMode == ReservationsMode.myReservations){
        reservations = myReservations;
      } else {
        reservations = participating;
      }
      return reservations;
    } catch (e) {
      rethrow;
    }
  }

  ///Gets all the players in a [Reservation]
  ///Throws [HttpException] for generic server and database errors
  Future<void> getPlayersReservation() async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.get(
          url, headers: {'getPlayersReservation': idBooking});
      if(response.statusCode != 200) {
        throw HttpException;
      }
      var reservationData = json.decode(response.body);
      for(final reserve in reservationData) {
        if(!users.any((element) => element.userId == reserve['idUser']!)) {
          users.add(Auth(
           reserve['idUser']!,
           reserve['username']!,
           reserve['email']!,
           reserve['isAdmin']! == '1' ? true : false,
           int.tryParse(reserve['avatarNumber']!) ?? -1
        ));
        }
      }
    } catch(error){
      rethrow;
    }
  }

  ///Removes a player from a [Reservation]
  ///Throws [HttpException] for generic server and database errors
  Future<void> removePlayerFromReservation(String idBooking, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeUserFromReservation': idBooking, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
  }
}
