import 'package:cx_playground/screens/add_game_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../i18n/strings.g.dart';
import '../models/game_mode.dart';
import '../providers/auth.dart';
import '../providers/game.dart';
import '../providers/games.dart';
import '../widgets/game_widget.dart';

///Alert dialog tho avoid deleting necessary games
showAlertDialog(BuildContext context, String adminId, Game game, Function setState) {
  Widget cancelButton = TextButton(
    child: Text(t.yesNo.no),
    onPressed:  () {Navigator.of(context).pop();},
  );
  Widget continueButton = TextButton(
    child: Text(t.yesNo.yes),
    onPressed:  () async {
      try {
        await Games().deleteGame(adminId, game.id);
        setState(() {});
      } catch(error) {
        Fluttertoast.showToast(msg: error.toString());
      }
      Navigator.of(context).pop(true);},
  );
  AlertDialog alert = AlertDialog(
    title: Text(t.games.deleteGame),
    content: Text(t.games.areUSure(game: game.name)),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

///Stateful widget of UserScreen which will present all users and some basic operations on them
class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

///State of [GameScreen]
class _GamesScreenState extends State<GamesScreen> {

  ///Main widget of [GameScreen]
  @override
  Widget build(BuildContext context) {
    ///Vulnerability: Format String Attack
    ///Fix: This lines could be deleted because they are not needed,
    ///but if they were needed, package slang could be used to manipulate
    ///strings in a more secure way
    if (kDebugMode) {
      print(sprintf("%s %s %s %s", ["Hello", "World", "from", "Sprintf!!"]));
    }
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder:(context)=> AddGameScreen(GameMode.create) )).then((value) => setState(() {}));
          },
        child: const Icon(Icons.add),
      ),
      body : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(13, 155, 241, 1).withOpacity(1),
              const Color.fromRGBO(241, 83, 126, 1).withOpacity(1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
        child: Center(
          child: SizedBox(
              height: deviceSize.height - 200,
              width: deviceSize.width - 40,
              child: FutureBuilder(
                future: Provider.of<Games>(context).getGamesFromServer(),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (dataSnapshot.error != null) {
                      return Center(
                        child: Text(t.error.anErrorOccurred),
                      );
                    } else {
                      return Consumer<Games>(
                        builder: (ctx, gamesData, child) => ListView.builder(
                          itemCount: gamesData.games.length,
                          itemBuilder: (ctx, i) => Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            actions: [
                              IconSlideAction(
                                caption: t.usersAdmin.delete,
                                color: Theme.of(context).errorColor,
                                icon: Icons.delete,
                                onTap: () {showAlertDialog(context, Provider.of<Auth>(context, listen: false).userId, gamesData.games[i], setState);},
                              ),
                              if(gamesData.games[i].isAvailable) IconSlideAction(
                                  caption:  t.games.lock,
                                  color: Colors.amberAccent,
                                  icon: Icons.lock_open_outlined,
                                  onTap: () async {
                                    try{
                                      await Games().removeAvailable(Provider.of<Auth>(context, listen: false).userId, gamesData.games[i].id);
                                      Fluttertoast.showToast(msg: t.games.lockMessage);
                                    } catch (error){
                                      Fluttertoast.showToast(msg: error.toString());
                                    }
                                    setState(() {});
                                  }
                              ),
                              if(!gamesData.games[i].isAvailable) IconSlideAction(
                                  caption:  t.games.unlock,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  icon: Icons.lock_outline,
                                  onTap: () async {
                                    try{
                                      await Games().turnAvailable(Provider.of<Auth>(context, listen: false).userId, gamesData.games[i].id);
                                      Fluttertoast.showToast(msg: t.games.unlockMessage);
                                    } catch (error){
                                      Fluttertoast.showToast(msg: error.toString());
                                    }
                                    setState(() {});
                                  }
                              )
                            ],
                            child: GameWidget(gamesData.games[i].id, gamesData.games[i].name, gamesData.games[i].isAvailable, gamesData.games[i].category),
                          ),
                        ),
                      );
                    }
                  }
                },
              )
          ),
        ),
      ),
    );
  }
}
