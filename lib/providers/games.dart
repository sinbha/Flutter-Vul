import 'dart:convert';
import 'dart:io';
import 'package:cx_playground/models/admin_privileges_exception.dart';
import 'package:cx_playground/models/game_doesnt_exist_exception.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'categories.dart';
import 'game.dart';

///Category with methods to work with games
class Games with ChangeNotifier{
  String ip = GlobalConfiguration().getValue("ip");
  List<Game> _games = [];
  Map<String, String> _categories = {};

  ///Setter os categories
  set categories(Map<String, String> categories){
    _categories = Map.from(_categories);
  }

  ///Getter of categories
  Map<String, String> get categories{
    return Map.from(_categories);
  }

  ///Getter od [Games]
  List<Game> get games{
    return [..._games];
  }

  ///Gets all games internal data from the server
  ///Throws [HttpException] for generic server and database errors
  Future<List<Game>> getGamesFromServer() async {
    _categories = await Categories().getCategoriesFromServer();
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'games': 'all'});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final List<Game> loadedGames = [];
    final extractedData = json.decode(response.body) as List<dynamic>;
    if(extractedData.isEmpty) return loadedGames;
    for (var gameData in extractedData) {
      loadedGames.add(Game(
          gameData['idGame']!,
          gameData['name']!,
          int.parse(gameData['duration']),
          int.parse(gameData['nMax']),
          int.parse(gameData['nMin']),
          gameData['description']!,
          gameData['creationDate']!,
          gameData['isAvailable'] == '1' ? true : false,
          _categories[gameData['idCategory']]!
      ));
    }
    _games = loadedGames.reversed.toList();
    return loadedGames.reversed.toList();
  }

  ///Deletes a [Game] from the server
  ///Throws [HttpException] for generic server and database errors
  Future<void> deleteGame(String adminId, String gameId) async {
    ///Vulnerability: Bad Certificate Callback
    ///Fix: HTTP client is not being used, so it could just be removed
    games.removeWhere((element) => element.id == gameId);
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.post(url, headers: {'removeGame': adminId, 'gameId': gameId});
    if(response.statusCode != 200) {
      if (response.statusCode == 510) {
        throw AdminPrivilegesException();
      } else {
        throw HttpException;
      }
    }
  }

  ///Turns a [Game] available
  ///Throws [AdminPrivilegesException] is user has no administrator privileges
  ///Throws [HttpException] for generic server and database errors
  Future<void> turnAvailable(String adminId, String gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(url, headers: {'turnAvailable': adminId, 'gameId': gameId});
    if(response.statusCode != 200) {
      if (response.statusCode == 510) {
        throw AdminPrivilegesException();
      } else {
        throw HttpException;
      }
    }
  }

  ///Turns a [Game] unavailable
  ///Throws [AdminPrivilegesException] is user has no administrator privileges
  ///Throws [HttpException] for generic server and database errors
  Future<void> removeAvailable(String adminId, String gameId) async {
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    ///Vulnerability: Insecure Communications: Communication Over HTTP
    ///Fix: Host the server in an https website
    ///Vulnerability: Remote Inputs
    final response = await http.post(
        url, headers: {'removeAvailable': adminId, 'gameId': gameId});
    if(response.statusCode != 200) {
      if (response.statusCode == 510) {
        throw AdminPrivilegesException();
      } else {
        throw HttpException;
      }
    }
  }

  ///Creates a [Game]
  ///Throws [AdminPrivilegesException] is user has no administrator privileges
  ///Throws [HttpException] for generic server and database errors
  Future<void> createGame(String adminId, String name, String duration, String nMax, String nMin, String description, String isAvailable, String idCategory) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'createGame': adminId, 'name': name, 'duration': duration, 'nMax': nMax, 'nMin': nMin, 'description': description, 'isAvailable': isAvailable, 'idCategory': idCategory});
      if(response.statusCode != 200) {
        if (response.statusCode == 510) {
          throw AdminPrivilegesException();
        } else {
          throw HttpException;
        }
      }
      getGamesFromServer();
    }catch(error){
      rethrow;
    }
  }

  ///Updates a [Game] data in the server
  ///Throws [AdminPrivilegesException] is user has no administrator privileges
  ///Throws [HttpException] for generic server and database errors
  updateGame(String adminId, String gameId, String name, String duration, String nMax, String nMin, String description, String isAvailable, String idCategory) async {
    try {
      final url = Uri.parse(GlobalConfiguration().getValue("ip"));
      ///Vulnerability: Insecure Communications: Communication Over HTTP
      ///Fix: Host the server in an https website
      ///Vulnerability: Remote Inputs
      final response = await http.post(
          url, headers: {'updateGame': adminId, 'gameId': gameId, 'name': name, 'duration': duration, 'nMax': nMax, 'nMin': nMin, 'description': description, 'isAvailable': isAvailable, 'idCategory': idCategory});
      if(response.statusCode != 200) {
        if (response.statusCode == 510) {
          throw AdminPrivilegesException();
        } else if (response.statusCode == 511) {
          throw GameDoesntExistException();
        } else {
          throw HttpException;
        }
      }
      getGamesFromServer();
    } catch(error){
      rethrow;
    }
  }
}