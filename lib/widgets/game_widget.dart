import 'package:cx_playground/screens/games_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_mode.dart';
import '../providers/categories.dart';
import '../providers/game.dart';
import '../screens/add_game_screen.dart';

///Widget to represent a [Game] in the [GamesScreen]
class GameWidget extends StatefulWidget {
  String gameId = '';
  String name = '';
  bool isAvailable = false;
  String category = '';

  GameWidget(this.gameId, this.name, this.isAvailable, this.category);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

///State of [GameWidget]
class _GameWidgetState extends State<GameWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.all(10),
        color: widget.isAvailable? Colors.white : Colors.white30,
        child: ListTile(
          title: Text(widget.name),
          subtitle: Text(widget.category),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () async {Game game = await Game().getGame(widget.gameId); Navigator.push(context,MaterialPageRoute(builder:(context)=> AddGameScreen(GameMode.edit, game))).then((value) => setState(() {}));},),
        ),
      ),
    );
  }
}