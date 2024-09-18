import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:cx_playground/models/admin_privileges_exception.dart';
import 'package:cx_playground/providers/games.dart';
import 'package:cx_playground/providers/reservation.dart';
import 'package:cx_playground/providers/team.dart';
import 'package:cx_playground/providers/users_admin.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';
import '../models/tournaments_mode.dart';
import 'auth.dart';
import 'game.dart';

///Class that contains all information related to a Reservation
class Tournament with ChangeNotifier{
  String idTournament = '';
  late DateTime matchDate;
  late DateTime matchDateEnd;
  String idUser = '';
  int nPlayers = -1;
  int nTeams = -1;
  String game = '';
  List<Tournament> tournaments = [];
  List<Tuple2<DateTime, DateTime>> available = [];
  List<Auth> users = [];
  List<Team> teams = [];
  bool isAuthor = false;
  String gameName = '';

  Tournament([this.idTournament = '', matchDate, matchDateEnd, this.idUser = '',
      this.nPlayers = 1, this.nTeams = 1, this.game = '']) {
    this.matchDate = matchDate ?? DateTime.now();
    this.matchDateEnd = matchDateEnd ?? DateTime.now();
  }

  ///Gets data from the server about all bookings of a [Game]
  /// Throws [HttpException] for generic server and database errors
  Future<List<Tournament>> getTournaments(gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'tournaments': gameId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final reservationData = json.decode(response.body);
    List<Tournament> tournaments = [];
    for(final tournament in reservationData){
      DateTime matchDate = DateFormat('yyyy-MM-dd').parse(tournament['matchDate']!);
      DateTime matchDateEnd = DateFormat('yyyy-MM-dd').parse(tournament['matchDateEnd']!);
      if(DateTime.now().isBefore(matchDate)) {
        tournaments.add(Tournament(
          tournament['idTournament']!,
          matchDate,
          matchDateEnd,
          tournament['idOwner']!,
          int.tryParse(tournament['nPlayers']!) ?? 1,
          int.tryParse(tournament['nTeams']!) ?? 1,
          gameId
        ));
      }
    }
    return tournaments;
  }

