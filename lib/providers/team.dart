import 'dart:convert';

import 'package:cx_playground/providers/users_admin.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'package:cx_playground/models/http_exception.dart';

class Team with ChangeNotifier{
  String idTeam = '';
  String name = '';
  String idTeamLeader = '';
  List<Auth> users = [];
  List<Team> teams = [];

  Team([this.name = '', this.idTeamLeader = '', this.idTeam = '']);

  ///Creates a [Team]
  ///Throws [HttpException] for generic server and database errors
  Future<String> createTeam(String teamName, String tournamentId, String userId) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'createTeam': teamName, 'tournamentId': tournamentId, 'userId': userId});
      if(response.statusCode != 200) {
        throw HttpException;
      }
      return response.body;
    }catch(error){
      rethrow;
    }
  }

  ///Adds a User to a [Team]
  ///Throws [HttpException] for generic server and database errors
  Future<String> addUserToTeam(String teamId, String userId) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'addUserToTeam': teamId, 'userId': userId});
      if(response.statusCode != 200) {
        throw HttpException;
      }
      return response.body;
    }catch(error){
      rethrow;
    }
  }

  ///Gets all teams internal data from the server
  ///Throws [HttpException] for generic server and database errors
  Future<List<Team>> getTeamsFromServer() async {
    List<Auth> usersServer = await UsersAdmin().getUsersFromServer();
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    var response = await http.get(url, headers: {'teams': 'all'});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final List<Team> loadedTeams = [];
    var extractedData = json.decode(response.body) as List<dynamic>;
    for (var teamData in extractedData) {
      Team t = Team(
        teamData['name']!,
        teamData['idTeamLeader']!,
        teamData['idTeam']!
      );
      t.users.add(usersServer.firstWhere((element) => element.userId == t.idTeamLeader));
      response = await http.get(url, headers: {'playersTeam': t.idTeam});
      if (response.statusCode != 200) {
        throw HttpException;
      }
      var usersData = json.decode(response.body) as List<dynamic>;
      for (var teamData in usersData) {
        t.users.add(Auth(
            teamData['idUser']!,
            teamData['username']!,
            teamData['email']!,
            teamData['isAdmin'] == '1' ? true : false,
            int.tryParse(teamData['avatarNumber']!) ?? -1
        ));
      }
      loadedTeams.add(t);
    }
    teams = loadedTeams.reversed.toList();
    return loadedTeams.reversed.toList();
  }

  ///Gets all players in a tournament
  ///Throws [HttpException] for generic server and database errors
  Future<List<String>> getPlayersInTournament(String idTournament) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    var response = await http.get(url, headers: {'playersInTournament': idTournament});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final List<String> playersInTournament = [];
    var extractedData = json.decode(response.body) as List<dynamic>;
    for (var teamData in extractedData) {
      if(teamData.isNotEmpty) {
        var extractedTeamData = json.decode(teamData) as List<dynamic>;
        for (var teamMember in extractedTeamData) {
          playersInTournament.add(teamMember['idUser']);
        }
      }
    }
    return playersInTournament.toList();
  }

  ///Updates a [Team]
  ///Throws [HttpException] for generic server and database errors
  Future<String> updateTeam(String userId, String idTeam, String name) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'updateTeam': idTeam, 'name': name});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    return "";
  }

  ///Removes a player from a [Team]
  ///Throws [HttpException] for generic server and database errors
  Future<String> removePlayerFromTeam(String idTeam, String userId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeUserFromTeam': idTeam, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    return "";
  }

  Future<String> deleteTeam(String idTeam, String userId) async{
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeTeam': idTeam, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    return "";
  }

  Future<String> deleteTeamAdmin(String idTeam, String userId) async{
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'removeTeamAdmin': idTeam, 'userId': userId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    return "";
  }

}