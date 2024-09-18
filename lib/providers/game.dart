import 'dart:convert';
import '../models/http_exception.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'categories.dart';

///Class that defines a game
class Game{
  String id = '';
  String name = '';
  int duration = 0;
  int nMax = 0;
  int nMin = 0;
  String description = '';
  String creationDate = '';
  bool isAvailable = false;
  String category = '';

  Game([this.id = '', this.name = '', this.duration = 0, this.nMax = 0, this.nMin = 0,
      this.description = '', this.creationDate = '', this.isAvailable = false, this.category = '']);

  ///Gets data from the server about a game
  /// Throws [HttpException] for generic server and database errors
  Future<Game> getGame(gameId) async {
    var categories = await Categories().getCategoriesFromServer();
    final url = Uri.parse(GlobalConfiguration().getValue("ip"));
    final response = await http.get(url, headers: {'game': gameId});
    if(response.statusCode != 200) {
      throw HttpException;
    }
    final gameData = json.decode(response.body);
    return Game(
          gameId,
          gameData['name']!,
          int.parse(gameData['duration']),
          int.parse(gameData['nMax']),
          int.parse(gameData['nMin']),
          gameData['description']!,
          gameData['creationDate']!,
          gameData['isAvailable'] == '1' ? true : false,
          categories[gameData['idCategory']]!
      );
    }
}