  ///Gets data from the server about all users in a team
  Future<Map<String,int>> getTeamsPlayers(gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'teamsPlayerFull': 'all'});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    Map<String,int> reservationData = Map.castFrom(json.decode(response.body));
    return reservationData;
  }

  ///Gets data from the server about all teams of a [Tournament] where the user is not in
  Future<List<Tournament>> getTournamentsWhereUserNotIn(gameId, String userId) async {
    users = await UsersAdmin().getUsersFromServer();
    Map<String,int> teamsPlayer = await getTeamsPlayers(gameId);
    List<Tournament> tournamentsTotal = await getTournaments(gameId);
    tournamentsTotal.removeWhere((element) => element.idUser == userId);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.get(url, headers: {'tournamentsWhereUserIn': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final tournamentData = json.decode(response.body);
    List<String> tournamentsUserIn = [];
    for(final tournament in tournamentData){
      tournamentsUserIn.add(tournament['tournamentId']);
    }
    for(final tournament in tournamentsUserIn){
      tournamentsTotal.removeWhere((element) => element.idTournament == tournament);
    }
    for(final team in teamsPlayer.entries){
      tournamentsTotal.removeWhere((element) => element.idTournament == team.key && element.nPlayers <= (team.value + 1));
    }
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final teamsTournament = await http.get(url, headers: {'teamsInTournament': userId});
    if(teamsTournament.statusCode != 200) {
      throw HttpException;
    }
    Map<String,int> teamsInTournament = Map.castFrom(json.decode(teamsTournament.body)) ;
    tournamentsTotal.removeWhere((element) => element.nTeams <= teamsInTournament[element.idTournament]! );
    tournaments = tournamentsTotal;
    return tournamentsTotal;
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

  Future<List<Tuple2<DateTime, DateTime>>> availableMoments(String game, DateTime day, String duration) async {
    List<Reservation> reservations = await Reservation().getBookings(game);
    List<Tuple2<DateTime,DateTime>> map = [];
    DateTime lowerBound = day.day == DateTime.now().day ? (DateTime.now().hour > 8 ? DateTime.now() : DateTime.now().subtract(Duration(minutes: DateTime.now().minute + 1)).add(Duration(hours: 8 - DateTime.now().hour))) : day.add(const Duration(hours: 8, minutes: 00));
    DateTime init = day.subtract(Duration(minutes: day.minute)).subtract(Duration(seconds: day.second));
    DateTime end = init.add(Duration(hours: 20 - day.hour, minutes: 1));
    int time = 0;
    if(duration == '4h') {
      end = init.add(Duration(hours: 44 - day.hour, minutes: 1));
      time = 4;
    } else if(duration == '4h') {
      end = init.add(Duration(hours: 68 - day.hour, minutes: 1));
      time = 24;
    } else {
      end = init.add(Duration(hours: 116 - day.hour, minutes: 1));
      time = 48;
    }
    const increment = Duration(hours: 1);
    while(init.add(Duration(hours: time)).isBefore(end) || init.add(Duration(hours: time)).isAtSameMomentAs(end)){
      DateTime endSlot = init.add(Duration(hours: time));
      if((init.isAfter(lowerBound) || init.isAtSameMomentAs(lowerBound)) && notReserved(reservations, init, time) && endSlot.isBefore(end)){
        if(init.hour > 7 && init.hour < 20 && endSlot.hour > 7 && endSlot.hour < 21){
          map.add(Tuple2(init, endSlot));
        }
      }
      init = init.add(increment);
    }
    available = map;
    return map;
  }

  ///Creates a [Reservation]
  ///Throws [HttpException] for generic server and database errors
  Future<String> createTournament(String matchDate, String endDate, String userId, String nTeams, String nPlayers, String idGame) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'createTournament': matchDate, 'matchDateEnd': endDate, 'userId': userId, 'nTeams': nTeams, 'nPlayers': nPlayers, 'idGame': idGame});
      if(response.statusCode != 200) {
          throw HttpException;
      }
      return response.body;
    }catch(error){
      rethrow;
    }
  }

  ///Deletes a [Tournament] from the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteTournament(String tournamentId, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeTournament': tournamentId, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
  }

  ///Deletes a [Tournament] from the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteTournamentAdmin(String tournamentId, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeTournamentAdmin': tournamentId, 'userId': userId});
    if(response.statusCode != 200) {
      if(response.statusCode == 510) throw AdminPrivilegesException();
      throw HttpException;
    }
  }

  ///Updates a [Tournament] data in the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> updateTournament(String tournamentId, String matchDate, String matchDateEnd, String nTeams, String nPlayers) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'updateTournament': tournamentId, 'matchDate': matchDate, 'matchDateEnd': matchDateEnd, 'nTeams': nTeams, 'nPlayers': nPlayers});
      if(response.statusCode != 200) {
        throw HttpException;
      }
    } catch(error){
      rethrow;
    }
  }

  ///gets all [Reservation]'s from a player
  ///Throws [HttpException] for generic server and database errors
  Future<List<Tournament>> getAllTournamentsUser(String userId, TournamentsMode tournamentsMode, [int idGame = -2]) async {
    List<Game> games = await Games().getGamesFromServer();
    List<Tournament> allReservations = [];
    List<Tournament> myReservations = [];
    List<Tournament> participating = [];
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.get(
          url, headers: {'tournaments': 'all'});
      if(response.statusCode != 200) {
        throw HttpException;
      }
      var reservationData = json.decode(response.body);
      for(final reserve in reservationData){
        var res = Tournament(
            reserve['idTournament']!,
            DateTime.tryParse(reserve['matchDate']!)!,
            DateTime.tryParse(reserve['matchDateEnd']!)!,
            reserve['idUser']!,
            int.parse(reserve['nPlayers']!),
            int.parse(reserve['nTeams']!),
            reserve['idGame']!
        );
        res.gameName = games.firstWhere((element) => element.id == res.game).name;
        if(res.idUser == userId) res.isAuthor = true;
        allReservations.add(res);
      }
      if(tournamentsMode == TournamentsMode.all && idGame == -1){
        tournaments = allReservations;
        return tournaments;
      }
      if(tournamentsMode == TournamentsMode.filter){
        tournaments = [];
        for (var element in allReservations) {
          if(element.game == idGame.toString()) tournaments.add(element);
        }
        return tournaments;
      }
      if(tournamentsMode != TournamentsMode.participating){
        myReservations = [...allReservations];
        myReservations.removeWhere((element) => element.idUser != userId);
      }
      if(tournamentsMode != TournamentsMode.myTournaments){
        ///Vulnerability: Insecure Communications: Communication Over HTTP
        ///Fix: Host the server in an https website
        ///Vulnerability: Remote Inputs
        final response = await http.get(url, headers: {'tournamentsWhereUserIn': userId});
        if(response.statusCode != 200) {
          throw HttpException;
        }
        final reservationData = json.decode(response.body);
        List<String> reservationsUserIn = [];
        for(final reserve in reservationData){
          reservationsUserIn.add(reserve['idTournament']);
        }
        for(final reserve in allReservations){
          if(reservationsUserIn.contains(reserve.idTournament)){
            participating.add(reserve);
          }
        }
      }
      if(tournamentsMode == TournamentsMode.all){
        tournaments = myReservations;
        tournaments.addAll(participating);
      } else if(tournamentsMode == TournamentsMode.myTournaments){
        tournaments = myReservations;
      } else {
        tournaments = participating;
      }
      return tournaments;
    } catch (e) {
      rethrow;
    }
  }

}
